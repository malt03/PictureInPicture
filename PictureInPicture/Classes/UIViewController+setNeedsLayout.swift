//
//  UIViewController+setNeedsLayout.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/19.
//
//

import UIKit

extension UIViewController {
  func setNeedsLayout() {
    childViewControllers.forEach { $0.setNeedsLayout() }
    view.setNeedsLayout()
  }
}
