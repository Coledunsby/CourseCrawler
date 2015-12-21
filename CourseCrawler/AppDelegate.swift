//
//  AppDelegate.swift
//  CourseCrawler
//
//  Created by Cole Dunsby on 2015-12-21.
//  Copyright © 2015 Cole Dunsby. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register Parse Subclasses
        TPCourse.registerSubclass()
        TPSession.registerSubclass()
        TPTimeslot.registerSubclass()
        
        // Run Crawler
        Spider.crawl()
        
        return true
    }

}

