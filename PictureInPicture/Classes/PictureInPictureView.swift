//
//  PictureInPictureView.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import UIKit

final class PictureInPictureView: ContainerView {
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
  
  enum VerticalEdge {
    case top
    case bottom
  }
  
  enum HorizontalEdge {
    case left
    case right
  }
  
  var movable = true
  var animationDuration = 0.2
  
  override func present(with viewController: UIViewController) {
    super.present(with: viewController)
    
    if superview == nil {
      UIApplication.shared.keyWindow?.addSubview(self)
      frame.origin.y = superview!.bounds.height
      UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
        self.frame.origin.y = 0
      }, completion: nil)
    } else {
      applyLarge()
    }
  }
  
  func dismiss(animation: Bool, completion: @escaping (() -> Void) = {}) {
    if animation {
      if isLargeState {
        UIView.animate(withDuration: animationDuration, animations: {
          self.frame.origin.y = self.superview!.bounds.height
        }, completion: { _ in
          super.dismiss()
          self.removeFromSuperview()
          completion()
        })
      } else {
        UIView.animate(withDuration: animationDuration, animations: {
          self.alpha = 0
        }, completion: { _ in
          super.dismiss()
          self.removeFromSuperview()
          completion()
        })
      }
    } else {
      super.dismiss()
      self.removeFromSuperview()
      completion()
    }
  }
  
  private var disposeHandler: (() -> Void)
  
  init(disposeHandler: @escaping (() -> Void)) {
    self.disposeHandler = disposeHandler

    super.init(frame: UIScreen.main.bounds)

    backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    prepareNotifications()
    addGestureRecognizers()
  }
  
  required init?(coder aDecoder: NSCoder) {
    disposeHandler = {}
    super.init(coder: aDecoder)
  }
  
  private let panGestureRecognizer = UIPanGestureRecognizer()
  private let tapGestureRecognizer = UITapGestureRecognizer()
  private var currentCorner = Corner.bottomRight
  
  private func addGestureRecognizers() {
    panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
    tapGestureRecognizer.addTarget(self, action: #selector(tapped))
    addGestureRecognizer(panGestureRecognizer)
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc private func tapped() {
    applyLarge()
  }
  
  private func applyLarge() {
    if isLargeState { return }
    isLargeState = true
    currentCorner = .bottomRight
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
      self.applyTransform(rate: 0)
    }, completion: nil)
  }
  
  @objc private func panned(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .began, .changed:
      panChanged(sender)
    case .cancelled, .ended:
      panEnded(sender)
    default:
      break
    }
  }
  
  private var isLargeState = true
  
  private func panChanged(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !movable {
      let translation = sender.translation(in: superview!).y
      let location = sender.location(in: superview!).y
      let beginningLocation = location - translation
      
      let rate: CGFloat
      
      if isLargeState {
        rate = min(1, max(0, translation / (centerWhenSmall - beginningLocation)))
      } else {
        rate = 1 - min(1, max(0, translation / (centerWhenLarge - beginningLocation)))
      }
      
      applyTransform(rate: rate)
    } else {
      applyTransform(corner: currentCorner, translate: sender.translation(in: superview!))
    }
  }
  
  private func panEnded(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !movable {
      let translation = sender.translation(in: superview!).y
      let location = sender.location(in: superview!).y
      let beginningLocation = location - translation
      let endLocation = isLargeState ? centerWhenSmall : centerWhenLarge
      let velocity = sender.velocity(in: superview!).y
      
      let isApply = (location + velocity * 0.1 - beginningLocation) / (endLocation - beginningLocation) > 0.5
      let isToSmall = isLargeState == isApply
      
      let v: CGFloat
      if isApply {
        v = velocity / (endLocation - location)
      } else {
        v = velocity / (beginningLocation - location)
      }
      
      if isToSmall {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: v, options: .curveLinear, animations: {
          self.applyTransform(rate: 1)
        }, completion: nil)
        isLargeState = false
      } else {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: v, options: .curveLinear, animations: {
          self.applyTransform(rate: 0)
        }, completion: nil)
        isLargeState = true
      }
    } else {
      let location = sender.location(in: superview!)
      let velocity = sender.velocity(in: superview!)
      let locationInFeature = CGPoint(x: location.x + velocity.x * 0.1, y: location.y + velocity.y * 0.1)
      
      if superview!.bounds.contains(locationInFeature) {
        let v: VerticalEdge = location.y < superview!.bounds.height / 2 ? .top : .bottom
        let h: HorizontalEdge = location.x < superview!.bounds.width / 2 ? .left : .right
        currentCorner = Corner(v, h)
        UIView.animate(withDuration: animationDuration, animations: {
          self.applyTransform(corner: self.currentCorner)
        })
      } else {
        disposeHandler()
        let translate = sender.translation(in: superview!)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
          let translateInFeature = CGPoint(x: translate.x + velocity.x, y: translate.y + velocity.y)
          self.applyTransform(rate: 1, corner: self.currentCorner, translate: translateInFeature)
        }, completion: { _ in
          self.dismiss(animation: false)
        })
      }
    }
  }
  
  private var scale: CGFloat { return 0.2 }
  private var centerEdgeDistance: CGFloat { return 0.5 - scale / 2 }
  private var margin: CGFloat { return 8 }
  private var centerWhenSmall: CGFloat { return superview!.bounds.height - bounds.height * scale / 2 - margin }
  private var centerWhenLarge: CGFloat { return superview!.bounds.height / 2 }
  
  private func applyTransform(rate: CGFloat = 1, corner: Corner = .bottomRight, translate: CGPoint = .zero) {
    let x: CGFloat
    let y: CGFloat
    switch corner.horizontalEdge {
    case .left:  x = rate * (-superview!.bounds.width * centerEdgeDistance + margin)
    case .right: x = rate * (superview!.bounds.width * centerEdgeDistance - margin)
    }
    switch corner.verticalEdge {
    case .top:    y = rate * (-superview!.bounds.height * centerEdgeDistance + margin)
    case .bottom: y = rate * (superview!.bounds.height * centerEdgeDistance - margin)
    }
    center = CGPoint(x: x + translate.x + superview!.bounds.width / 2, y: y + translate.y + superview!.bounds.height / 2)
    let applyScale = 1 - (1 - scale) * rate
    transform = CGAffineTransform(scaleX: applyScale, y: applyScale)
  }
  
  private func prepareNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(addSubviewOnKeyWindow), name: .UIWindowDidBecomeKey, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
  }
  
  @objc private func addSubviewOnKeyWindow() {
    removeFromSuperview()
    UIApplication.shared.keyWindow?.addSubview(self)
  }
  
  @objc private func orientationDidChange() {
  }
}
