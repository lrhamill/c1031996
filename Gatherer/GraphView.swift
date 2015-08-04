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
    
    var sampleDVData: [Int]?
    var sampleHappyData: [Int]?
    
    var rSquared: Double?
    var m: Double?
    var intercept: Double?
    
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
//        sampleDVData = GraphView.genRandomData(30, type: .StepData)
//        sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
//        sampleDVData = [Int]()
//        sampleHappyData = [Int]()
//        
//        sampleDVData! += 1...10
//        sampleHappyData! += 2...11
        sampleDVData = GraphView.genRandomData(30, type: .StepData)
        sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
    }
    
    func getBestFit() {
        
        // Calculates gradient (m) and intercept of best fit line
        
        let avgX = Double( sampleDVData!.reduce(0) { $0 + $1 } ) / Double(sampleDVData!.count)
        let avgY = Double( sampleHappyData!.reduce(0) { $0 + $1 } ) / Double(sampleHappyData!.count)
        let avgXavgY = avgX * avgY
        
        var XY = [Int]()
        var XSq = [Int]()
        
        var i = 0
        
        for item in sampleDVData! {
            
            XY.append(item * sampleHappyData![i])
            XSq.append(item * item)
            i++
            
        }
        
        let avgXY = Double( XY.reduce(0) { $0 + $1 } ) / Double(XY.count)
        let avgXSq = Double( XSq.reduce(0) { $0 + $1 } ) / Double(XSq.count)
        
        self.m = (avgXavgY - avgXY) / ((avgX * avgX) - avgXSq)
        
        self.intercept = avgY - (self.m! * avgX)
        
        // Calculating r-squared
        
        var predictedY = [Double]()
        
        // Populate array of predicted values from our observed step data and the best fit line
        
        for val in sampleDVData! {
            
            let predVal = Double(val) * self.m! + self.intercept!
            predictedY.append(predVal)
            
        }
        
        // Now generate array of squared error and difference from mean values
        
        var squaredError = [Double]()
        var fromMean = [Double]()
        i = 0
        
        for val in sampleHappyData! {
            
            // Squared error/difference from mean
            let valError = pow( ( Double(val) - predictedY[i] ), 2 )
            let meanDiff = pow( ( Double(val) - avgY ), 2 )
            
            squaredError.append(valError)
            fromMean.append(meanDiff)
            
            i++
            
        }
        
        // Run the r-squared formula
        
        let sumSqErr = squaredError.reduce(0, combine: +) // Find the sum of an array
        let sumFromMean = fromMean.reduce(0, combine: +)
        
        rSquared = 1 - ( sumSqErr /  sumFromMean )
        
        
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
        
        if sampleDVData == nil || sampleHappyData == nil {
            
            sampleDVData = [Int]()
            sampleHappyData = [Int]()
            
            sampleDVData! += 2...10
            sampleHappyData! += 2...10
//            sampleDVData = GraphView.genRandomData(30, type: .StepData)
//            sampleHappyData = GraphView.genRandomData(30, type: .HappyData)
        }

        
        //calculate the x point
        
        let margin:CGFloat = 20.0
        let graphWidth = width - margin * 2 - 4
        let maxSteps = maxElement(sampleDVData!)
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
        var color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        // Add points
        
        for i in 0..<sampleHappyData!.count {
            var point = CGPoint(x:columnXPoint(sampleDVData![i]), y:columnYPoint(sampleHappyData![i]))
            
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalInRect:
                CGRect(origin: point,
                    size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
        // Calculate line of best fit
        
        getBestFit()
    
        // Set up drawing the line
        
        let bestFit = UIBezierPath()
        
        let yVal = CGFloat((Double(sampleHappyData!.last!) * self.m!) + self.intercept!) / CGFloat(maxValue) * graphHeight
        let bestFitY = graphHeight + topBorder - yVal
        let maxX = sampleDVData!.reduce( Int.min, combine: { max($0, $1) } )
        
        let endOfBestFit = CGPoint( x:columnXPoint(maxX), y:bestFitY )

        // Draw line

        let startY = graphHeight + topBorder - (CGFloat(intercept!) / CGFloat(maxValue) * graphHeight)
        
        bestFit.moveToPoint(CGPoint(x:margin, y:startY))
        bestFit.addLineToPoint(endOfBestFit)
        
        color = UIColor(white: 0.5, alpha: 0.9)
        color.setStroke()
        bestFit.stroke()
        
    
    }
    
}