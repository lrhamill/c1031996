//
//  ViewController.swift
//  Gatherer
//
//  Created by Liam Hamill on 04/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import UIKit
import ResearchKit
import CoreData


extension ViewController : ORKTaskViewControllerDelegate {


    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        //Handle results with taskViewController.result
        
        
        switch reason {
        
        case .Completed:
            
            
            // If the user has come from the consent form, update consent info & HK authentication
            if !self.consented {
                self.consented = true
                
                taskViewController.dismissViewControllerAnimated(true, completion: nil)
//                authHealthkit()
                return

            }

            
        
            // Otherwise, if the user has come from the survey task,
            // save the results using Core Data
            
            if let resultArray = taskViewController.result.results {
                
                var thisResult = 0
                for item in resultArray {
                    let results = item.results as! [ORKChoiceQuestionResult]
                    
                    if results.count > 0 {
                        if let answer = results[0].choiceAnswers as? [Int] {
                            thisResult += answer[0]
                        }
                    }
                }
                
                transmitJSON(thisResult)
                
                recentHappiness.text = String(thisResult)
                
                let newItem = NSEntityDescription.insertNewObjectForEntityForName("Result", inManagedObjectContext: self.context!) as! Result
                newItem.date = NSDate()
                newItem.surveyResult = thisResult
                
                println("\(newItem.date): \(newItem.surveyResult)")
                taskViewController.dismissViewControllerAnimated(true, completion: nil)
            }

            
        default:
            // Exit without saving
            
            taskViewController.dismissViewControllerAnimated(true, completion: nil)
            return
            
        }
        
    }
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var HKCheck: UILabel!
    
    @IBOutlet weak var recentDistance: UILabel!
    
    @IBOutlet weak var recentHappiness: UILabel!
