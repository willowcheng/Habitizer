//
//  ViewController.swift
//  JGTransitionCollectionView
//
//  Created by Jay on 23/03/15.
//  Copyright (c) 2015 Jay. All rights reserved.
//

import UIKit
import CoreData

class HabitCollectionViewController: UIViewController , JGTransitionCollectionViewDatasource {
    
    let cellColorStringArray = ["#23D3EC", "#0ED0EB", "#6D8EF0", "#5B80EF", "#FFCE63", "#FFC74D", "#FFAE63", "#FFA24D"]
    
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var collView: JGTransitionCollectionView!
    var dataSource : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.collView.settDataArray(self.dataSource)
        self.collView.jgDatasource = self
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //设置每个Cell里有什么
        var cell: JGCustomCell  = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! JGCustomCell;
        var dataDict = self.dataSource.objectAtIndex(indexPath.row) as! NSDictionary
        cell.contentView.backgroundColor = dataDict["color"] as? UIColor
//        cell.backgroundImage.image = UIImage(named: NSString(format: "car%d", indexPath.row+1) as String)
        cell.habitTextLabel.text = dataDict["text"] as? String
        return cell;
    }
    
    //MARK : Helpers
    func loadData(){
        //!!!: JGTransitionLayout 需要修改第83行适应显示页面长度 : var height = self.itemSize.height * CGFloat(itemCount! / 2 + 1)
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
        
        var error: NSError? = nil
        habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
        
        var color: String
        
        for habit in habits {
            color = cellColorStringArray[Int(arc4random_uniform(8))]
            println(color)
            self.dataSource.addObject(NSDictionary(objectsAndKeys: UIColor().colorWithHex(color), "color", "\(habit.content)", "text"))
            println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved), remain days: \(habit.remainDays)")
        }
    }
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

