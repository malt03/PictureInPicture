//
//  PictureInPicture.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import Foundation

public final class PictureInPicture {
  public static func configure(movable: Bool = true, scale: CGFloat = 0.2, margin: CGFloat = 8, defaultEdge: HorizontalEdge = .right) {
    self.movable = movable
    self.scale = scale
    self.margin = margin
    self.defaultEdge = defaultEdge
  }
  
  static var movable = true
  static var scale = CGFloat(0.2)
  static var margin = CGFloat(8)
  private static var defaultEdge = HorizontalEdge.right
  
  static var defaultCorner: Corner {
    return Corner(.bottom, defaultEdge)
  }
  
  public static let shared = PictureInPicture()
  
  public func present(with viewController: UIViewController) {
    UIView.exchangeDidAddSubview()
    viewCreateIfNeeded.present(with: viewController)
  }
  
  public func makeLarger() {
    view?.applyLarge()
  }
  
  public func makeSmaller() {
    view?.applySmall()
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

  public enum HorizontalEdge {
    case left
    case right
  }
  
  enum VerticalEdge {
    case top
    case bottom
  }
  
  enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var verticalEdge: VerticalEdge {
      switch self {
      case .topLeft, .topRight: return .top
      case .bottomLeft, .bottomRight: return .bottom
      }
    }
    
    var horizontalEdge: HorizontalEdge {
      switch self {
      case .topLeft, .bottomLeft: return .left
      case .topRight, .bottomRight: return .right
      }
    }
    
    init(_ verticalEdge: VerticalEdge, _ horizontalEdge: HorizontalEdge) {
      switch verticalEdge {
      case .top:
        switch horizontalEdge {
        case .left:  self = .topLeft
        case .right: self = .topRight
        }
      case .bottom:
        switch horizontalEdge {
        case .left:  self = .bottomLeft
        case .right: self = .bottomRight
        }
      }
    }
  }
}
