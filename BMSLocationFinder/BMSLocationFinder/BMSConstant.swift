//
//  BMSConstant.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit

enum PlaceType: NSInteger {
    case Food = 1
    case Gym
    case Hospital
    case Restaurant
    case School
    case Spa
}

struct constantStruct {
    static let IS_OS_8_AND_ABOVE = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0
}