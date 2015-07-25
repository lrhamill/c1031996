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
                return

            }
 
            // Otherwise, if the user has come from the survey task,
            // submit the results
            
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
                
                let success = transmitJSON(thisResult)
                
                if !success {
                    
                    let serverFail = UIAlertController(title: "Unable to send", message: "The app was unable to reach the server. Your internet connection may be unstable, or the server may be down. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    serverFail.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(serverFail, animated: true, completion: nil)
                    
                    return
                    
                }
                
                // Set nextDate for survey
                
                let calendar = NSCalendar.currentCalendar()
                
                let components = calendar.components(NSCalendarUnit.CalendarUnitYear |
                    NSCalendarUnit.CalendarUnitMonth |
                    NSCalendarUnit.CalendarUnitDay |
                    NSCalendarUnit.CalendarUnitHour |
                    NSCalendarUnit.CalendarUnitMinute |
                    NSCalendarUnit.CalendarUnitSecond,
                    fromDate: NSDate()
                )
                
                components.day++
                components.hour = 16
                components.minute = 0
                components.second = 0
                
                println(calendar.dateFromComponents(components))
                nextDate = calendar.dateFromComponents(components)
                
                println(nextDate)
                
                var localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertAction = "Complete a survey."
                localNotification.alertBody = "Launch c1031996 to fill in your next survey."
                localNotification.fireDate = nextDate!
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                
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

    @IBOutlet weak var nextSurvey: UILabel!
    
    var stepCount: Int?
    var cycleDistance: Int?
    var energyConsumed: Int?
    var basalEnergyBurned: Int?
    var activeEnergyBurned: Int?
    var sleep: Int?
    
    var bioSex: String?
    var age: Int?
    var BMI: Double?
    
    var nextDate: NSDate? {
        didSet {
            
            if nextDate == nil { return }
            
            // Save next date
            
            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            var path = paths.stringByAppendingPathComponent("ConsentStatus.plist")
            var fileManager = NSFileManager.defaultManager()
            if (!(fileManager.fileExistsAtPath(path))) {
                var bundle : String = NSBundle.mainBundle().pathForResource("ConsentStatus", ofType: "plist")!
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
            var data : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
            data.setObject(nextDate!, forKey: "NextSurvey")
            data.writeToFile(path, atomically: true)
            
            // Update UILabel
            
            nextSurvey.text! = "Next survey: \(humanReadableNextDate!)"
            
        }

    }
    
    var humanReadableNextDate: String? {
        
        // More readable date format
        
        if nextDate == nil {
            return nil
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(nextDate!)
    }
    
    var manager = HealthManager()
    
    // Code block that can be passed to HealthManager.weeklyQuantitySum to print results.
    // Used for debugging.
    var printQuantitySum: (query: HKStatisticsCollectionQuery!, results: HKStatisticsCollection!, error: NSError!) -> Void = {
        
        (query, results, error) in
        if results.statistics().isEmpty {
            
            println("No value")
            
        } else {
            
            println("\(Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit())))")
        }
        
    }
    
    func updateDistance() {
       
        let quantityTypes = [
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            
        ]
        
            
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
        
        // Legacy code...
        // possible use for debugging, necessary if you want to write to HK in future
        
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
        
        authHealthkit()
        
        if nextDate == nil || nextDate!.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            nextSurvey.text! = "Survey ready!"
        } else {
            nextSurvey.text! = "Next survey: \(humanReadableNextDate!)"
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Initialise
        super.viewDidAppear(animated)
        
        // Check saved data
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("ConsentStatus.plist")
        
        // Extract consent history
        
        if let save = NSDictionary(contentsOfFile: path) {
            consented = save["Consented"] as! Bool
            nextDate = save["NextSurvey"] as? NSDate
        }
        
        if !consented {
            
            println(consented)
            launchConsent()
            
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
        
        if nextDate != nil {
            let date = NSDate()
            
            if nextDate!.compare(date) == NSComparisonResult.OrderedDescending {
                
                let tooEarly = UIAlertController(title: "Try Later", message: "You have already completed the task for today. Come back at 4PM or later the day after you complete the task.", preferredStyle: UIAlertControllerStyle.Alert)
                
                tooEarly.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in return } ))
                
                self.presentViewController(tooEarly, animated: true, completion: nil)
                
                return
            }
        }
        
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

    func transmitJSON (happiness: Int) -> Bool {

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
        
        var formatDate: String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.stringFromDate(NSDate())
        }
        
        // Construct JSON
        
        let jsonString = "{\"ID\": \"\(UIDevice.currentDevice().identifierForVendor.UUIDString)\", \"Date\": \"\(formatDate)\", \"Steps\": \(processedValues[0]), \"Cycle\": \(processedValues[1]), \"EnergyIn\": \(processedValues[2]), \"BasalEnergy\": \(processedValues[3]), \"ActiveEnergy\": \(processedValues[4]), \"Sleep\": \(processedValues[5]), \"Age\": \(processedValues[6]), \"Sex\": \"\(processedValues[7])\", \"BMI\": \(processedValues[8]), \"Happiness\": \(happiness)}"
        
        
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
            
            if httpResponse.statusCode != 200 {
                return false
            } else {
                return true
            }
            
        } else {
            println("No HTTP response")
            return false
        }
        
        
    }
    
}

