//
//  ListCell.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ListCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    
    var place:Place!
    
    func configure(#placeObject:Place) {
        self.place = placeObject
        placeName.text = placeObject.placeName
        distanceLabel.text = NSString(format: "%.2lf Km.", BMSUtil().calculateDistance(place.latitude, longitude: place.longitude)/1000)
        self.loadAsynchronousImage()
        
    }
    
    func loadAsynchronousImage() {
        // If the image does not exist, we need to download it
        var imgURL: NSURL = NSURL(string: place.iconUrl)!
        
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    self.placeImageView.image = UIImage(data: data)
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
    
//    func calculateDistance()-> Double  {
//        var currentLocation = BMSNetworkManager.sharedInstance.currentUserLocation
//        var placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
//        return  placeLocation.distanceFromLocation(currentLocation)
//    }
}
