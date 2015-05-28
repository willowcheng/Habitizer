//
//  NewHabitViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit

class NewHabitViewController: UIViewController {

    @IBOutlet weak var habitTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmNewHabitButtonPressed(sender: AnyObject) {
        if habitTextField.text.isEmpty {
            var alert = UIAlertController(title: nil, message: NSLocalizedString("TYPE_YOUR_NEW_HABIT", comment: "Type your new habit"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let db = SQLiteDB.sharedInstance()
            let sql = "INSERT INTO habit(id, content, startDate, achieved) VALUES (1, '\(habitTextField.text)', 'May 28, 2015', 0)"
            let rc = db.execute(sql)
            if rc != 0 {
                let alert = UIAlertView(title:"Success", message:"New habit added!", delegate:nil, cancelButtonTitle: "OK")
                alert.show()
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func cancelButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
