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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    observeNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
}

// Notifications
extension ViewController {
  fileprivate func observeNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(pictureInPictureMadeSmaller), name: .PictureInPictureMadeSmaller, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(pictureInPictureMadeLarger), name: .PictureInPictureMadeLarger, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(pictureInPictureMoved(_:)), name: .PictureInPictureMoved, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(pictureInPictureDismissed), name: .PictureInPictureDismissed, object: nil)
  }
  
  @objc private func pictureInPictureMadeSmaller() {
    print("pictureInPictureMadeSmaller")
  }
  
  @objc private func pictureInPictureMadeLarger() {
    print("pictureInPictureMadeLarger")
  }
  
  @objc private func pictureInPictureMoved(_ notification: Notification) {
    let userInfo = notification.userInfo!
    let oldCorner = userInfo[PictureInPictureOldCornerUserInfoKey] as! PictureInPicture.Corner
    let newCorner = userInfo[PictureInPictureNewCornerUserInfoKey] as! PictureInPicture.Corner
    print("pictureInPictureMoved(old: \(oldCorner), new: \(newCorner))")
  }
  
  @objc private func pictureInPictureDismissed() {
    print("pictureInPictureDismissed")
  }
}
