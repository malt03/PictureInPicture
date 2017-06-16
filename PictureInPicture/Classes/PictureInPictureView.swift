//
//  PictureInPictureView.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import UIKit

final class PictureInPictureView: UIView {
  init() {
    super.init(frame: UIScreen.main.bounds)

    backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    prepareNotifications()
    addGestureRecognizer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private let panGestureRecognizer = UIPanGestureRecognizer()
  
  private func addGestureRecognizer() {
    panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
    addGestureRecognizer(panGestureRecognizer)
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
  }
  
  private func panEnded(_ sender: UIPanGestureRecognizer) {
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
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: v, options: .curveLinear, animations: {
        self.applyTransform(rate: 1)
      }, completion: nil)
      isLargeState = false
    } else {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: v, options: .curveLinear, animations: {
        self.applyTransform(rate: 0)
      }, completion: nil)
      isLargeState = true
    }
  }
  
  private var scale: CGFloat { return 0.2 }
  private var translate: CGFloat { return 0.5 - scale / 2 }
  private var margin: CGFloat { return 8 }
  private var centerWhenSmall: CGFloat { return bounds.height * (1 - scale / 2) - margin }
  private var centerWhenLarge: CGFloat { return bounds.height / 2 }
  
  private func applyTransform(rate: CGFloat) {
    let t = CGAffineTransform(translationX: rate * (bounds.width * translate - margin), y: rate * (bounds.height * translate - margin))
    let applyScale = 1 - (1 - scale) * rate
    transform = t.scaledBy(x: applyScale, y: applyScale)
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
