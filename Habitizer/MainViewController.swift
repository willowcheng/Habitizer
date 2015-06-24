//
//  ViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import CoreData
import Spring


class MainViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let transition = BubbleTransition()
    
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var remainLabel: SpringLabel!
    @IBOutlet weak var transitionButton: UIButton!
    @IBOutlet weak var habitTargetLabel: SpringLabel!
    @IBOutlet weak var remainDaysLabel: SpringLabel!
    var remainDays = 0
    var progressLimit = 255
    
    var circularProgress: KYCircularProgress!
    var progress = 0
    
    //TODO: 使用UserDefaults存储当前习惯是否正在进行
    //用来记录是否有进行中的习惯
    var ongoingHabit: Bool = false {
        didSet {
            if !ongoingHabit {
                remainLabel.text = "In next"
            } else {
                remainLabel.text = "Remain"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remainDaysLabel.animation = "slideDown"
        remainDaysLabel.curve = "spring"
        remainDaysLabel.animate()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()

        let circularProgressFrame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2)
        circularProgress = KYCircularProgress(frame: circularProgressFrame)
        
        let center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        circularProgress.path = UIBezierPath(arcCenter: center, radius: CGFloat(CGRectGetWidth(circularProgress.frame)/3), startAngle: CGFloat(M_PI), endAngle: CGFloat(0.0), clockwise: true)
        println("\(UIColor.orangeColor())")
        circularProgress.colors = [UIColor.whiteColor(), UIColorFromRGB(0x2DF79F)]
        circularProgress.lineWidth = 5.0
        circularProgress.showProgressGuide = true
        circularProgress.progressGuideColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2)
        view.addSubview(circularProgress)
        circularProgress.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in
            self.remainDaysLabel.text = "\(20 - Int(progress * 21.0))"
        })

        //这两行代码不知道加在哪合适.........
        circularProgress.animation = "fadeInUp"
        circularProgress.curve = "spring"
        circularProgress.animate()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // 载入数据库
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
        // Transition Button Dismiss时重载数据库及部分动画效果
        progress = 0
        loadDatabase()
        println("Transition button dismiss")
        if (ongoingHabit) {
            println("Label animation")
            remainDaysLabel.animation = "pop"
            remainDaysLabel.delay = 0.5
            remainDaysLabel.curve = "spring"
            remainDaysLabel.animate()
            habitTargetLabel.animation = "pop"
            habitTargetLabel.delay = 0.5
            habitTargetLabel.curve = "spring"
            habitTargetLabel.animate()
        }
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
        
        if habits.count == 0 {
            ongoingHabit = false
        } else {
            ongoingHabit = true
            for habit in habits {
                println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved), remain days: \(habit.remainDays)")
                habitTargetLabel.text = habit.content
                remainDays = Int(habit.remainDays)
//                remainDays = 5
                circularDaysAnimation()
            }
        }


        if error != nil {
            println("An error occurred loading the data")
        }
    }
    
    func updateProgress() {
        // Timer调用的累加计数器
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

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

