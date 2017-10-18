//
//  PictureInPictureView.swift
//  Pods
//
//  Created by Koji Murata on 2017/07/17.
//
//

import UIKit

final class PictureInPictureWindow: UIWindow {
  private var animationDuration: TimeInterval { return 0.2 }
  private var beforePresenting = true
  
  private let userInterfaceShutoutView = UIView()
  
  func present(with viewController: UIViewController, makeLargerIfNeeded: Bool) {
    let handler = {
      self.rootViewController = viewController
      
      if self.beforePresenting {
        self.beforePresenting = false
        self.bounds = UIScreen.main.bounds
        self.frame.origin.y = UIScreen.main.bounds.height
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut, animations: {
          self.frame.origin.y = 0
        }, completion: nil)
        self.makeKeyAndVisible()
      } else if makeLargerIfNeeded {
        self.applyLarge()
      }
    }
    if let rootViewController = rootViewController {
      rootViewController.dismissPresentedViewControllers(completion: handler)
    } else {
      handler()
    }
  }
  
  func dismiss(animation: Bool) {
    if animation {
      if isLargeState {
        UIView.animate(withDuration: animationDuration, animations: {
          self.frame.origin.y = UIScreen.main.bounds.height
        }, completion: { _ in
          self.rootViewController?.dismissPresentedViewControllers {
            self.disposeHandler()
            NotificationCenter.default.post(name: .PictureInPictureDismissed, object: nil)
          }
        })
      } else {
        UIView.animate(withDuration: animationDuration, animations: {
          self.alpha = 0
        }, completion: { _ in
          self.rootViewController?.dismissPresentedViewControllers {
            self.disposeHandler()
            NotificationCenter.default.post(name: .PictureInPictureDismissed, object: nil)
          }
        })
      }
    } else {
      self.rootViewController?.dismissPresentedViewControllers {
        self.disposeHandler()
        NotificationCenter.default.post(name: .PictureInPictureDismissed, object: nil)
      }
    }
  }
  
  var shadowEnabled = false {
    didSet {
      if shadowEnabled {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
      } else {
        layer.shadowColor = UIColor.clear.cgColor
      }
    }
  }
  
  private var disposeHandler: (() -> Void)
  
  init(disposeHandler: @escaping (() -> Void)) {
    self.disposeHandler = disposeHandler

    super.init(frame: UIScreen.main.bounds)

    prepareNotifications()
    addGestureRecognizers()
    
    FeedbackGenerator.shared.prepare()
    
    layer.shadowColor = PictureInPicture.shadowConfig.color.cgColor
    layer.shadowOffset = PictureInPicture.shadowConfig.offset
    layer.shadowRadius = PictureInPicture.shadowConfig.radius
    layer.shadowOpacity = PictureInPicture.shadowConfig.opacity
    
    windowLevel = UIWindowLevelPictureInPicture
    
    userInterfaceShutoutView.frame = UIScreen.main.bounds
    userInterfaceShutoutView.backgroundColor = .clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    disposeHandler = {}
    super.init(coder: aDecoder)
  }
  
  private let panGestureRecognizer = UIPanGestureRecognizer()
  private let tapGestureRecognizer = UITapGestureRecognizer()
  private(set) var currentCorner = PictureInPicture.defaultCorner
  
  private func addGestureRecognizers() {
    panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
    panGestureRecognizer.maximumNumberOfTouches = 1
    panGestureRecognizer.delegate = self
    tapGestureRecognizer.addTarget(self, action: #selector(tapped))
    addGestureRecognizer(panGestureRecognizer)
    addGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer.isEnabled = false
  }
  
  @objc private func tapped() {
    applyLarge()
  }
  
  func applyLarge() {
    if isLargeState { return }
    currentCorner = PictureInPicture.defaultCorner
    NotificationCenter.default.post(name: .PictureInPictureDidBeginMakingLarger, object: nil)
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
      self.applyTransform(rate: 0)
    }, completion: { _ in
      NotificationCenter.default.post(name: .PictureInPictureMadeLarger, object: nil)
    })
    isLargeState = true
  }
  
  func applySmall() {
    if !isLargeState { return }
    NotificationCenter.default.post(name: .PictureInPictureDidBeginMakingSmaller, object: nil)
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
      self.applyTransform(rate: 1)
    }, completion: { _ in
      NotificationCenter.default.post(name: .PictureInPictureMadeSmaller, object: nil)
    })
    isLargeState = false
  }
  
  @objc private func panned(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .began:
      isPanning = true
      let velocity = sender.velocity(in: mainWindow)
      isPanVectorVertical = abs(velocity.x) < abs(velocity.y)
      panChanged(sender)
    case .changed:
      panChanged(sender)
    case .cancelled, .ended:
      isPanning = false
      panEnded(sender)
    default:
      break
    }
  }
  
  private(set) var isLargeState = true {
    didSet {
      if isLargeState {
        userInterfaceShutoutView.removeFromSuperview()
      } else {
        addSubview(userInterfaceShutoutView)
      }
      tapGestureRecognizer.isEnabled = !isLargeState
      rootViewController?.setNeedsUpdateConstraints()
    }
  }
  
  private var isPanVectorVertical = true
  private var isPanning = false
  
  private var mainWindow: UIWindow {
    return UIApplication.shared.delegate!.window!!
  }
  
  private var lastRate = CGFloat(0)
  
  private func panChanged(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !PictureInPicture.movable {
      if isPanVectorVertical || isLargeState {
        FeedbackGenerator.shared.prepare()
        let translation = sender.translation(in: mainWindow).y
        let location = sender.location(in: mainWindow).y
        let beginningLocation = location - translation
        
        let rate: CGFloat
        
        if isLargeState {
          rate = min(1, max(0, translation / (locationWhenSmall(y: beginningLocation) - beginningLocation)))
        } else {
          rate = 1 - min(1, max(0, translation / (locationWhenLarge(y: beginningLocation) - beginningLocation)))
        }

        if rate != 1 && lastRate == 1 { NotificationCenter.default.post(name: .PictureInPictureDidBeginMakingLarger, object: nil) }
        if rate != 0 && lastRate == 0 { NotificationCenter.default.post(name: .PictureInPictureDidBeginMakingSmaller, object: nil) }
        if rate == 0 && lastRate != 0 { NotificationCenter.default.post(name: .PictureInPictureMadeLarger, object: nil) }
        if rate == 1 && lastRate != 1 { NotificationCenter.default.post(name: .PictureInPictureMadeSmaller, object: nil) }
        applyTransform(rate: rate)
      } else {
        applyTransform(translate: CGPoint(x: sender.translation(in: mainWindow).x, y: 0))
      }
    } else {
      applyTransform(corner: currentCorner, translate: sender.translation(in: mainWindow))
    }
  }
  
  private func panEnded(_ sender: UIPanGestureRecognizer) {
    if isLargeState || !PictureInPicture.movable {
      if isPanVectorVertical || isLargeState {
        let translation = sender.translation(in: mainWindow).y
        let location = sender.location(in: mainWindow).y
        let beginningLocation = location - translation
        let endLocation = isLargeState ? locationWhenSmall(y: beginningLocation) : locationWhenLarge(y: beginningLocation)
        let velocity = sender.velocity(in: mainWindow).y
        
        let isApply = (location + velocity * 0.1 - beginningLocation) / (endLocation - beginningLocation) > 0.5
        let isToSmall = isLargeState == isApply
        
        let v: CGFloat
        if isApply {
          v = velocity / (endLocation - location)
        } else {
          v = velocity / (beginningLocation - location)
        }
        
        if lastRate != 0 && lastRate != 1 {
          FeedbackGenerator.shared.occurred()

          if isToSmall {
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: v, options: .curveEaseIn, animations: {
              self.applyTransform(rate: 1)
            }, completion: { _ in
              NotificationCenter.default.post(name: .PictureInPictureMadeSmaller, object: nil)
            })
          } else {
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: v, options: .curveEaseIn, animations: {
              self.applyTransform(rate: 0)
            }, completion: { _ in
              NotificationCenter.default.post(name: .PictureInPictureMadeLarger, object: nil)
            })
          }
        }
        isLargeState = !isToSmall
      } else {
        let location = sender.location(in: mainWindow).x
        let velocity = sender.velocity(in: mainWindow).x
        let locationInFeature = CGPoint(x: location + velocity * 0.2, y: 0)
        
        if UIScreen.main.bounds.contains(locationInFeature) {
          UIView.animate(withDuration: animationDuration, animations: {
            self.applyTransform()
          })
        } else {
          disposeHandler()
          let translate = sender.translation(in: mainWindow).x
          UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            let translateInFeature = CGPoint(x: translate + velocity, y: 0)
            self.applyTransform(translate: translateInFeature)
          }, completion: { _ in
            self.dismiss(animation: false)
          })
        }
      }
    } else {
      let location = sender.location(in: mainWindow)
      let velocity = sender.velocity(in: mainWindow)
      let locationInFeature = CGPoint(x: location.x + velocity.x * 0.05, y: location.y + velocity.y * 0.05)
      
      if UIScreen.main.bounds.contains(locationInFeature) {
        let oldCorner = currentCorner
        let v: PictureInPicture.VerticalEdge = locationInFeature.y < UIScreen.main.bounds.height / 2 ? .top : .bottom
        let h: PictureInPicture.HorizontalEdge = locationInFeature.x < UIScreen.main.bounds.width / 2 ? .left : .right
        currentCorner = PictureInPicture.Corner(v, h)
        let newCorner = currentCorner
        UIView.animate(withDuration: animationDuration, animations: {
          self.applyTransform(corner: self.currentCorner)
        }, completion: { _ in
          NotificationCenter.default.post(name: .PictureInPictureMoved, object: nil, userInfo: [
            PictureInPictureOldCornerUserInfoKey: oldCorner,
            PictureInPictureNewCornerUserInfoKey: newCorner,
          ])
        })
      } else {
        disposeHandler()
        let translate = sender.translation(in: mainWindow)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: .curveLinear, animations: {
          let translateInFeature = CGPoint(x: translate.x + velocity.x * 0.1, y: translate.y + velocity.y * 0.1)
          self.applyTransform(corner: self.currentCorner, translate: translateInFeature)
        }, completion: { _ in
          self.dismiss(animation: false)
        })
      }
    }
  }
  
  private var centerEdgeDistance: CGFloat { return 0.5 - PictureInPicture.scale / 2 }
  private func locationWhenSmall(y: CGFloat) -> CGFloat { return UIScreen.main.bounds.height - (bounds.height - y) * PictureInPicture.scale - PictureInPicture.margin }
  private func locationWhenLarge(y: CGFloat) -> CGFloat { return bounds.height + (PictureInPicture.margin + y - UIScreen.main.bounds.height) / PictureInPicture.scale }
  
  private func applyTransform(rate: CGFloat = 1, corner: PictureInPicture.Corner = PictureInPicture.defaultCorner, translate: CGPoint = .zero) {
    let x: CGFloat
    let y: CGFloat
    switch corner.horizontalEdge {
    case .left:  x = rate * (-UIScreen.main.bounds.width * centerEdgeDistance + PictureInPicture.margin)
    case .right: x = rate * (UIScreen.main.bounds.width * centerEdgeDistance - PictureInPicture.margin)
    }
    
    switch corner.verticalEdge {
    case .top:
      let top: CGFloat
      if #available(iOS 11.0, *) {
        top = mainWindow.safeAreaInsets.top
      } else {
        top = UIApplication.shared.statusBarFrame.height
      }
      y = rate * (-UIScreen.main.bounds.height * centerEdgeDistance + PictureInPicture.margin + top)
    case .bottom:
      let bottom: CGFloat
      if #available(iOS 11.0, *) {
        bottom = mainWindow.safeAreaInsets.bottom
      } else {
        bottom = 0
      }
      y = rate * (UIScreen.main.bounds.height * centerEdgeDistance - PictureInPicture.margin - bottom)
    }
    center = CGPoint(x: x + translate.x + UIScreen.main.bounds.width / 2, y: y + translate.y + UIScreen.main.bounds.height / 2)
    let applyScale = 1 - (1 - PictureInPicture.scale) * rate
    transform = CGAffineTransform(scaleX: applyScale, y: applyScale)
    lastRate = rate
  }
  
  override var transform: CGAffineTransform {
    get { return super.transform }
    set {
      let oldValue = super.transform
      super.transform = newValue
      if oldValue.isIdentity != newValue.isIdentity {
        bounds.size.height = newValue.isIdentity ? UIScreen.main.bounds.height : UIScreen.main.bounds.height - .leastNonzeroMagnitude
        UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
      }
    }
  }
  
  private func prepareNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willChangeStatusBarFrame(_:)), name: .UIApplicationWillChangeStatusBarFrame, object: nil)
  }
  
  @objc private func orientationDidChange() {
    if !isLargeState {
      layer.masksToBounds = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
        self.layer.masksToBounds = false
      }
    }

    if #available(iOS 11.0, *) {
    } else {
      bounds = UIScreen.main.bounds
    }
    applyTransform(rate: isLargeState ? 0 : 1, corner: currentCorner, translate: .zero)
  }
  
  @objc private func willChangeStatusBarFrame(_ notification: Notification) {
    if currentCorner.verticalEdge == .bottom || isLargeState || isPanning { return }
    UIView.animate(withDuration: 0.35) {
      self.applyTransform(corner: self.currentCorner)
    }
  }
}

extension PictureInPictureWindow: UIGestureRecognizerDelegate {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if !isLargeState { return true }
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
    let velocity = panGestureRecognizer.velocity(in: self)
    return abs(velocity.x) < abs(velocity.y)
  }
}
