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
                println("User has exited consent form. Consented: \(consented)")
                self.consented = true
                println("User has exited consent form. Consented: \(consented)")
                
                taskViewController.dismissViewControllerAnimated(true, completion: authHealthkit)
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
                
                recentHappiness.text = String(thisResult)
                
                let newItem = NSEntityDescription.insertNewObjectForEntityForName("Result", inManagedObjectContext: self.context!) as! Result
                newItem.date = NSDate()
                newItem.surveyResult = thisResult
                
                println("\(newItem.date): \(newItem.surveyResult)")
                taskViewController.dismissViewControllerAnimated(true, completion: nil)
                updateDistance()
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
    
    
    var manager = HealthManager()
    
    func updateDistance() {
        manager.thisWeekSteps() {
            query, results, error in
            
            if error != nil {
                return
            }
            self.recentDistance.text = "\(Int(results.statistics()[0].sumQuantity().doubleValueForUnit(HKUnit.countUnit())))"
            
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
            
//            if let path = NSBundle.mainBundle().pathForResource("ConsentStatus", ofType: "plist") {
//                    if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, Bool> {
//                        
//                        var newDict = dict
//                        newDict["Consented"] = consented
//                        
//                        ([newDict] as NSArray).writeToFile(path, atomically: false)
//                        println("Saved successfully.")
//                    
//                    
//                }
//            }
        }
    }
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    func authHealthkit() {
        
        let authStatus = manager.store.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning))
        
        switch authStatus {
        case .SharingAuthorized:
            return
            
        case .NotDetermined:
            println("Not determined")
            
            println("Trying to authorise...")
            manager.authoriseHK { (success,  error) -> Void in
                
                if success {
                    return
                }
                else {
                    println("HealthKit authorization denied!")
                        var HKwarning = UIAlertController(title: "HealthKit Authorisation", message: "You must authorise HealthKit to continue.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        HKwarning.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        self.presentViewController(HKwarning, animated: true, completion: nil)
                        self.HKCheck.text = "You must authorize HealthKit before you can take a survey."
                
                }
            }
            
        case .SharingDenied:
            
            return
            
        }

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        HKCheck.lineBreakMode = .ByWordWrapping
        HKCheck.numberOfLines = 0
        
        updateDistance()
        
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
        let save = NSDictionary(contentsOfFile: path)
        
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


}

