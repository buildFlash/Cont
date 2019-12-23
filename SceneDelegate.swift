//
//  SceneDelegate.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("active")
        NotificationCenter.default.post(name: .syncContacts, object: nil)
    }
}

