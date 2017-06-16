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
  @IBAction func present() {
    PictureInPicture.shared.present(with: UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "PiP"))
  }
  
  @IBAction func dismiss() {
    PictureInPicture.shared.dismiss()
  }
}

