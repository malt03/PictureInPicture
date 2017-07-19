//
//  PictureInPicture.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import Foundation

extension Notification.Name {
  public static let PictureInPictureMadeSmaller = Notification.Name(rawValue: "PictureInPictureMadeSmaller")
  public static let PictureInPictureMadeLarger = Notification.Name(rawValue: "PictureInPictureMadeLarger")
  public static let PictureInPictureMoved = Notification.Name(rawValue: "PictureInPictureMoved")
  public static let PictureInPictureDismissed = Notification.Name(rawValue: "PictureInPictureDismissed")
}

public let PictureInPictureOldCornerUserInfoKey = "PictureInPictureOldCornerUserInfoKey"
public let PictureInPictureNewCornerUserInfoKey = "PictureInPictureNewCornerUserInfoKey"

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
  
  public func present(with viewController: UIViewController, makeLargerIfNeeded: Bool = true) {
    UIView.exchangeDidAddSubview()
    viewCreateIfNeeded.present(with: viewController, makeLargerIfNeeded: makeLargerIfNeeded)
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
  
  public var presentingViewController: UIViewController? {
    return view?.viewController
  }
  
  public var currentCorner: Corner {
    return view?.currentCorner ?? PictureInPicture.defaultCorner
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
  
  public enum VerticalEdge {
    case top
    case bottom
  }
  
  public enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    public var verticalEdge: VerticalEdge {
      switch self {
      case .topLeft, .topRight: return .top
      case .bottomLeft, .bottomRight: return .bottom
      }
    }
    
    public var horizontalEdge: HorizontalEdge {
      switch self {
      case .topLeft, .bottomLeft: return .left
      case .topRight, .bottomRight: return .right
      }
    }
    
    public init(_ verticalEdge: VerticalEdge, _ horizontalEdge: HorizontalEdge) {
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
