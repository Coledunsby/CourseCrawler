//
//  TPSession.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-11-17.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Parse

class TPSession: PFObject, PFSubclassing {
    
    @NSManaged var name: String?
    @NSManaged var identifier: String?
    
    static func parseClassName() -> String {
        return "Session"
    }
    
}
