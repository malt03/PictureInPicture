//
//  PictureInPictureView.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import UIKit

final class PictureInPictureView: ContainerView {
  private var animationDuration: TimeInterval { return 0.2 }
  
  func present(with viewController: UIViewController, makeLargerIfNeeded: Bool) {
    super.present(with: viewController)
    
    if superview == nil {
      UIApplication.shared.keyWindow?.addSubview(self)
      bounds = superview!.bounds
      frame.origin.y = superview!.bounds.height
      UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
        self.frame.origin.y = 0
      }, completion: nil)
    } else if makeLargerIfNeeded {
      applyLarge()
    }
  }
  
  func dismiss(animation: Bool) {
    if animation {
      if isLargeState {
        UIView.animate(withDuration: animationDuration, animations: {
          self.frame.origin.y = self.superview!.bounds.height
        }, completion: { _ in
          super.dismiss()
          self.removeFromSuperview()
        })
      } else {
        UIView.animate(withDuration: animationDuration, animations: {
          self.alpha = 0
        }, completion: { _ in
          super.dismiss()
          self.removeFromSuperview()
        })
      }
    } else {
      super.dismiss()
      self.removeFromSuperview()
    }
  }
  
  private var disposeHandler: (() -> Void)
  
  init(disposeHandler: @escaping (() -> Void)) {
    self.disposeHandler = disposeHandler

    super.init(frame: UIScreen.main.bounds)

    prepareNotifications()
    addGestureRecognizers()
  }
  
  required init?(coder aDecoder: NSCoder) {
    disposeHandler = {}
    super.init(coder: aDecoder)
  }
  
  private let panGestureRecognizer = UIPanGestureRecognizer()
  private let tapGestureRecognizer = UITapGestureRecognizer()
  private var currentCorner = PictureInPicture.defaultCorner
  
  private func addGestureRecognizers() {
    panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
    tapGestureRecognizer.addTarget(self, action: #selector(tapped))
    addGestureRecognizer(panGestureRecognizer)
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc private func tapped() {
    applyLarge()
  }
  
  func applyLarge() {
    if isLargeState { return }
    currentCorner = PictureInPicture.defaultCorner
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
      self.applyTransform(rate: 0)
    }, completion: nil)
    isLargeState = true
  }
  
  func applySmall() {
    if !isLargeState { return }
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
      self.applyTransform(rate: 1)
    }, completion: nil)
    isLargeState = false
  }
  
  @objc private func panned(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .began:
      let velocity = sender.velocity(in: superview!)
      isPanVectorVertical = abs(velocity.x) < abs(velocity.y)
      panChanged(sender)
    case .changed:
      panChanged(sender)
    case .cancelled, .ended:
      panEnded(sender)
    default:
      break
    }
  }
  
  private var isLargeState = true {
    didSet {
      viewController?.view.isUserInteractionEnabled = isLargeState
      viewController?.view.setNeedsLayout()
    }
  }
  
  private var isPanVectorVertical = true
  
  private func panChanged(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !PictureInPicture.movable {
      if isPanVectorVertical || isLargeState {
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
        applyTransform(translate: CGPoint(x: sender.translation(in: superview!).x, y: 0))
      }
    } else {
      applyTransform(corner: currentCorner, translate: sender.translation(in: superview!))
    }
  }
  
  private func panEnded(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !PictureInPicture.movable {
      if isPanVectorVertical || isLargeState {
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
        let location = sender.location(in: superview!).x
        let velocity = sender.velocity(in: superview!).x
        let locationInFeature = CGPoint(x: location + velocity * 0.2, y: 0)
        
        if superview!.bounds.contains(locationInFeature) {
          UIView.animate(withDuration: animationDuration, animations: {
            self.applyTransform()
          })
        } else {
          disposeHandler()
          let translate = sender.translation(in: superview!).x
          UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            let translateInFeature = CGPoint(x: translate + velocity, y: 0)
            self.applyTransform(translate: translateInFeature)
          }, completion: { _ in
            self.dismiss(animation: false)
          })
        }
      }
    } else {
      let location = sender.location(in: superview!)
      let velocity = sender.velocity(in: superview!)
      let locationInFeature = CGPoint(x: location.x + velocity.x * 0.05, y: location.y + velocity.y * 0.05)
      
      if superview!.bounds.contains(locationInFeature) {
        let v: PictureInPicture.VerticalEdge = locationInFeature.y < superview!.bounds.height / 2 ? .top : .bottom
        let h: PictureInPicture.HorizontalEdge = locationInFeature.x < superview!.bounds.width / 2 ? .left : .right
        currentCorner = PictureInPicture.Corner(v, h)
        UIView.animate(withDuration: animationDuration, animations: {
          self.applyTransform(corner: self.currentCorner)
        })
      } else {
        disposeHandler()
        let translate = sender.translation(in: superview!)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
          let translateInFeature = CGPoint(x: translate.x + velocity.x, y: translate.y + velocity.y)
          self.applyTransform(corner: self.currentCorner, translate: translateInFeature)
        }, completion: { _ in
          self.dismiss(animation: false)
        })
      }
    }
  }
  
  private var centerEdgeDistance: CGFloat { return 0.5 - PictureInPicture.scale / 2 }
  private var centerWhenSmall: CGFloat { return superview!.bounds.height - bounds.height * PictureInPicture.scale / 2 - PictureInPicture.margin }
  private var centerWhenLarge: CGFloat { return superview!.bounds.height / 2 }
  
  private func applyTransform(rate: CGFloat = 1, corner: PictureInPicture.Corner = PictureInPicture.defaultCorner, translate: CGPoint = .zero) {
    let x: CGFloat
    let y: CGFloat
    switch corner.horizontalEdge {
    case .left:  x = rate * (-superview!.bounds.width * centerEdgeDistance + PictureInPicture.margin)
    case .right: x = rate * (superview!.bounds.width * centerEdgeDistance - PictureInPicture.margin)
    }
    switch corner.verticalEdge {
    case .top:    y = rate * (-superview!.bounds.height * centerEdgeDistance + PictureInPicture.margin)
    case .bottom: y = rate * (superview!.bounds.height * centerEdgeDistance - PictureInPicture.margin)
    }
    center = CGPoint(x: x + translate.x + superview!.bounds.width / 2, y: y + translate.y + superview!.bounds.height / 2)
    let applyScale = 1 - (1 - PictureInPicture.scale) * rate
    transform = CGAffineTransform(scaleX: applyScale, y: applyScale)
  }
  
  private func prepareNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(bringToFront), name: .PictureInPictureUIWindowDidAddSubview, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(addSubviewOnKeyWindow), name: .UIWindowDidBecomeKey, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
  }
  
  @objc private func bringToFront() {
    superview?.bringSubview(toFront: self)
  }
  
  @objc private func addSubviewOnKeyWindow() {
    removeFromSuperview()
    UIApplication.shared.keyWindow?.addSubview(self)
    bounds = superview!.bounds
  }
  
  @objc private func orientationDidChange() {
    DispatchQueue.main.async {
      self.bounds = self.superview!.bounds
      self.applyTransform(rate: self.isLargeState ? 0 : 1, corner: self.currentCorner, translate: .zero)
    }
  }
}
