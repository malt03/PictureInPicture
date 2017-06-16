//
//  NewWindowViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 2017/07/18.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

final class NewWindowViewController: UIViewController {
  private static var window: UIWindow?
  
  static func present() {
    let w = UIWindow(frame: UIScreen.main.bounds)
    w.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "NewWindow")
    w.makeKeyAndVisible()
    window = w
  }
  
  @IBAction func dismiss() {
    NewWindowViewController.window = nil
  }
}
