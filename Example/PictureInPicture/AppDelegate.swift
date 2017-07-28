//
//  AppDelegate.swift
//  PictureInPicture
//
//  Created by Koji Murata on 07/17/2017.
//  Copyright (c) 2017 Koji Murata. All rights reserved.
//

import UIKit
import PictureInPicture

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let shadowConfig = PictureInPicture.ShadowConfig(color: .black, offset: .zero, radius: 10, opacity: 1)
    PictureInPicture.configure(movable: false, scale: 0.3, margin: 10, defaultEdge: .left, shadowConfig: shadowConfig)
    return true
  }
}
