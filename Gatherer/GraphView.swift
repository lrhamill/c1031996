//
//  GraphView.swift
//  c1031996
//
//  Created by Liam Hamill on 25/07/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GraphView: UIView {
    
    var sampleStepData: [Int]?
    var sampleHappyData: [Int]?
    
    enum dataTypes {
        case StepData
        case HappyData
    }
    
    func genRandomData(n: Int, type: dataTypes) -> [Int] {
        
        // Create random data for testing
        
        var output = [Int]()
        
        if type == .StepData {
            for i in 0..<n {
                output.append(Int(arc4random_uniform(10000) + 1))
            }
        } else {
            for i in 0..<n {
                output.append(Int(arc4random_uniform(70) + 1))
            }
        }
        
        return output
        
    }

    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        //set up background clipping area
        var path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        //6 - draw the gradient
        var startPoint = CGPoint.zeroPoint
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            0)
        
        if sampleStepData == nil || sampleHappyData == nil {
            return
        }
        
        
    
    }
    
}