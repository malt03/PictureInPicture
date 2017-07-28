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
  public static let PictureInPictureDidBeginMakingSmaller = Notification.Name(rawValue: "PictureInPictureDidBeginMakingSmaller")
  public static let PictureInPictureDidBeginMakingLarger = Notification.Name(rawValue: "PictureInPictureDidBeginMakingLarger")
  public static let PictureInPictureMoved = Notification.Name(rawValue: "PictureInPictureMoved")
  public static let PictureInPictureDismissed = Notification.Name(rawValue: "PictureInPictureDismissed")
}

public let PictureInPictureOldCornerUserInfoKey = "PictureInPictureOldCornerUserInfoKey"
public let PictureInPictureNewCornerUserInfoKey = "PictureInPictureNewCornerUserInfoKey"
public let UIWindowLevelPictureInPicture = UIWindowLevelNormal + 1

public final class PictureInPicture {
  public struct ShadowConfig {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
    
    public init(color: UIColor = .black, offset: CGSize = .zero, radius: CGFloat = 5, opacity: Float = 0.5) {
      self.color = color
      self.offset = offset
      self.radius = radius
      self.opacity = opacity
    }
    
    public static var `default`: ShadowConfig {
      return ShadowConfig()
    }
  }
  
  public static func configure(movable: Bool = true,
                               scale: CGFloat = 0.2,
                               margin: CGFloat = 8,
                               defaultEdge: HorizontalEdge = .right,
                               shadowConfig: ShadowConfig = .default) {
    self.movable = movable
    self.scale = scale
    self.margin = margin
    self.defaultEdge = defaultEdge
    self.shadowConfig = shadowConfig
  }
  
  private(set) static var movable = true
  private(set) static var scale = CGFloat(0.2)
  private(set) static var margin = CGFloat(8)
  private(set) static var shadowConfig = ShadowConfig.default
  private static var defaultEdge = HorizontalEdge.right
  
  static var defaultCorner: Corner {
    return Corner(.bottom, defaultEdge)
  }
  
  public static let shared = PictureInPicture()
  
  public func present(with viewController: UIViewController, makeLargerIfNeeded: Bool = true) {
    windowCreateIfNeeded.present(with: viewController, makeLargerIfNeeded: makeLargerIfNeeded)
  }
  
  public func makeLarger() {
    window?.applyLarge()
  }
  
  public func makeSmaller() {
    window?.applySmall()
  }
  
  public func dismiss(animation: Bool = true) {
    window?.dismiss(animation: animation)
    window = nil
  }
  
  public var presentedViewController: UIViewController? {
    return window?.rootViewController
  }
  
  public var currentCorner: Corner {
    return window?.currentCorner ?? PictureInPicture.defaultCorner
  }
  
  private init() {
    prepareNotification()
  }
  
  private var windowCreateIfNeeded: PictureInPictureWindow {
    if let w = window { return w }
    let w = PictureInPictureWindow {
      self.keyWindow?.makeKeyAndVisible()
      self.window = nil
    }
    window = w
    return w
  }
  private(set) var window: PictureInPictureWindow?
  private var keyWindow = UIApplication.shared.keyWindow
  
  private func prepareNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: .UIWindowDidBecomeKey, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(madeLarger), name: .PictureInPictureMadeLarger, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didBeginMakingSmaller), name: .PictureInPictureDidBeginMakingSmaller, object: nil)
  }
  
  @objc private func windowDidBecomeKey() {
    if window == UIApplication.shared.keyWindow { return }
    keyWindow = UIApplication.shared.keyWindow
  }
  
  @objc private func madeLarger() {
    window?.makeKeyAndVisible()
  }
  
  @objc private func didBeginMakingSmaller() {
    keyWindow?.makeKeyAndVisible()
  }
  
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
