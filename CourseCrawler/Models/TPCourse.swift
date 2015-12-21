//
//  TPCourse.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-11-17.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Parse

class TPCourse: PFObject, PFSubclassing {
    
    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var sessions: [String]?
    
    static func parseClassName() -> String {
        return "Course"
    }
    
}
