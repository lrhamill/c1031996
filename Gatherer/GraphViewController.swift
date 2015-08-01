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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        maxIndVar.text! = String(maxElement(graph!.sampleStepData!))
        midIndVar.text! = String(maxElement(graph!.sampleStepData!)/2)
        
        graph!.getBestFit()
        graph!.setNeedsDisplay()
        
        if graph!.rSquared == nil {
            rSquared.text = "r^2: nil"
        } else {
            rSquared.text = String(format: "r^2 = %.3f", graph!.rSquared!)
        }
        
        rSquared.setNeedsDisplay()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        graph!.setNeedsDisplay()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager = toPass
        
    }
    
}