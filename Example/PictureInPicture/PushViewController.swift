//
//  PushViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 2017/07/25.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

final class PushViewController: UIViewController {
  @IBAction private func back() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("push willDisappear")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("push didDisappear")
  }
  
  deinit {
    print("push deinitted")
  }
}
