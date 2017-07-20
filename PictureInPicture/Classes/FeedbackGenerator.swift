//
//  FeedbackGenerator.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/20.
//
//

import UIKit

final class FeedbackGenerator {
  static let shared = FeedbackGenerator()
  
  private let generatorWrapper: NSObject?
  
  @available(iOS 10.0, *)
  private var generator: UIImpactFeedbackGenerator {
    return generatorWrapper as! UIImpactFeedbackGenerator
  }
  
  private init() {
    if #available(iOS 10.0, *) {
      generatorWrapper = UIImpactFeedbackGenerator(style: .light)
    } else {
      generatorWrapper = nil
    }
  }
  
  func prepare() {
    if #available(iOS 10.0, *) {
      generator.prepare()
    }
  }
  
  func occurred() {
    if #available(iOS 10.0, *) {
      generator.impactOccurred()
      generator.prepare()
    }
  }
}
