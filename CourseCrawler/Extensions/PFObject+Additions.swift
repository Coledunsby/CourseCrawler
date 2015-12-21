//
//  PFObject+Additions.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-12-20.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Parse

extension PFObject {
    
    func toJSON() -> [String : AnyObject] {
        var json = [String : AnyObject]()
        for key in self.allKeys {
            let object = self.objectForKey(key)!
            json[key] = object.isKindOfClass(PFObject) ? object.objectId : object
        }
        return json
    }
    
}