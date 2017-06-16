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
  
  public func present() {
    
  }

  private init() {}
  
  private let window = PictureInPictureView()
  
}
