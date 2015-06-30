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
import SwiftyUserDefaults


class MainViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: -IBOutlet
    
    @IBOutlet weak var remainLabel: SpringLabel!
    @IBOutlet weak var transitionButton:SpringButton!
    @IBOutlet weak var achievedHabitButton: UIButton!
    @IBOutlet weak var habitTargetLabel: SpringLabel!
    @IBOutlet weak var remainDaysLabel: SpringLabel!
    @IBOutlet weak var failButton: SpringButton!
    @IBOutlet weak var succeedButton: SpringButton!

    
    // MARK: - 变量
    
    let transition = BubbleTransition()
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    var remainDays = 0
    var progressLimit = 255
    var circularProgress: KYCircularProgress!
    var progress = 3
    var ongoingHabit: Bool = false {
        didSet {
            if !ongoingHabit {
                remainLabel.text = "In next"
                habitTargetLabel.text = "Start raising a good habit today!"
                remainDaysLabel.text = "21"
                remainDays = 21
                
                //第一次运行程序,只显示添加习惯按钮, 隐藏fail, succeed和achieved按钮
                transitionButton.hidden = false
                failButton.hidden = true
                succeedButton.hidden = true
            } else {
                remainLabel.text = "Remain"
                transitionButton.hidden = true
                failButton.hidden = false
                succeedButton.hidden = false
            }
        }
    }
    
    // MARK: - VC 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 天数数字向上动画效果
        remainDaysLabel.animation = "slideDown"
        remainDaysLabel.curve = "spring"
        remainDaysLabel.animate()
        
        addShadow(succeedButton, failButton, transitionButton, achievedHabitButton)
        
        
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
            if(progress == 0 || progress == 1) {
                self.remainDaysLabel.text = "21"
            } else {
                self.remainDaysLabel.text = "\(20 - Int(progress * 21.0))"
            }
            
        })
        
        // 进度圈向下动画效果
        circularProgress.animation = "fadeInUp"
        circularProgress.curve = "spring"
        circularProgress.animate()
        
        self.view.bringSubviewToFront(achievedHabitButton)
        
        loadDatabase()
        
        
        NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadDatabase()
    }
    
    // MARK: - 加载数据库
    
    func loadDatabase() {
        
        if (Defaults.hasKey("habit_ongoing")) {
            ongoingHabit = true
            
            let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
            var error: NSError? = nil
            habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
            
            for habit in habits {
                println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved), remain days: \(habit.remainDays)")
                habitTargetLabel.text = habit.content
                remainDays = Int(habit.remainDays)
                circularDaysAnimation()
            }
            
            if error != nil {
                println("An error occurred loading the data")
            }
            
        } else {
            ongoingHabit = false
            circularDaysAnimation()
        }
        
        if(habits.count > 0) {
            achievedHabitButton.hidden = false
        } else {
            achievedHabitButton.hidden = true
        }
        
        
    }
    
    @IBAction func succeedButtonPressed(sender: AnyObject) {
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
        var error: NSError? = nil
        habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
        
        if (habits.last!.remainDays > 1) {
            habits.last!.remainDays -= 1
        } else {
            habits.last!.achieved = true
            Defaults.remove("habit_ongoing")
            
            transitionButton.animation = "fadeIn"
            transitionButton.curve = "spring"
            transitionButton.animate()
        }
        
        self.managedObjectContext?.save(nil)
        loadDatabase()
        
    }
    
    @IBAction func failButtonPressed(sender: AnyObject) {
        Defaults.remove("habit_ongoing")
        ongoingHabit = false
        
        transitionButton.animation = "fadeIn"
        transitionButton.curve = "spring"
        transitionButton.animate()
    }
    
    // MARK: - 显示进度圈加载进度效果
    
    func updateProgress() {
        // Timer调用的累加计数器
        
        if (ongoingHabit) {
            if(progress < progressLimit) {
                progress = progress + 1
                println(progress)
                circularProgress.progress = Double(progress) / 255.0
            }
        } else {
            if(progress > 0) {
                progress = progress - 1
                println(progress)
                circularProgress.progress = Double(progress) / 255.0
            }
        }
        
        if (progress == 0) {
            remainDaysLabel.text = "21"
        }


    }
    
    func circularDaysAnimation() {
        progressLimit = (21 - remainDays) * 255 / 21
    }
    
    // MARK: - 自定义Segue动画效果
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if(presented.isKindOfClass(NewHabitViewController)) {
            println("NewHabitViewController")
            transition.transitionMode = .Present
            transition.startingPoint = transitionButton.center
            transition.bubbleColor = transitionButton.backgroundColor!
        } else if(presented.isKindOfClass(HabitCollectionViewController)) {
            println("HabitCollectionViewController")
            transition.transitionMode = .Present
            transition.startingPoint = achievedHabitButton.center
            transition.bubbleColor = UIColor.whiteColor()
        }
        
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if(dismissed.isKindOfClass(NewHabitViewController)) {
            println("NewHabitViewController")
            transition.transitionMode = .Dismiss
            transition.startingPoint = transitionButton.center
            transition.bubbleColor = transitionButton.backgroundColor!
            
            if(Defaults["habit_ongoing"].bool == true) {
                // Transition Button Dismiss时重载数据库及部分动画效果
                progress = 0
                transitionButton.animation = "fadeOut"
                transitionButton.curve = "spring"
                transitionButton.delay = 0.2
                transitionButton.animate()
                loadDatabase()
                remainDaysLabel.animation = "pop"
                remainDaysLabel.delay = 0.5
                remainDaysLabel.curve = "spring"
                remainDaysLabel.animate()
                habitTargetLabel.animation = "pop"
                habitTargetLabel.delay = 0.5
                habitTargetLabel.curve = "spring"
                habitTargetLabel.animate()
            }
        } else if (dismissed.isKindOfClass(HabitCollectionViewController)) {
            println("HabitCollectionViewController")
            transition.transitionMode = .Dismiss
            transition.startingPoint = achievedHabitButton.center
            transition.bubbleColor = UIColor.whiteColor()
        }
        return transition
    }
}