//    @IBOutlet weak var withdraw: UIButton!
    
    var stepCount: Int?
    var cycleDistance: Int?
    var energyConsumed: Int?
    var basalEnergyBurned: Int?
    var activeEnergyBurned: Int?
    var sleep: Int?
    
    var bioSex: String?
    var age: Int?
    var BMI: Double?
    
    
    
    var printQuantitySum: (query: HKStatisticsCollectionQuery!, results: HKStatisticsCollection!, error: NSError!) -> Void = {
        
        (query, results, error) in
        if results.statistics().isEmpty {
            
            println("No value")
            
        } else {
            
            
            
            println("\(Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit())))")
        }
        
    }
    
    var manager = HealthManager()
    
    func updateDistance() {
       
        let quantityTypes = [
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            
        ]
        
        manager.weeklyQuantitySum(quantityTypes[0]) {
            query, results, error in
            
            if error != nil {
                return
            }
            self.recentDistance.text = "\(Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit())))"
        }
            
        for item in quantityTypes {
            self.manager.weeklyQuantitySum(item) {
                (query, results, error) in
                
                switch item {
                    
                case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!:
                    if results.statistics().isEmpty {
                        
                        self.stepCount = nil
                        println("No value")
                        
                    } else {

                        self.stepCount = Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
                        println("Step count: \(self.stepCount!)")
                    }
                
                case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!:
                    
                    if results.statistics().isEmpty {
                        
                        self.cycleDistance = nil
                        println("Cycling: No value")
                        
                    } else {
                        
                        self.cycleDistance = Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
                        println("Step count: \(self.cycleDistance!)")
            
                    }
                case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!:
                    
                    if results.statistics().isEmpty {
                        
                        self.energyConsumed = nil
                        println("Energy consumed: No value")
                        
                    } else {
                        
                        self.energyConsumed = Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
                        println("Energy consumed: \(self.energyConsumed!)")
                        
                    }
                
                case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!:
                    
                    if results.statistics().isEmpty {
                        
                        self.basalEnergyBurned = nil
                        println("Basal energy burned: No value")
                        
                    } else {
                        
                        self.basalEnergyBurned = Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
                        println("Basal energy burned: \(self.basalEnergyBurned!)")
                        
                    }
                
                case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!:
                    
                    if results.statistics().isEmpty {
                        
                        self.activeEnergyBurned = nil
                        println("Active energy burned: No value")
                        
                    } else {
                        
                        self.activeEnergyBurned = Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
                        println("Active energy burned: \(self.activeEnergyBurned!)")
                        
                    }
                default:
                    println("Type not recognised")
                }
            }
        }
        
        self.manager.weeklySleepAnalysis() {
            query, results, error in
            
            if error != nil {
                println("Error accessing sleep data")
                return
            }
            
            if results.isEmpty {
                println("No sleep data found")
                return
            }
            
            self.sleep = 0
            
            for item in results {
                
                let duration = item.endDate!!.timeIntervalSinceDate(item.startDate!!)
                
                self.sleep! += Int(duration)

            }
            
            println("Sleep: \(self.sleep!)")
        }
        
        bioSex = manager.biologicalSex()
        
        if bioSex != nil {
            println("Biological sex: \(bioSex!)")
        } else {
            println("Biological sex: not set.")
        }
        
        age = manager.age()
        
        if age != nil {
            println("Age: \(age!)")
        } else {
            println("Age: Unknown")
        }
        
        manager.getBMI() {
            (query, results, error) in
            
            if results.isEmpty {
                self.BMI = nil
                println("BMI: No data")
            } else {
                self.BMI = results.first!.quantity!.doubleValueForUnit(HKUnit.countUnit())
                println("BMI: \(self.BMI!)")
            }
        }
    }
    
    var consented = false {
        didSet {
            
            println("Consented: \(consented)")
            
            // Save changes to consented status
            
            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            var path = paths.stringByAppendingPathComponent("ConsentStatus.plist")
            var fileManager = NSFileManager.defaultManager()
            if (!(fileManager.fileExistsAtPath(path))) {
                var bundle : String = NSBundle.mainBundle().pathForResource("ConsentStatus", ofType: "plist")!
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
            var data : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
            data.setObject(consented, forKey: "Consented")
            data.writeToFile(path, atomically: true)
            
        }
    }
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    func authHealthkit() {

        println("Not determined")
        
        println("Trying to authorise...")
        manager.authoriseHK { (success,  error) -> Void in
            
            if success {
                return
            }
            else {
                println("HealthKit authorization denied!")
            
            }
        }

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        HKCheck.lineBreakMode = .ByWordWrapping
        HKCheck.numberOfLines = 0
        
        authHealthkit()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if let path = NSBundle.mainBundle().pathForResource("ConsentStatus", ofType: "plist") {
//            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
//                
//                let plist = dict["Consented"] as! Bool
//                println("plist says: \(plist)")
//                
//                consented = dict["Consented"] as! Bool
//                
//            }
//        }

        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("ConsentStatus.plist")
        if let save = NSDictionary(contentsOfFile: path) {
            consented = save["Consented"] as! Bool
        }
        
        if !consented {
            
            println(consented)
            launchConsent()
            
        }
        
        // Create a new fetch request
        let fetchRequest = NSFetchRequest(entityName: "Result")
        
        // Cast the results to an array
        if let fetchResults = context!.executeFetchRequest(fetchRequest, error: nil) as? [Result] {
                //TODO: handle saved results
        }
    }
    
    func launchConsent() {
        
        println("Launch consent: \(consented)")
        var userConsent = ConsentTask
        let taskViewController = ORKTaskViewController(task: userConsent, taskRunUUID: nil)
        taskViewController.delegate = self
        presentViewController(taskViewController, animated: true, completion: nil)

    }
    
    
    @IBAction func surveyTapped(sender : AnyObject) {
        
        updateDistance()
        
        let taskViewController = ORKTaskViewController(task: SurveyTask, taskRunUUID: nil)
        taskViewController.delegate = self
        presentViewController(taskViewController, animated: true, completion: nil)
    }

    @IBAction func withdrawTapped(sender : AnyObject) {
        
        var warning = UIAlertController(title: "Withdrawing consent", message: "Are you sure you want to withdraw from the study?", preferredStyle: UIAlertControllerStyle.Alert)
        
        warning.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        
        warning.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                self.consented = false
                self.launchConsent()
        
            default:
                println("cancel")

            }
        }))
        
        self.presentViewController(warning, animated: true, completion: nil)

    }

    func transmitJSON (happiness: Int) {
        // updateDistance()
        
//        var stepCount: Int?
//        var cycleDistance: Int?
//        var energyConsumed: Int?
//        var basalEnergyBurned: Int?
//        var activeEnergyBurned: Int?
//        var sleep: Int?
//        
//        var bioSex: String?
//        var age: Int?
//        var BMI: Double?
        
        // Convert optionals into JSON-friendly format
        
        let arrayOfIntTypes = [stepCount, cycleDistance, energyConsumed, basalEnergyBurned, activeEnergyBurned, sleep, age]
        
        var processedValues = [String]()
        var jsonValues = [JSON]()
        let nullJSON = JSON("null")
        
        for item in arrayOfIntTypes {
            if item != nil {
                let curItem = JSON(item!)
                jsonValues.append(curItem)
                processedValues.append("\(item!)")
            } else {
                jsonValues.append(nullJSON)
                processedValues.append("null")
            }
        }
        
        if bioSex != nil {
            let sexJSON = JSON(bioSex!)
            jsonValues.append(sexJSON)
            processedValues.append("\(bioSex!)")
        } else {
            jsonValues.append(nullJSON)
            processedValues.append("null")
        }
        
        if BMI != nil {
            let BMIJSON = JSON(BMI!)
            jsonValues.append(BMIJSON)
            processedValues.append("\(BMI!)")
        } else {
            jsonValues.append(nullJSON)
            processedValues.append("null")
        }
        
        var jsonPacket: [AnyObject] = [
            ["ID": UIDevice.currentDevice().identifierForVendor.UUIDString, "Steps": processedValues[0], "Cycle": processedValues[1], "EnergyIn": processedValues[2], "BasalEnergy": processedValues[3], "ActiveEnergy": processedValues[4], "Sleep": processedValues[5]]
            ]
        
        var formatDate: String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.stringFromDate(NSDate())
        }
        
        let jsonString = "{\"ID\": \"\(UIDevice.currentDevice().identifierForVendor.UUIDString)\", \"Date\": \"\(formatDate)\", \"Steps\": \(processedValues[0]), \"Cycle\": \(processedValues[1]), \"EnergyIn\": \(processedValues[2]), \"BasalEnergy\": \(processedValues[3]), \"ActiveEnergy\": \(processedValues[4]), \"Sleep\": \(processedValues[5]), \"Age\": \(processedValues[6]), \"Sex\": \"\(processedValues[7])\", \"BMI\": \(processedValues[8]), \"Happiness\": \(happiness)}"
        
        let json: JSON = JSON(jsonString)
        
        

        println(json)
        println(json["Sleep"].intValue)
        println(json["ID"].stringValue)
        
        
        let url = "https://project.cs.cf.ac.uk/HamillLR/mysqli.php"
        let username = "c1031996"
        let password = "Jumbles12"
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        var response: NSURLResponse?
        var error: NSError?
        
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // send the request
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        // look at the response
        if let httpResponse = response as? NSHTTPURLResponse {
            println("HTTP response: \(httpResponse.statusCode)")
        } else {
            println("No HTTP response")
        }
        
        
    }
    
}

