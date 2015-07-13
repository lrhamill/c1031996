//
//  HealthManager.swift
//  Gatherer
//
//  Created by Liam Hamill on 16/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
    
    var store = HKHealthStore()
    let emptyWriteTypes = Set<NSObject>()
    let readTypes = Set(arrayLiteral:
        
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
        
        HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!,
        
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!
    
    )

    func authoriseHK(completion: ((success:Bool, error:NSError!) -> Void)!) {

        if !HKHealthStore.isHealthDataAvailable() {
            
            println("No health data is available")
            
            let error = NSError(domain: "com.lrhamill.gatherer", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
            
        }
        
        println(readTypes)
        store.requestAuthorizationToShareTypes(emptyWriteTypes, readTypes: readTypes) { ( success, error ) -> Void in
            
            if completion != nil {
                completion(success:success,error:error)
            }
            println(success)
        
        }

    }
    
    func thisWeekSteps(completion: ((HKStatisticsCollectionQuery!, HKStatisticsCollection!, NSError!) -> Void)!) {
        
        // Get dates for this week
        let calendar = NSCalendar()
        let today = NSDate()
        let lastWeek = today.dateByAddingTimeInterval(-24 * 7 * 60 * 60)
        let interval = NSDateComponents()
        interval.day = 7
        
        // Sample type
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Run query
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: lastWeek, intervalComponents: interval)
        
        if completion != nil {
            query.initialResultsHandler = completion
        }
        
        store.executeQuery(query)
        
    }
}