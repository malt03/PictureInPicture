//
//  PictureInPictureViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 2017/07/18.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import PictureInPicture

final class PictureInPictureViewController: UIViewController {
  @IBAction private func dismiss() {
    PictureInPicture.shared.dismiss(animation: true)
  }
}
