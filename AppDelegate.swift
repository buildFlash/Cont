//
//  AppDelegate.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CNContactStore().requestAccess(for: .contacts) { (access, error) in
          print("Access: \(access)")
        }

        return true
    }
    
}
