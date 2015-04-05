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
    @IBOutlet weak var favoritePlaceImageView: UIImageView!
    
    var place:Place!
    
    func configure(#placeObject:Place) {
        self.place = placeObject
        placeName.text = placeObject.placeName
        distanceLabel.text = NSString(format: "%.2lf Km.", placeObject.distance/1000)

        var favoritePlace: NSManagedObject? = BMSUtil().fetchFavoritePlacesForId(place!.placeId)
        var imageName =  (favoritePlace != nil) ? "favorite_selected.png" : "favorite_unselected.png"
        self.favoritePlaceImageView.image = UIImage(named: imageName)

        
        self.loadAsynchronousImage()
        
    }
    
    func loadAsynchronousImage() {
        // If the image does not exist, we need to download it
        var imgURL: NSURL = NSURL(string: place.iconUrl)!
        
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
        if checkInternetConnection {
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
//        else {
//            UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
//        }

       
    }
    
}
