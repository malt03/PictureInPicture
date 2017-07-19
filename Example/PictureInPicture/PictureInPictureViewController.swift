//
//  PictureInPictureViewController.swift
//  PictureInPicture
//
//  Created by Koji Murata on 2017/07/18.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import PictureInPicture

final class PictureInPictureViewController: UIViewController, UITableViewDataSource {
  private static var instanceNumber = 0
  @IBOutlet weak var instanceNumberLabel: UILabel! {
    didSet {
      instanceNumberLabel.text = "\(PictureInPictureViewController.instanceNumber)"
      PictureInPictureViewController.instanceNumber += 1
    }
  }
  
  @IBAction private func dismiss() {
    PictureInPicture.shared.dismiss(animation: true)
  }
  
  @IBAction private func makeSmaller() {
    PictureInPicture.shared.makeSmaller()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
    cell.textLabel?.text = "\(indexPath.row)"
    return cell
  }
}
