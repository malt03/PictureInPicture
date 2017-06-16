# PictureInPicture

[![Version](https://img.shields.io/cocoapods/v/PictureInPicture.svg?style=flat)](http://cocoapods.org/pods/PictureInPicture)
[![License](https://img.shields.io/cocoapods/l/PictureInPicture.svg?style=flat)](http://cocoapods.org/pods/PictureInPicture)
[![Platform](https://img.shields.io/cocoapods/p/PictureInPicture.svg?style=flat)](http://cocoapods.org/pods/PictureInPicture)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

### Configure
If you want to change from default value.
Default: PictureInPicture.configure(movable: true, scale: 0.2, margin: 8)

```swift
PictureInPicture.configure(movable: false, scale: 0.3, margin: 10)
```

### Present
```swift
PictureInPicture.shared.present(with: viewController)
```

### Dismiss
```swift
PictureInPicture.shared.dismiss()
```

### Make Smaller
```swift
PictureInPicture.shared.makeSmaller()
```

### Make Larger
```swift
PictureInPicture.shared.makeLarger()
```

## Installation

PictureInPicture is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PictureInPicture"
```

## Author

Koji Murata, malt.koji@gmail.com

## License

PictureInPicture is available under the MIT license. See the LICENSE file for more info.
