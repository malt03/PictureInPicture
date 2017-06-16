//
//  PictureInPicture.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import Foundation

public final class PictureInPicture {
  public static let shared = PictureInPicture()
  
  public func present(with viewController: UIViewController) {
    viewCreateIfNeeded.present(with: viewController)
  }
  
  public func dismiss(animation: Bool = true) {
    view?.dismiss(animation: animation) {
      self.view = nil
    }
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
