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
    
    class func showProressHUD() {
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
    }
    
    class func hideProgressHUD() {
        HUDController.sharedController.hide(animated: true)
    }
    
    func calculateDistance(latitude: Double, longitude: Double)-> Double  {
        var currentLocation = BMSNetworkManager.sharedInstance.currentUserLocation
        var placeLocation = CLLocation(latitude: latitude, longitude:longitude)
        return  placeLocation.distanceFromLocation(currentLocation)
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

}