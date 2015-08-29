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
    
    @IBOutlet weak var stepsButton: UIButton!
    
    @IBOutlet weak var cycleButton: UIButton!
    
    @IBOutlet weak var sleepButton: UIButton!
    
    
    var toPass: HealthManager!
    var manager: HealthManager?
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Redraws the graph when the orientation changes
        
        graph!.setNeedsDisplay()
        
    }
    
    func notEnoughData() {
        
        let dataWarning = UIAlertController(title: "Not enough data", message: "Not enough data to generate a graph. You may need to fill in more surveys, or give the app a moment to load the data.", preferredStyle: UIAlertControllerStyle.Alert)
        
        dataWarning.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in return } ))
        
        self.presentViewController(dataWarning, animated: true, completion: nil)
        return
        
    }
    
    @IBAction func changeDataType(sender: UIButton) {
        
        genGraphForValue( sender.currentTitle!.lowercaseString )
        
    }

    
    func genGraphForValue( val: String ) {
        
        let graphValues = self.manager?.dataForGraph(val)
        
        if let happyVals = graphValues!["happiness"] {
            if let DVVals = graphValues![val] {
                
                if happyVals.count < 3 {
                    notEnoughData()
                    
                    return
                } else {
                    
                    independentVar.text = val
                    
                    graph!.sampleHappyData = graphValues!["happiness"]
                    graph!.sampleDVData = graphValues![val]
                    
                    generateGraph()
                    
                }
            } else {
                
                notEnoughData()
                
                return
            }
        } else {
            
            notEnoughData()
            
            return
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager = toPass
        
        genGraphForValue("steps")
        
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