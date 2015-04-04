//
//  Place.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation

class Place: NSObject {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var placeId: NSString = ""
    var iconUrl: NSString = ""
    var placeName: NSString = ""
    var photoReference: NSString = ""
    
    override init() {
        super.init()
    }
    
    init(dictionary:NSDictionary) {
        var dict = dictionary.objectForKey("geometry")?.objectForKey("location") as NSDictionary
        self.latitude = dict.objectForKey("lat")!.doubleValue
        self.longitude = dict.objectForKey("lng")!.doubleValue
        self.placeId = dictionary.objectForKey("place_id") as String
        self.iconUrl = dictionary.objectForKey("icon") as String
        self.placeName = dictionary.objectForKey("name") as String
        
        var tempArray: NSArray? =  dictionary.objectForKey("photos") as? NSArray
        if tempArray != nil {
            var tempPhotoDict: NSDictionary? = tempArray?.firstObject as? NSDictionary
            self.photoReference = tempPhotoDict?.objectForKey("photo_reference") as String
        }
       
        
    }
    
    
}

