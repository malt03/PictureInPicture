//
//  UIWindow+DidAddSubview.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/18.
//
//

import UIKit

extension Notification.Name {
  static let PictureInPictureUIWindowDidAddSubview = Notification.Name("PictureInPictureUIWindowDidAddSubview")
}

extension UIView {
  private static var changed = false
  
  func dh_didAddSubview(_ subview: UIView) {
    self.dh_didAddSubview(subview)
    if self is UIWindow {
      NotificationCenter.default.post(name: .PictureInPictureUIWindowDidAddSubview, object: nil)
    }
  }
  
  class func exchangeDidAddSubview() {
    if changed { return }
    changed = true
    let from = class_getInstanceMethod(self, #selector(didAddSubview(_:)))
    let to = class_getInstanceMethod(self, #selector(dh_didAddSubview(_:)))
    method_exchangeImplementations(from, to)
  }
}
