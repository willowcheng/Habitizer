//
//  ViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    @IBOutlet weak var habitTargetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDatabase() {
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
        
        var error: NSError? = nil
        habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
        for habit in habits {
            println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved)")
        }
        if error != nil {
            println("An error occurred loading the data")
        }
    }

}

