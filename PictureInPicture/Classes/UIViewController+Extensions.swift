//
//  UIViewController+Extensions.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/19.
//
//

import UIKit

extension UIViewController {
  func setNeedsUpdateConstraints() {
    childViewControllers.forEach { $0.setNeedsUpdateConstraints() }
    view.setNeedsUpdateConstraints()
  }
  
  func dismissPresentedViewControllers(completion: @escaping () -> Void) {
    if let vc = presentedViewController {
      vc.dismissWithPresentedViewController(completion: completion)
    } else {
      completion()
    }
  }
  
  private func dismissWithPresentedViewController(completion: @escaping () -> Void) {
    if let vc = presentedViewController {
      vc.dismissWithPresentedViewController {
        self.dismiss(animated: false, completion: completion)
      }
    } else {
      dismiss(animated: false, completion: completion)
    }
  }
}
