//
//  BorderButton.swift
//  c1031996
//
//  Created by Liam Hamill on 29/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import UIKit

class BorderButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blueColor().CGColor
    
    }

}
