# PictureInPicture

[![Platform](https://img.shields.io/cocoapods/p/PictureInPicture.svg?style=flat)](http://cocoapods.org/pods/PictureInPicture)
![Language](https://img.shields.io/badge/language-Swift%203.1-orange.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/PictureInPicture.svg?style=flat)](http://cocoapods.org/pods/PictureInPicture)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License](https://img.shields.io/github/license/malt03/PictureInPicture.svg?style=flat)

![ScreenShot](https://raw.githubusercontent.com/malt03/PictureInPicture/master/README/Screenshot.gif)

## Usage
### Configure
If you want to change from default value.

```swift
let shadowConfig = PictureInPicture.ShadowConfig(color: .black, offset: .zero, radius: 10, opacity: 1)
PictureInPicture.configure(movable: true,
                           scale: 0.3,
                           margin: 10,
                           defaultEdge: .left,
                           shadowConfig: shadowConfig)
```

#### Default Config
```swift
PictureInPicture.configure(movable: true,
                           scale: 0.2,
                           margin: 8,
                           defaultEdge: .right,
                           shadowConfig: .default)
```

#### Default Shadow Config
```swift
ShadowConfig(color: .black, offset: .zero, radius: 5, opacity: 0.5)
```

### Main Functions
```swift
PictureInPicture.shared.present(with: viewController) // Present
PictureInPicture.shared.dismiss()                     // Dismiss
PictureInPicture.shared.makeSmaller()                 // Make Smaller
PictureInPicture.shared.makeLarger()                  // Make Larger
PictureInPicture.shared.presentedViewController       // Get presented ViewController
```

### Notifications
- PictureInPictureMadeSmaller
- PictureInPictureMadeLarger
- PictureInPictureDidBeginMakingSmaller
- PictureInPictureDidBeginMakingLarger
- PictureInPictureMoved
  - PictureInPictureOldCornerUserInfoKey # PictureInPicture.Corner
  - PictureInPictureNewCornerUserInfoKey # PictureInPicture.Corner
- PictureInPictureDismissed

### Other Constants
- UIWindowLevelPictureInPicture

## Installation

### Via CocoaPods
```ruby
pod "PictureInPicture"
```

### Via Carthage
```ruby
github "malt03/PictureInPicture"
```

## Author

Koji Murata, malt.koji@gmail.com

## License

PictureInPicture is available under the MIT license. See the LICENSE file for more info.
