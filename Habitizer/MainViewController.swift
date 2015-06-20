//
//  ViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData


class MainViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let transition = BubbleTransition()
    
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var transitionButton: UIButton!
    @IBOutlet weak var habitTargetLabel: UILabel!
    @IBOutlet weak var remainDaysLabel: UILabel!
    var remainDays = 0
    var progressLimit = 255
    
    var circularProgress: KYCircularProgress!
    var progress = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("ViewDidLoad")
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()

        
        let circularProgressFrame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2)
        circularProgress = KYCircularProgress(frame: circularProgressFrame)
        
        let center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        circularProgress.path = UIBezierPath(arcCenter: center, radius: CGFloat(CGRectGetWidth(circularProgress.frame)/3), startAngle: CGFloat(M_PI), endAngle: CGFloat(0.0), clockwise: true)
        circularProgress.colors = [UIColor.whiteColor(), UIColor.orangeColor()]
        circularProgress.lineWidth = 10.0
        circularProgress.showProgressGuide = true
        circularProgress.progressGuideColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2)
        
        circularProgress.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in
            self.remainDaysLabel.text = "\(20 - Int(progress * 21.0))"
        })
        
        view.addSubview(circularProgress)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadDatabase()
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        loadDatabase()
        return transition
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
        }
    }

    
    func loadDatabase() {
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
        
        var error: NSError? = nil
        habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
        for habit in habits {
            println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved), remain days: \(habit.remainDays)")
            habitTargetLabel.text = habit.content
//            remainDays = Int(habit.remainDays)
            remainDays = 5
                circularDaysAnimation()
        }
        if error != nil {
            println("An error occurred loading the data")
        }
    }
    
    func updateProgress() {
        if(progress < progressLimit) {
                progress = progress + 1
        } else {
            return
        }
        circularProgress.progress = Double(progress) / 255.0

    }
    
    func circularDaysAnimation() {
        progressLimit = (21 - remainDays) * 255 / 21
        NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }

}

