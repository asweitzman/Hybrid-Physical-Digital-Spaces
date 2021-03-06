//
//  ViewController.swift
//  HPDS-Data
//
//  Created by Michael Cooper on 2018-07-12.
//  Copyright © 2018 Michael Cooper. All rights reserved.
//

import UIKit
import AWAREFramework
import ResearchKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Hides the default parent level navigation bar upon navigating to a child screen
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     * Action: syncSensors
     * Description: Syncs all AWARE sensors with the AWARE server.
     */
    @IBAction func syncSensors(_ sender: Any) {
        //Pull in the sensorManager from our AppDelegate file.
        let sensorManager = AppDelegate.shared().manager!
        //Sync the sensor data with the AWARE server.
        sensorManager.syncAllSensors()
    }
    
    /*
     * Action: openEmail
     * Description: Opens the user's default email client, and an email within
     * the client addressed to the email address below.
     */
    @IBAction func openEmail(_ sender: Any) {
        let email = "foo@bar.com" // To be updated with real contact info
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /*
     * Action: researchKitSurvey
     * Description: Opens the ResearchKit Survey in the "SurveyTask.swift" file; runs
     * the survey.
     */
    @IBAction func researchKitSurvey(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
        taskViewController.delegate = (self as! ORKTaskViewControllerDelegate)
        present(taskViewController, animated: true, completion: nil)
        

        
    }
    
}

/*
 * Extension:    ViewController : ORKTaskViewControllerDelegate
 * Description: extends he current ViewController to implement the taskViewController delegate
 * method. This is necessary to allow the ViewController to support ResearchKit surveys.
 */
extension ViewController : ORKTaskViewControllerDelegate {
    
    func jsonToNSDictionary(jsonstring: String) -> NSDictionary {
        //Converts a JSON string to an NSDictionary
        
        var dict: NSDictionary?
        
        if let data = jsonstring.data(using: String.Encoding.utf8) {
            
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as? NSDictionary
                
                if let myDictionary = dict
                {
                    return myDictionary
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return dict!
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        //Serializes the survey result into a JSON.
        let taskResult = taskViewController.result
        
        let jsonData = try! ORKESerializer.jsonData(for: taskResult)
        if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
            //Converts the JSON to a dictionary
            print(jsonToNSDictionary(jsonstring: jsonString as String))
            
            let rkSensor = AppDelegate.shared().rk!
            rkSensor.startSensor()
            //The goal: something like syncESMWithAWARE(jsonToNSDictionary(jsonstring: jsonString as String)
        }
        else {
            print("Failure - could not serialize ORKResult to JSON.")
        }
        
        taskViewController.dismiss(animated: true, completion: nil)
    }
}
