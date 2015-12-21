//
//  Array+Additions.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-12-20.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
    
}