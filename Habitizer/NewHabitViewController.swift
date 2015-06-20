//
//  NewHabitViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData

class NewHabitViewController: UIViewController, UITextFieldDelegate {

    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    @IBOutlet weak var habitTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        habitTextField.delegate = self
        
        var todaysDate: NSDate = NSDate()
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .NoStyle
        var dateInFormat: String = dateFormatter.stringFromDate(todaysDate)
        currentDateLabel.text = dateInFormat
        var timeFormatter: NSDateFormatter = NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = .ShortStyle
        var timeInFormat: String = timeFormatter.stringFromDate(todaysDate)
        currentTimeLabel.text = timeInFormat
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    @IBAction func closeAction(sender: UIButton) {
        if(habitTextField.text.isEmpty) {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            createHabit(habitTextField.text)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        habitTextField.resignFirstResponder()
        return true
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        habitTextField.resignFirstResponder()
    }
    
    func createHabit(content: String) {
        let entityDescription =
        NSEntityDescription.entityForName("Habits",
            inManagedObjectContext: managedObjectContext!)
        
        let habit = Habits(entity: entityDescription!,
            insertIntoManagedObjectContext: managedObjectContext)
        
        habit.content = content
        habit.createdAt = NSDate()
        habit.achieved = false
        habit.remainDays = 20
        
        var error: NSError?
        
        managedObjectContext?.save(&error)
        
        if let err = error {
            var alert = UIAlertController(title: nil, message: err.localizedFailureReason, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            var newHabitNotification: UILocalNotification = UILocalNotification()
            newHabitNotification.category = "NEW_HABIT_CATEGORY"
            var notificationHead: String = NSLocalizedString("NEW_HABIT_ADD", comment: "New habit add") as String
            newHabitNotification.alertBody = "\(notificationHead)\(habitTextField.text.lowercaseString)"
            newHabitNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
            
            UIApplication.sharedApplication().scheduleLocalNotification(newHabitNotification)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    

}
