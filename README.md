# RxJoystickView

[![CI Status](http://img.shields.io/travis/3ph/RxJoystickView.svg?style=flat)](https://travis-ci.org/3ph/RxJoystickView)
[![Version](https://img.shields.io/cocoapods/v/RxJoystickView.svg?style=flat)](http://cocoapods.org/pods/RxJoystickView)
[![License](https://img.shields.io/cocoapods/l/RxJoystickView.svg?style=flat)](http://cocoapods.org/pods/RxJoystickView)
[![Platform](https://img.shields.io/cocoapods/p/RxJoystickView.svg?style=flat)](http://cocoapods.org/pods/RxJoystickView)
![Swift](https://img.shields.io/badge/in-swift4.0-orange.svg)

A simple reactive joystick view widget. Tracks horizontal and vertical position of dragged thumb from center in range [-1.0, 1.0]. Both axes can be individually disabled.

## Usage

Simply add as custom view to storyboard or create programatically.

```swift
let joystickView = RxJoystickView()
```

#### Generic properties:

```swift
/// Flag determining if vertical line should be drawn.
/// Settings this to false also means vertical movement will be disabled.
joystickView.showVerticalLine = true

/// Flag determining if horizontal line should be drawn.
/// Settings this to false also means horizontal movement will be disabled.
joystickView.showHorizontalLine = true

/// Vertical line color
joystickView.verticalLineColor = UIColor.gray

/// Horizontal line color
joystickView.horizontalLineColor = UIColor.gray

/// Joystick thumb radius in pt
joystickView.thumbRadius = 10

/// Joystick thumb color
joystickView.thumbColor = UIColor.lightGray
```

#### Observing changes
```swift
// Horizontal thumb position changed: -1 is leftmost position, +1 is rightmost position.
joystickView
    .rx
    .horizontalPositionChanged
    .asDriver(onErrorJustReturn: 0)
    .drive(onNext: { position in
        NSLog("Horizontal position: \(position)")
    }).disposed(by: disposeBag)

joystickView
    .rx
    .verticalPositionChanged
    .asDriver(onErrorJustReturn: 0)
    .drive(onNext: { position in
        NSLog("Vertical position: \(position)")
    }).disposed(by: disposeBag)
```

## Example

To run the example project, run `pod try`.

## Requirements
iOS 8+, RxSwift.

## Installation

RxJoystickView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxJoystickView'
```

## Author

Tomas Friml, instantni.med@gmail.com

## License

RxJoystickView is available under the MIT license. See the LICENSE file for more info.
