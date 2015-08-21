//
//  GraphViewController.swift
//  c1031996
//
//  Created by Liam Hamill on 25/07/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import UIKit

class GraphViewController : UIViewController {
    
    @IBOutlet weak var independentVar: UILabel!
    @IBOutlet weak var rSquared: UILabel!
    @IBOutlet weak var maxIndVar: UILabel!
    @IBOutlet weak var midIndVar: UILabel!    
    
    @IBOutlet weak var graph: GraphView!
    
    var toPass: HealthManager!
    var manager: HealthManager?
    
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(animated)
//
//        maxIndVar.text! = String(maxElement(graph!.sampleDVData!))
//        midIndVar.text! = String(maxElement(graph!.sampleDVData!)/2)
//        
//        graph!.getBestFit()
//        graph!.setNeedsDisplay()
//        
//        if graph!.rSquared == nil {
//            rSquared.text = "r^2: nil"
//        } else {
//            rSquared.text = String(format: "r^2 = %.3f", graph!.rSquared!)
//        }
//        
//        rSquared.setNeedsDisplay()
//        
//    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        graph!.setNeedsDisplay()
        
    }
    
    func notEnoughData() {
        
        let dataWarning = UIAlertController(title: "Not enough data", message: "Not enough data to generate a graph. You may need to fill in more surveys, or give the app a moment to load the data.", preferredStyle: UIAlertControllerStyle.Alert)
        
        dataWarning.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in return } ))
        
        self.presentViewController(dataWarning, animated: true, completion: nil)
        return
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager = toPass
        
        let graphValues = self.manager?.dataForGraph("steps")
        
        println(graphValues)
        
        if let happyVals = graphValues!["happiness"] {
            if let DVVals = graphValues!["steps"] {
                
                if happyVals.count < 3 {
                     notEnoughData()
//                    graph!.sampleHappyData = [1, 2, 3, 4, 5]
//                    graph!.sampleDVData = [1, 2, 3, 4, 5]
                    
                    return
                } else {
                    
                    graph!.sampleHappyData = graphValues!["happiness"]
                    graph!.sampleDVData = graphValues!["steps"]
                    
                    generateGraph()
                    
                }
            } else {
                 notEnoughData()
//                graph!.sampleHappyData = [1, 2, 3, 4, 5]
//                graph!.sampleDVData = [1, 2, 3, 4, 5]
//                
//                generateGraph()
                
                return
            }
        } else {
             notEnoughData()
//            graph!.sampleHappyData = [1, 2, 3, 4, 5]
//            graph!.sampleDVData = [1, 2, 3, 4, 5]
//            
//            generateGraph()
            
            return
        }
        
    }
 
    func generateGraph() {
        
        maxIndVar.text! = String(maxElement(graph!.sampleDVData!))
        midIndVar.text! = String(maxElement(graph!.sampleDVData!)/2)
        
        graph!.getBestFit()
        graph!.setNeedsDisplay()
        
        if graph!.rSquared == nil {
            rSquared.text = "r^2: nil"
        } else {
            rSquared.text = String(format: "r^2 = %.3f", graph!.rSquared!)
        }
        
        rSquared.setNeedsDisplay()

        
    }
    
}