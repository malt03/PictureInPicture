//
//  ContainerView.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/18.
//
//

import UIKit

class ContainerView: UIView {
  private(set) var viewController: UIViewController?
  
  func present(with viewController: UIViewController) {
    self.viewController?.view.removeFromSuperview()
    self.viewController = viewController
    addSubview(viewController.view)
    layoutIfNeeded()
  }
  
  func dismiss() {
    viewController?.view.removeFromSuperview()
    viewController = nil
  }
}
