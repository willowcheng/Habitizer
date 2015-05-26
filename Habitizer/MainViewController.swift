//
//  ViewController.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-05-25.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var habitTargetLabel: UILabel!
    
    var data = [SQLRow]()
    let db = SQLiteDB.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        data = db.query("SELECT * FROM habit ORDER BY id ASC")
//        let row = data[0]
//        let task = row["content"]
//        habitTargetLabel.text = task?.asString()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

