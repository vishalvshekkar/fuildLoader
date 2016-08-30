//
//  WigglySpin.swift
//  FluidLoader
//
//  Created by Vishal on 30/08/16.
//  Copyright © 2016 Vishal. All rights reserved.
//

import UIKit

class WigglySpin: CATransformLayer {
    
    // Adjust the color later on and the stack will redraw.
    
    var color: UIColor = UIColor.whiteColor() {
        didSet {
            guard let sublayers = sublayers where sublayers.count > 0 else { return }
            for (index, layer) in sublayers.enumerate() {
                (layer as? CAShapeLayer)?.fillColor = color.set(hueSaturationOrBrightness: .Brightness, percentage: 1.0-(0.1*CGFloat(index))).CGColor
            }
        }
    }
    
    /* Adjust the size later on and the stack will redraw.
     *
     * The corner radius is calculated to be the result of the width / 4. Assuming the width === height.
     * Default size is 100x100.
     */
    
    var size: CGSize = CGSize(width: 200, height: 200) {
        didSet {
            sublayers?.forEach({
                ($0 as? CAShapeLayer)?.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: size.width/4).CGPath
                ($0 as? CAShapeLayer)?.frame = CGPathGetBoundingBox(($0 as? CAShapeLayer)?.path)
                setAnchorPoint(CGPoint(x: 0.5, y: 0.5), forLayer: $0)
            })
        }
    }
    
    convenience init(withNumberOfItems items: Int) {
        self.init()
        masksToBounds = false
        
        for i in 0..<items {
            let layer = generateLayer(withSize: size, withIndex: i)
            insertSublayer(layer, atIndex: 0)
            setZPosition(ofShape: layer, z: CGFloat(i))
        }
        
        sublayers = sublayers?.reverse()
        centerInSuperlayer()
        rotateParentLayer(toDegree: 45)
    }
    
    private func generateLayer(withSize size: CGSize, withIndex index: Int) -> CAShapeLayer {
        let square = CAShapeLayer()
        square.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: size.width/4).CGPath
        square.frame = CGPathGetBoundingBox(square.path)
        setAnchorPoint(CGPoint(x: 0.5, y: 0.5), forLayer: square)
        return square
    }
    
    // Because adjusting the anchorPoint itself adjusts the frame, this is needed to avoid it, and keep the layer stationary.
    
    private func setAnchorPoint(anchorPoint: CGPoint, forLayer layer: CALayer) {
        var newPoint = CGPoint(x: layer.bounds.size.width * anchorPoint.x, y: layer.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: layer.bounds.size.width * layer.anchorPoint.x, y: layer.bounds.size.height * layer.anchorPoint.y)
        newPoint = CGPointApplyAffineTransform(newPoint, layer.affineTransform())
        oldPoint = CGPointApplyAffineTransform(oldPoint, layer.affineTransform())
        
        var position = layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = anchorPoint
    }
    
    private func setZPosition(ofShape shape: CAShapeLayer, z: CGFloat) {
        shape.zPosition = z*(-20)
    }
    
    private func centerInSuperlayer() {
        frame = CGRect(x: getX(), y: getY(), width: size.width, height: size.height)
    }
    
    private func getX() -> CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        return (screenWidth/2)-(size.width/2)
    }
    
    private func getY() -> CGFloat {
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        return (screenHeight/2)-(2*(size.height/2))
    }
    
    // When the time comes to animate, we'll need this. It converts...well...degrees into radians..
    
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return ((CGFloat(M_PI) * degrees) / 180.0)
    }
}

extension WigglySpin {
    func startAnimating() {
        var offsetTime = 0.0
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DRotate(transform, CGFloat(M_PI/2), 0, 0, 1)
        
        CATransaction.begin()
        sublayers?.forEach({
            let basic = getSpin(forTransform: transform)
            basic.beginTime = $0.convertTime(CACurrentMediaTime(), toLayer: nil) + offsetTime
            $0.addAnimation(basic, forKey: nil)
            offsetTime += 0.1
        })
        CATransaction.commit()
    }
    
    func stopAnimating() {
        sublayers?.forEach({ $0.removeAllAnimations() })
    }
    
    private func getSpin(forTransform transform: CATransform3D) -> CABasicAnimation {
        let basic = CABasicAnimation(keyPath: "transform")
        basic.toValue = NSValue(CATransform3D: transform)
        basic.duration = 1.0
        basic.fillMode = kCAFillModeForwards
        basic.repeatCount = HUGE
        basic.autoreverses = true
        basic.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        basic.removedOnCompletion = false
        return basic
    }
}

extension WigglySpin {
    private func rotateParentLayer(toDegree degree: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DRotate(transform, degreesToRadians(degree), 1, 0, 0)
        self.transform = transform
    }
}