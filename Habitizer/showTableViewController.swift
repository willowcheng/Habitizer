//
//  showTableViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-06-10.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData

// Declare that ViewController conforms to the UITableViewDataSource protocol
class showTableViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var habitsTableView: UITableView!

    // MARK: - Variables
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    
    // Model (datasource) for the table view
    var items = [NSManagedObject]()
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the UITableViewCell class with the tableView. Dequeue a cell with the reuse identifier
        habitsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        fetchData()
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Use subtitle style for UI table view cell
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        // Load items in database into list
        let item = items[indexPath.row]
        
        // Get content
        cell.textLabel!.text = item.valueForKey("content") as? String
        
        // Get date string
        var todaysDate = item.valueForKey("createdAt") as! NSDate
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var DateInFormat = dateFormatter.stringFromDate(todaysDate) as String
        println(DateInFormat)
        
        cell.detailTextLabel?.text = DateInFormat
//        cell.imageView?.image = UIImage(named: "AppIcon.jpg")

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            managedObjectContext?.deleteObject(items[indexPath.row] as! Habits)
            
            var error: NSError? = nil
            if !managedObjectContext!.save(&error) {
                println("Failed to delete the item \(error), \(error?.userInfo)")
            } else {
                items.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    // MARK: - Refactor functions
    
    func fetchData() {
        // Create a fetch request into Core Data
        let fetchRequest = NSFetchRequest(entityName: "Habits")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        //Execute the fetch request
        var error: NSError?
        
        if let fetchedResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]? {
            // Fetched results is not nil, update self.items
            items = fetchedResults
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        self.habitsTableView.reloadData()
        
    }


}
