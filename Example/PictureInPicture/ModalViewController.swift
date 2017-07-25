//
//  ModalViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 2017/07/25.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

final class ModalViewController: UIViewController {
  @IBAction private func dismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("modal willDisappear")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("modal didDisappear")
  }
  
  deinit {
    print("modal deinitted")
  }
}
