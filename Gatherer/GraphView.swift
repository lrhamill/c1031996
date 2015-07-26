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
    
    class func genRandomData(n: Int, type: dataTypes) -> [Int] {
        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        sampleStepData = GraphView.genRandomData(30, type: .StepData)
//        sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        sampleStepData = GraphView.genRandomData(30, type: .StepData)
        sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
    }

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
            sampleStepData = GraphView.genRandomData(30, type: .StepData)
            sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
        }

        
        //calculate the x point
        
        let margin:CGFloat = 20.0
        let graphWidth = width - margin * 2 - 4
        let maxSteps = maxElement(sampleStepData!)
        var columnXPoint = { (graphPoint:Int) -> CGFloat in
            //Calculate gap between points
            var x:CGFloat = CGFloat(graphPoint) / CGFloat(maxSteps) * graphWidth
            return x + margin
        }
        
        // calculate the y point
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = 70
        var columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        //Draw horizontal graph lines on the top of everything
        var linePath = UIBezierPath()
        
        //top line
        linePath.moveToPoint(CGPoint(x:margin, y: topBorder))
        linePath.addLineToPoint(CGPoint(x: width - margin,
            y:topBorder))
        
        //center line
        linePath.moveToPoint(CGPoint(x:margin,
            y: graphHeight/2 + topBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.moveToPoint(CGPoint(x:margin,
            y:height - bottomBorder))
        linePath.addLineToPoint(CGPoint(x:width - margin,
            y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        for i in 0..<sampleHappyData!.count {
            var point = CGPoint(x:columnXPoint(sampleStepData![i]), y:columnYPoint(sampleHappyData![i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalInRect:
                CGRect(origin: point,
                    size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
    
    }
    
    func linearRegression() -> Float? {
        
        if sampleStepData == nil || sampleHappyData == nil {
            return nil
        }
        
        let n = sampleStepData!.count

        
        return Float(1.0)
        
        
    }
    
}