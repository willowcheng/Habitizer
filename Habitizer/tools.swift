//
//  tools.swift
//  Habitizer
//
//  Created by Zhiheng Yi on 2015-06-30.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import UIKit
import Foundation

func addShadow(buttons: UIButton...) {
    for button in buttons {
        button.layer.shadowOffset = CGSizeMake(3, 3)
        button.layer.shadowRadius = 3
        button.layer.shadowColor = UIColor.grayColor().CGColor
        button.layer.shadowOpacity = 0.5
    }
}