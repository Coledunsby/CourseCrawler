//
//  TPTimeslot.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-11-17.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Parse

class TPTimeslot: PFObject, PFSubclassing {
    
    @NSManaged var sessionIdentifier: String?
    @NSManaged var courseCode: String?
    @NSManaged var section: String?
    @NSManaged var activity: String?
    @NSManaged var day: String?
    @NSManaged var professor: String?
    @NSManaged var place: String?
    
    static func parseClassName() -> String {
        return "Timeslot"
    }
    
}
