//
//  BMSUtil.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 04/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import CoreLocation

class BMSUtil: NSObject {
    
    //To show 3rd party progress hud.
    class func showProressHUD() {
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
    }
    
    //To hide progress hud.
    class func hideProgressHUD() {
        HUDController.sharedController.hide(animated: true)
    }
    
    //To calculate the distance between two points.
    func calculateDistance(latitude: Double, longitude: Double)-> Double  {
        var currentLocation = BMSNetworkManager.sharedInstance.currentUserLocation
        var placeLocation = CLLocation(latitude: latitude, longitude:longitude)
        return  placeLocation.distanceFromLocation(currentLocation)
    }
 
}
