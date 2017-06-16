//
//  PictureInPicture.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import Foundation

public final class PictureInPicture {
  public static func configure(movable: Bool = true, scale: CGFloat = 0.2, margin: CGFloat = 8) {
    self.movable = movable
    self.scale = scale
    self.margin = margin
  }
  
  static var movable = true
  static var scale = CGFloat(0.2)
  static var margin = CGFloat(8)
  
  public static let shared = PictureInPicture()
  
  public func present(with viewController: UIViewController) {
    UIView.exchangeDidAddSubview()
    viewCreateIfNeeded.present(with: viewController)
  }
  
  public func dismiss(animation: Bool = true) {
    view?.dismiss(animation: animation)
    view = nil
  }
  
  private init() {}
  
  private var viewCreateIfNeeded: PictureInPictureView {
    if let v = view { return v }
    let v = PictureInPictureView {
      self.view = nil
    }
    view = v
    return v
  }
  private var view: PictureInPictureView?
}
