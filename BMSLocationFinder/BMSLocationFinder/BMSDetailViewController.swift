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

class BMSDetailViewController: UIViewController {
    var currentPlace:Place?
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeLocationMapView: MKMapView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateFavoriteButton()
        self.showLocationOnMap()
        self.distanceLabel.text = NSString(format: "%.2lf Km.", BMSUtil().calculateDistance(self.currentPlace!.latitude, longitude: self.currentPlace!.longitude)/1000)
        BMSNetworkManager.sharedInstance.sendRequestForPhoto(self.currentPlace!.photoReference, completionBlock: { (image, error) -> () in
            self.placeImageView.image = image
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: User Defined Methods:-
    
    func showLocationOnMap() {
        var latDelta:CLLocationDegrees = 0.50
        var longDelta:CLLocationDegrees = 0.50
        
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentPlace!.latitude, self.currentPlace!.longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        self.placeLocationMapView.setRegion(region, animated: true)
        
        var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentPlace!.latitude, self.currentPlace!.longitude)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = self.currentPlace?.placeName as String
        self.placeLocationMapView.addAnnotation(objectAnnotation)
    }
    
    func updateFavoriteButton() {
        var favoritePlace: NSManagedObject? = self.fetchFavoritePlacesForId(self.currentPlace!.placeId)
        var title =  (favoritePlace != nil) ? "Unfavorite" : "Favorite"
        self.favoriteButton.setTitle(title, forState: UIControlState.Normal)

    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        if ((self.currentPlace?.isFavorite) == false) {
            self.addToFavorites()
            self.currentPlace?.isFavorite = true
            
        }else {
            self.removeFromFavorites()
            self.currentPlace?.isFavorite = false
        }
        self.updateFavoriteButton()
    }
    
    func addToFavorites() {
        var favoritePlace: NSManagedObject? = self.fetchFavoritePlacesForId(self.currentPlace!.placeId)
        if (favoritePlace == nil) {
            let favoritePlace = NSEntityDescription.insertNewObjectForEntityForName("FavoritePlace", inManagedObjectContext: CoreDataManager.sharedManager.managedObjectContext!) as FavoritePlace
            favoritePlace.placeName = self.currentPlace!.placeName
            favoritePlace.placeId = self.currentPlace!.placeId
            favoritePlace.placeImageUrl = self.currentPlace!.iconUrl
            favoritePlace.placeLatitude = self.currentPlace!.latitude
            favoritePlace.placeLongitude = self.currentPlace!.longitude
            favoritePlace.placeImagePhotoReference = self.currentPlace!.photoReference
            CoreDataManager.sharedManager.saveContext()
        }
    }
    
    func fetchFavoritePlacesForId(placeId: String)-> FavoritePlace? {
        var favoritePlace: FavoritePlace?
        let fetchRequest = NSFetchRequest(entityName: "FavoritePlace")
        fetchRequest.predicate = NSPredicate(format: "SELF.placeId = %@",placeId)
        if let fetchResults = CoreDataManager.sharedManager.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [FavoritePlace] {
            favoritePlace = fetchResults.first
        }
        return favoritePlace
    }

    func removeFromFavorites() {
        var favoritePlace = self.fetchFavoritePlacesForId(self.currentPlace!.placeId)
        CoreDataManager.sharedManager.managedObjectContext?.deleteObject(favoritePlace!)
        CoreDataManager.sharedManager.saveContext()
    }
}
