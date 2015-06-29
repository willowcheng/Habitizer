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
    
    let transition = BubbleTransition()
    
    var habits : [Habits] = [Habits]()
    let managedObjectContext =
    (UIApplication.sharedApplication().delegate
        as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var remainLabel: SpringLabel!
    @IBOutlet weak var transitionButton:SpringButton!
    @IBOutlet weak var achievedHabitButton: UIButton!
    @IBOutlet weak var habitTargetLabel: SpringLabel!
    @IBOutlet weak var remainDaysLabel: SpringLabel!
    @IBOutlet weak var failButton: UIButton!
    @IBOutlet weak var succeedButton: UIButton!

    
    
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
                habitTargetLabel.text = "Start raising a good habit today!"
                remainDaysLabel.text = "21"
                
                //第一次运行程序,只显示添加习惯按钮,隐藏fail,succeed和achieved按钮
                transitionButton.hidden = false
                failButton.hidden = true
                succeedButton.hidden = true
                achievedHabitButton.hidden = true
            } else {
                remainLabel.text = "Remain"
                transitionButton.hidden = true
                failButton.hidden = false
                succeedButton.hidden = false
                achievedHabitButton.hidden = false
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
        
        self.view.bringSubviewToFront(achievedHabitButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        // 载入数据库
        loadDatabase()
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if let controller = segue.destinationViewController as? UIViewController {
                controller.transitioningDelegate = self
                controller.modalPresentationStyle = .Custom
            }
    }
    
    func loadDatabase() {
        
        if (Defaults["habit_ongoing"].bool == true) {
            ongoingHabit = true
        } else {
            ongoingHabit = false
        }
        
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Habits")
        
        var error: NSError? = nil
        habits = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Habits]
        
        for habit in habits {
            println("Content: \(habit.content), createdAt: \(habit.createdAt), achieved: \(habit.achieved), remain days: \(habit.remainDays)")
            habitTargetLabel.text = habit.content
            remainDays = Int(habit.remainDays)
            //                remainDays = 5
            circularDaysAnimation()
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
    
    @IBAction func statusButtonTapped(sender: UIButton) {
        switch sender {
        case succeedButton:
            UIView.transitionWithView(succeedButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.succeedButton.setImage(UIImage(named: "succeedChecked"), forState: .Normal)
                }, completion: nil)
            UIView.transitionWithView(failButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.failButton.setImage(UIImage(named: "fail"), forState: .Normal)
                }, completion: nil)
            
        case failButton:
            UIView.transitionWithView(failButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.failButton.setImage(UIImage(named: "failChecked"), forState: .Normal)
                }, completion: nil)
            UIView.transitionWithView(succeedButton, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.succeedButton.setImage(UIImage(named: "succeed"), forState: .Normal)
                }, completion: nil)
        default: ()
        }
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

