//
//  RxJoystickView.swift
//  RxJoystickView
//
//  Created by Tomas Friml on 28/03/2018.
//
//  MIT License
//
//  Copyright (c) 2018 Tomas Friml
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import RxCocoa
import RxSwift

public class RxJoystickView: UIView {
    
    /// Flag determining if vertical line should be drawn.
    public var showVerticalLine: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    /// Flag determining if horizontal line should be drawn.
    public var showHorizontalLine: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    /// Vertical line color
    public var verticalLineColor: UIColor = UIColor.gray {
        didSet { setNeedsDisplay() }
    }
    
    /// Horizontal line color
    public var horizontalLineColor: UIColor = UIColor.gray {
        didSet { setNeedsDisplay() }
    }
    
    /// Joystick thumb radius in pt
    public var thumbRadius: CGFloat = 10 {
        didSet { createThumb() }
    }
    
    /// Joystick thumb color
    public var thumbColor: UIColor = UIColor.lightGray {
        didSet { createThumb() }
    }
    
    override public func draw(_ rect: CGRect) {
        if showVerticalLine {
            let verticalLinePath = UIBezierPath()
            verticalLinePath.move(to: CGPoint(x: bounds.midX, y: 0))
            verticalLinePath.addLine(to: CGPoint(x: bounds.midX, y: bounds.height))
            verticalLinePath.close()
            
            verticalLineColor.set()
            verticalLinePath.stroke()
        }
        
        if showHorizontalLine {
            let horizontalLinePath = UIBezierPath()
            horizontalLinePath.move(to: CGPoint(x: 0, y: bounds.midY))
            horizontalLinePath.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
            horizontalLinePath.close()
            
            horizontalLineColor.set()
            horizontalLinePath.stroke()
        }
        
        let point = CGPoint(x: bounds.midX, y: bounds.midY)
        drawThumb(at: point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let location = touches.first?.location(in: self) {
            let frame = _thumbLayerInner.frame.insetBy(dx: -thumbRadius, dy: -thumbRadius)
            if frame.contains(location) {
                _isDraggingThumb = true
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        /// Calculates relative position in [-1.0,1.0] interval.
        /// -1.0 means 100% left/up from center, 1.0 means 100% right/down from center
        /// - Parameters:
        ///   - position: Absolute position
        ///   - portionLength: Length of the line portion from end to center
        func calculateRelative(position: CGFloat, portionLength: CGFloat) -> Float {
            return Float((position - portionLength) / portionLength)
        }
        
        if _isDraggingThumb, let location = touches.first?.location(in: self) {
            var x = bounds.midX
            var y = bounds.midY
            if showVerticalLine {
                y = location.y
            }
            if showHorizontalLine {
                x = location.x
            }
            x = max(0, min(x, bounds.maxX))
            y = max(0, min(y, bounds.maxY))
            
            // calculate new positions
            if showHorizontalLine && _thumbLayerInner.position.x != x {
                let position = calculateRelative(position: x, portionLength: bounds.midX)
                _horizontalPositionChanged.onNext(position)
            }
            if showVerticalLine && _thumbLayerInner.position.y != y {
                let position = calculateRelative(position: y, portionLength: bounds.midY)
                _verticalPositionChanged.onNext(position)
            }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            _thumbLayerInner.position = CGPoint(x: x + thumbRadius, y: y + thumbRadius)
            _thumbLayerOuter.position = CGPoint(x: x + thumbRadius, y: y + thumbRadius)
            CATransaction.commit()
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if _isDraggingThumb {
            _isDraggingThumb = false
            drawThumb(at: _centerPoint)
            if showHorizontalLine {
                _horizontalPositionChanged.onNext(0)
            }
            if showVerticalLine {
                _verticalPositionChanged.onNext(0)
            }
        }
    }
    
    // MARK: - Private
    fileprivate let _thumbLayerInner = CAShapeLayer()
    fileprivate let _thumbLayerOuter = CAShapeLayer()
    fileprivate let _disposeBag = DisposeBag()
    fileprivate var _isDraggingThumb = false
    fileprivate var _centerPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // Reactive
    fileprivate let _horizontalPositionChanged = PublishSubject<Float>()
    fileprivate let _verticalPositionChanged = PublishSubject<Float>()
    
    fileprivate func setup() {
        layer.addSublayer(_thumbLayerInner)
        layer.addSublayer(_thumbLayerOuter)
        createThumb()
    }
    
    fileprivate func drawThumb(at point: CGPoint) {
        let adjustedPoint = CGPoint(x: point.x + thumbRadius, y: point.y + thumbRadius)
        _thumbLayerInner.position = adjustedPoint
        _thumbLayerOuter.position = adjustedPoint
    }
    
    fileprivate func createThumb() {
        let thumbPathInner = UIBezierPath(arcCenter: _centerPoint,
                                          radius: thumbRadius,
                                          startAngle: 0,
                                          endAngle: CGFloat.pi * 2,
                                          clockwise: true)
        
        let thumbPathOuter = UIBezierPath(arcCenter: _centerPoint,
                                          radius: thumbRadius + 2,
                                          startAngle: 0,
                                          endAngle: CGFloat.pi * 2,
                                          clockwise: true)
        thumbPathOuter.lineWidth = 2
        
        _thumbLayerInner.path = thumbPathInner.cgPath
        _thumbLayerInner.fillColor = thumbColor.cgColor
        _thumbLayerInner.bounds = CGRect(origin: _centerPoint, size: CGSize(width: 2 * thumbRadius, height: 2 * thumbRadius))
        _thumbLayerOuter.path = thumbPathOuter.cgPath
        _thumbLayerOuter.fillColor = UIColor.clear.cgColor
        _thumbLayerOuter.strokeColor = thumbColor.cgColor
        _thumbLayerOuter.bounds = CGRect(origin: _centerPoint, size: CGSize(width: 2 * thumbRadius, height: 2 * thumbRadius))

        setNeedsDisplay()
    }
}

public extension Reactive where Base: RxJoystickView {
    public var horizontalPositionChanged: Observable<Float> {
        return base._horizontalPositionChanged.asObservable()
    }
    
    public var verticalPositionChanged: Observable<Float> {
        return base._verticalPositionChanged.asObservable()
    }
}
