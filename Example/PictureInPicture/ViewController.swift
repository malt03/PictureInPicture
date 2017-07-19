//
//  ViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 07/17/2017.
//  Copyright (c) 2017 Koji Murata. All rights reserved.
//

import UIKit
import PictureInPicture

final class ViewController: UIViewController {
  private static var instanceNumber = 0
  @IBOutlet weak var instanceNumberLabel: UILabel! {
    didSet {
      instanceNumberLabel.text = "\(ViewController.instanceNumber)"
      ViewController.instanceNumber += 1
    }
  }

  @IBAction func present() {
    PictureInPicture.shared.present(with: UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "PiP"))
  }
  
  @IBAction func presentWithoutMakingLarger() {
    PictureInPicture.shared.present(with: UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "PiP"), makeLargerIfNeeded: false)
  }

  @IBAction func dismiss() {
    PictureInPicture.shared.dismiss(animation: true)
  }
  
  @IBAction func changeWindow() {
    NewWindowViewController.present()
  }

  @IBAction func changeRootViewController() {
    UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()
  }
}
