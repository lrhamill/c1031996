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
        
        store.requestAuthorizationToShareTypes(emptyWriteTypes, readTypes: readTypes) { ( success, error ) -> Void in
            
            if completion != nil {
                completion(success:success,error:error)
            }
            println(success)
        
        }

    }
    
    func weeklyQuantitySum(sampleType: HKQuantityType!, completion: ((HKStatisticsCollectionQuery!, HKStatisticsCollection!, NSError!) -> Void)!) {
        
        // Get dates for this week
        let calendar = NSCalendar()
        let today = NSDate()
        let lastWeek = today.dateByAddingTimeInterval(-24 * 7 * 60 * 60)
        let interval = NSDateComponents()
        interval.day = 7
        
        // Run query
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: lastWeek, intervalComponents: interval)
        
        if completion != nil {
            query.initialResultsHandler = completion
        }
        
        store.executeQuery(query)
        
    }
    
    func weeklySleepAnalysis(completion: ((HKSampleQuery!, [AnyObject]!, NSError!) -> Void)!) {
        
        var totalSleep: Int?
    
        let today = NSDate()
        let lastWeek = today.dateByAddingTimeInterval(-24 * 7 * 60 * 60)
        
        let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        
        // creating a compound predicate for searching
        
        let timePredicate = HKQuery.predicateForSamplesWithStartDate(lastWeek, endDate: today, options: .None)
        
        let asleepPredicate = HKQuery.predicateForCategorySamplesWithOperatorType(
            .EqualToPredicateOperatorType,
            value: HKCategoryValueSleepAnalysis.Asleep.rawValue)
        
        let combinedPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [timePredicate, asleepPredicate])
        
        // construct query
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: combinedPredicate, limit: 0, sortDescriptors: nil, resultsHandler: completion)
        
        store.executeQuery(query)
        
    }
    
    func biologicalSex() -> String? {
        
        let userSex = store.biologicalSexWithError(nil)
        
        switch userSex!.biologicalSex {
            
        case .NotSet:
            return nil
        
        case .Other:
            return "Other"
        
        case .Female:
            return "Female"
        
        case .Male:
            return "Male"
            
        }
        
    }
    
    func age() -> Int? {
        
        let DOB = store.dateOfBirthWithError(nil)
        
        if DOB != nil {
            let calendar = NSCalendar.currentCalendar()
            let ageComponents = calendar.components(.CalendarUnitYear,
                fromDate: DOB!,
                toDate: NSDate(),
                options: nil)
            let age = ageComponents.year
            
            return age
        }
        
        else {
            return nil
        }
    }
}