//
//  Place.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation

class Place: NSObject {
    var latitude:Float = 0.0
    var longitude:Float = 0.0
    var placeId:NSString = ""
    var icon:NSString = ""
    var placeName:NSString = ""
    var photoReference:NSString = ""
    
    override init() {
        super.init()
    }
    
    init(dictionary:NSDictionary) {
        var dict = dictionary.objectForKey("geometry")?.objectForKey("location") as NSDictionary
        latitude = dict.objectForKey("lat") as Float
        longitude = dict.objectForKey("lng") as Float
        placeId = dictionary.objectForKey("place_id") as String
        icon = dictionary.objectForKey("icon") as String
        placeName = dictionary.objectForKey("name") as String
        photoReference = dictionary.objectForKey("reference") as String
    }
    
    
}

