//
//  HealthManager.swift
//  Gatherer
//
//  Created by Liam Hamill on 16/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

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

    var retrievedData: [String: [Int?]] = ["steps": [], "cycle": [], "sleep": [], "happiness": []]
    
    func retrieveData () {
        
        // Retrieves all data types from the server
        
        for (key, value) in retrievedData {
            
            let target: NSString = "https://project.cs.cf.ac.uk/HamillLR/mysqli_retrieval.php?Type=\(key)&ID=6497797F-0F65-467A-977D-9D7AFA83A55B"
            
//            let target: NSString = "https://project.cs.cf.ac.uk/HamillLR/mysqli_retrieval.php?Type=\(key)&ID=\(UIDevice.currentDevice().identifierForVendor.UUIDString)"
            let URLtarget = target.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let requestURL = NSURL(string: URLtarget)
            
            var request = NSMutableURLRequest(URL: requestURL!)
            request.HTTPMethod = "GET"
            
            let username = "c1031996"
            let password = "Jumbles12"
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
            
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                
                data, response, err in
                
                if ( err != nil ) {
                    
                    println(err?.description)
                
                } else {
                    
                    if let httpResponse = response as? NSHTTPURLResponse {
                        println("HTTP response: \(httpResponse.statusCode)")
                    }
                    
                    var jsonResult: NSArray? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
                    
                    for obj in jsonResult! {
                        
                        if var result = obj.integerValue {
                            self.retrievedData[key]?.append(result)
                        } else {
                            self.retrievedData[key]?.append(nil)
                        }
                    }
                    
                    println(self.retrievedData)
                    
                }
                
            }
            
            task.resume()
        
        }
            
            
    }
    
    func dataForGraph(dataType: String) -> [String: [Int]] {
        
        let validTypes: Set<String> = ["steps", "cycle", "sleep"]
        var returnDict: Dictionary<String, [Int]> = [:]
        
        if !validTypes.contains(dataType) {
            
            // Invalid input, abort
            return returnDict
            
        }
        
        var hapArr = [Int]()
        var DVArr = [Int]()
        
        let arr = retrievedData[dataType]!
        
        
        var i = 0
        
        while i < arr.count {
            
            if let val: Int = arr[i] {
                if let happiness: Int = retrievedData["happiness"]![i] {

                    hapArr.append(happiness)
                    DVArr.append(val)
                }
            }
            
            returnDict["happiness"] = hapArr
            returnDict[dataType] = DVArr
            
            i++
            
        }
        
        println(returnDict)
        return returnDict
    }
    
    func authoriseHK(completion: ((success:Bool, error:NSError!) -> Void)!) {

        // Authorises HealthKit
        
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
    
    func dailyQuantitySum(sampleType: HKQuantityType!, completion: ((HKStatisticsQuery!, HKStatistics!, NSError!) -> Void)!) {
        
        // Get dates for this week
        let calendar = NSCalendar()
        let today = NSDate()
        let yesterday = today.dateByAddingTimeInterval(-24 * 60 * 60)
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(yesterday,
            endDate: today, options: .StrictStartDate)
        
        // Run query
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum, completionHandler: completion)
        
        store.executeQuery(query)
        
    }
    
    func getBMI(completion: ((HKSampleQuery!, [AnyObject]!, NSError!) -> Void)!) {

        
        // Build predictae
        let past = NSDate.distantPast() as! NSDate
        let today = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: today, options: .None)
        
        // Interested only in the most recent value
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        
        // Build query
        let BMIQuery = HKSampleQuery(sampleType: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor], resultsHandler: completion)
        
        store.executeQuery(BMIQuery)
    }
    
    func dailySleepAnalysis(completion: ((HKSampleQuery!, [AnyObject]!, NSError!) -> Void)!) {
        
        var totalSleep: Int?
    
        let today = NSDate()
        let yesterday = today.dateByAddingTimeInterval(-24 * 60 * 60)
        
        let sleepType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
        
        // creating a compound predicate for searching
        
        let timePredicate = HKQuery.predicateForSamplesWithStartDate(yesterday, endDate: today, options: .None)
        
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