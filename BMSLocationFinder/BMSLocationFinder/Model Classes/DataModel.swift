//
//  DataModel.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 05/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

//Class to handle CoreData related task
import UIKit

class DataModel : NSObject {
    
    //Singlton class object
    class var sharedModel: DataModel {
        struct Static {
            static var instance: DataModel?
            static var token: dispatch_once_t = 0
        }
        //To initialize the object only once
        dispatch_once(&Static.token) {
            Static.instance = DataModel()
        }
        return Static.instance!
    }

    //Fetch favorite places
    func fetchFavoritePlaces()-> NSArray {
        var newPlaceArray = NSMutableArray()

        let fetchRequest = NSFetchRequest(entityName: "FavoritePlace")
        if let fetchResults = CoreDataManager.sharedManager.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [FavoritePlace] {
            if (fetchResults.count > 0) {
                for i in 0...fetchResults.count - 1 {
                    var favoritePlace = fetchResults[i] as FavoritePlace
                    var place = Place(favoritePlace: favoritePlace)
                    newPlaceArray.addObject(place)
                }
            }
        }
        //Sort array according to it's distance
        var descriptor: NSSortDescriptor? = NSSortDescriptor(key: "distance", ascending: true)
        var sortedResults: NSArray = newPlaceArray.sortedArrayUsingDescriptors(NSArray(object: descriptor!))
        return sortedResults
    }
    
    func addPlaceToFavorites(currentPlace:Place) {
        var favoritePlace: NSManagedObject? = self.fetchFavoritePlacesForId(currentPlace.placeId)
        //If object is not in DB, then add it into DB to make it favorite and skip duplicacy.
        if (favoritePlace == nil) {
            let favoritePlace = NSEntityDescription.insertNewObjectForEntityForName("FavoritePlace", inManagedObjectContext: CoreDataManager.sharedManager.managedObjectContext!) as FavoritePlace
            favoritePlace.placeName = currentPlace.placeName
            favoritePlace.placeId = currentPlace.placeId
            favoritePlace.placeImageUrl = currentPlace.iconUrl
            favoritePlace.placeLatitude = currentPlace.latitude
            favoritePlace.placeLongitude = currentPlace.longitude
            favoritePlace.placeImagePhotoReference = currentPlace.photoReference
            CoreDataManager.sharedManager.saveContext()
        }
    }
    
    func removePlaceFromFavorites(currentPlace:Place) {
        //Remove Object from favorite
        var favoritePlace = self.fetchFavoritePlacesForId(currentPlace.placeId)
        CoreDataManager.sharedManager.managedObjectContext?.deleteObject(favoritePlace!)
        CoreDataManager.sharedManager.saveContext()
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
