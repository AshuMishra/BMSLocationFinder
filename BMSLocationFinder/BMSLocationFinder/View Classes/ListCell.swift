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
        //Configure cell in ListView Controller
        self.place = placeObject
        placeName.text = placeObject.placeName
        distanceLabel.text = NSString(format: "%.2lf Km.", placeObject.distance/1000)

        //To check Whether this place is favorite is not using it's loaction and apply image according to that.
        var favoritePlace: NSManagedObject? = DataModel.sharedModel.fetchFavoritePlacesForId(place!.placeId)
        var imageName =  (favoritePlace != nil) ? "favorite_selected.png" : "favorite_unselected.png"
        self.favoritePlaceImageView.image = UIImage(named: imageName)

        //Load image asynchronously.
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
                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
                }
            })
        }
        
    }
    
}
