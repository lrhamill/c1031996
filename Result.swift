//
//  Result.swift
//  c1031996
//
//  Created by Liam Hamill on 24/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//
import Foundation
import CoreData

class Result: NSManagedObject {
    
    @NSManaged var date: NSDate
    @NSManaged var surveyResult: NSNumber
    
}