//
//  BMSDetailViewController.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import CoreData
import QuartzCore

class BMSDetailViewController: UIViewController {
    var currentPlace:Place?
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Update favorite button in Deatil view
        self.updateFavoriteButton()
        
        //Show place location on map
        self.showLocationOnMap()
        self.placeNameLabel.text = self.currentPlace?.placeName
        self.distanceLabel.text = NSString(format: "%.2lf Km.", BMSUtil().calculateDistance(self.currentPlace!.latitude, longitude: self.currentPlace!.longitude)/1000)
        
        //To load place photo as mentioned in doc
        BMSNetworkManager.sharedInstance.sendRequestForPhoto(self.currentPlace!.photoReference, completionBlock: { (image, error) -> () in
            self.placeImageView.image = image
            self.placeImageView.layer.cornerRadius = self.placeImageView.frame.size.height/2;
            self.placeImageView.layer.masksToBounds = true;
            self.placeImageView.layer.borderWidth = 0;
            
        })
        
        var favoritePlace: NSManagedObject? = DataModel.sharedModel.fetchFavoritePlacesForId(self.currentPlace!.placeId)
        self.currentPlace?.isFavorite =  (favoritePlace != nil) ? true : false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: User Defined Methods:-
    
    func showLocationOnMap() {
        var latDelta:CLLocationDegrees = 0.50
        var longDelta:CLLocationDegrees = 0.50
        
        //To set region to show on map
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentPlace!.latitude, self.currentPlace!.longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        self.placeLocationMapView.setRegion(region, animated: true)
        
        //Show annotation on map
        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentPlace!.latitude, self.currentPlace!.longitude)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = self.currentPlace?.placeName as String
        self.placeLocationMapView.addAnnotation(objectAnnotation)
    }
    
    func updateFavoriteButton() {
        //To update the favorite button according to favorite.
        var favoritePlace: NSManagedObject? = DataModel.sharedModel.fetchFavoritePlacesForId(self.currentPlace!.placeId)
        var imageName =  (favoritePlace != nil) ? "favorite_selected.png" : "favorite_unselected.png"
        self.favoriteButton.setImage(UIImage(named: imageName), forState: .Normal)
    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        
              //To select and deselect the favorite
        if ((self.currentPlace?.isFavorite) == false) {
            DataModel.sharedModel.addPlaceToFavorites(self.currentPlace!)
            self.currentPlace?.isFavorite = true
            
        }else {
            DataModel.sharedModel.removePlaceFromFavorites(self.currentPlace!)
            self.currentPlace?.isFavorite = false
        }
        self.updateFavoriteButton()
        NSNotificationCenter.defaultCenter().postNotificationName(notificationStruct.didSetFavorite, object: nil)
    }
    

    
}
