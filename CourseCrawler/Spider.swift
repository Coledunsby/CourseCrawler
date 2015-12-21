//
//  Spider.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-11-17.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Foundation
import Kanna
import Parse

class Spider: NSObject {

    static let baseUrl = "https://www.uottawa.ca/academic/info/regist/calendars/courses/"
    
    static func crawl() {
        writeToFile("Session", objects: getSessions())
        
        var courses = getCourses(getCoursePages(getFaculties())).sort({ $0.0.code < $0.1.code })
        
        writeToFile("Timeslot", objects: getTimeslots(&courses))
        writeToFile("Course", objects: courses)
        
        print("done!")
    }
    
    static func writeToFile(name: String, objects: [PFObject]) -> Bool {
        print("writing \(name)s to file")
        
        do {
            var dictionary = [String : AnyObject]()
            dictionary["results"] = objects.map({$0.toJSON()})
            
            let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let writePath = documents.stringByAppendingPathComponent("\(name).json")
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
            let success = jsonData.writeToFile(writePath, atomically: true)
            
            return success
        } catch {
            print("Error: \(error)")
            
            return false
        }
    }
    
    static func getSessions() -> [TPSession] {
        var sessions: [TPSession] = []
        
        let urlString = "https://web30.uottawa.ca/v3/SITS/timetable/Search.aspx"
        
        print("crawling \(urlString)")
        
        if let url = NSURL(string: urlString) {
            do {
                let html = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                
                if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    for option in doc.css("#ctl00_MainContentPlaceHolder_Basic_SessionDropDown > option") {
                        if option.text != "All" {
                            let session = TPSession()
                            session.identifier = option["value"]
                            session.name = option.text
                            
                            sessions.append(session)
                        }
                    }
                } else {
                    print("Error: Could not parse html!")
                }
            } catch {
                print("Error: Could not get html from url!")
            }
        } else {
            print("Error: Could not load url!")
        }
        
        return sessions
    }
    
    static func getFaculties() -> [String] {
        var faculties: [String] = []
        
        print("crawling \(baseUrl)")
        
        if let url = NSURL(string: baseUrl) {
            do {
                let html = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                
                if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    for a in doc.css(".LinkDiv > a") {
                        faculties.append(a["href"]!)
                    }
                } else {
                    print("Error: Could not parse html!")
                }
            } catch {
                print("Error: Could not get html from url!")
            }
        } else {
            print("Error: Could not load url!")
        }
        
        return faculties
    }
    
    static func getCoursePages(faculties: [String]) -> [String] {
        var coursePages: [String] = []
        
        for faculty in faculties {
            let urlString = baseUrl + faculty
            
            print("crawling \(urlString)")
            
            if let url = NSURL(string: urlString) {
                do {
                    let html = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                    
                    if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        for a in doc.css(".LinkDiv > a") {
                            coursePages.append(a["href"]!.componentsSeparatedByString("/").last!)
                        }
                    } else {
                        print("Error: Could not parse html!")
                    }
                } catch {
                    print("Error: Could not get html from url!")
                }
            } else {
                print("Error: Could not load url!")
            }
        }
        
        return coursePages
    }
    
    static func getCourses(coursePages: [String]) -> [TPCourse] {
        var courses = [TPCourse]()
        
        for coursePage in coursePages {
            let urlString = baseUrl + coursePage
            
            print("crawling \(urlString)")
            
            if let url = NSURL(string: urlString) {
                do {
                    let html = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                    
                    if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        for table in doc.css("#crsBox") {
                            let course = TPCourse()
                            course.code = table.css(".crsCode").text
                            course.name = table.css(".crsTitle").text
                            
                            courses.append(course)
                        }
                    } else {
                        print("Error: Could not parse html!")
                    }
                } catch {
                    print("Error: Could not get html from url!")
                }
            } else {
                print("Error: Could not load url!")
            }
        }
        
        return courses
    }
    
    static func getTimeslots(inout courses: [TPCourse]) -> [TPTimeslot] {
        var timeslots = [TPTimeslot]()
        
        for course in courses {
            let urlString = "https://web30.uottawa.ca/v3/SITS/timetable/Course.aspx?code=" + course.code!
            var sessions = [String]()
            var previousSection: String?
            
            print("crawling \(urlString)")
            
            if let url = NSURL(string: urlString) {
                do {
                    let html = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                    
                    if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        for schedule in doc.css(".schedule") {
                            let session = schedule["id"]
                            sessions.append(session!)
                            for div in schedule.css("div") {
                                for tr in div.css("tr") {
                                    if tr.css(".Section").count > 0 {
                                        let sectionText = tr.css(".Section").text!.trim()
                                        var section = (sectionText == "") ? previousSection : sectionText.componentsSeparatedByString(" ")[1]
                                        let newSection = section!.containsString("(") ? "" : section
                                        
                                        if newSection!.trim() == "" {
                                            section = newSection
                                        }
                                        
                                        previousSection = section
                                        
                                        let timeslot = TPTimeslot()
                                        timeslot.sessionIdentifier = session
                                        timeslot.courseCode = course.code
                                        timeslot.section = section
                                        timeslot.activity = tr.css(".Activity").text?.componentsSeparatedByString(" ").first
                                        timeslot.day = (tr.css(".Day").text!.trim() == "00:00 - 00:00") ? "" : tr.css(".Day").text!.trim()
                                        timeslot.professor = (tr.css(".Professor").text!.trim() == "Not available at this time.") ? "" : tr.css(".Professor").text!.trim()
                                        timeslot.place = (tr.css(".Place").text!.trim() == "Not available at this time.") ? "" : tr.css(".Place").text!.trim()
                                        
                                        timeslots.append(timeslot)
                                    }
                                }
                            }
                        }
                    } else {
                        print("Error: Could not parse html!")
                    }
                } catch {
                    print("Error: Could not get html from url!")
                }
            } else {
                print("Error: Could not load url!")
            }
            
            course.sessions = sessions
            
            if course.sessions?.count == 0 {
                courses.removeObject(course)
            }
        }
        
        return timeslots
    }
    
}
