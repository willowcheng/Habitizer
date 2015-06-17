//
//  Habits.swift
//  Habitizer
//
//  Created by Liu Cheng on 2015-06-09.
//  Copyright (c) 2015 Zhiheng Yi & Liu Cheng. All rights reserved.
//

import Foundation
import CoreData

class Habits: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var achieved: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var remainDays: Int16
}
