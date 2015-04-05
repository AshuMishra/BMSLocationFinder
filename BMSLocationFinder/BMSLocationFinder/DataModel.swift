//
//  DataModel.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 05/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit

class DataModel : NSObject {
        
    class var sharedModel: DataModel {
        struct Static {
            static var instance: DataModel?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataModel()
        }
        
        return Static.instance!
    }

    
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
        var unsortedArray = NSArray(array: newPlaceArray)
        var descriptor: NSSortDescriptor? = NSSortDescriptor(key: "distance", ascending: true)
        var sortedResults: NSArray = unsortedArray.sortedArrayUsingDescriptors(NSArray(object: descriptor!))
        return sortedResults
    }
    
}
