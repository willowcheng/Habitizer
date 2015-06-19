//
//  NewHabitViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData

class NewHabitViewController: UIViewController {

    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    @IBOutlet weak var habitTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var todaysDate: NSDate = NSDate()
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .NoStyle
        var dateInFormat: String = dateFormatter.stringFromDate(todaysDate)
        println(dateInFormat)
        var timeFormatter: NSDateFormatter = NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = .ShortStyle
        var timeInFormat: String = timeFormatter.stringFromDate(todaysDate)
        println(timeInFormat)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func confirmNewHabitButtonPressed(sender: AnyObject) {
        if habitTextField.text.isEmpty {
            var alert = UIAlertController(title: nil, message: NSLocalizedString("TYPE_YOUR_NEW_HABIT", comment: "Type your new habit"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            createHabit(habitTextField.text)
        }

    }

    @IBAction func cancelButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
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
