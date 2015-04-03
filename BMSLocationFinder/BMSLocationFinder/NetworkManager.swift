//
//  BMSNetworkManager.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

let kBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
let kAPIKey = "AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c"

typealias LocationFetchCompletionBlock = (CLLocation) -> ()

typealias RequestCompletionBlock = (result: NSArray?, error: NSError?) -> ()

class BMSNetworkManager : NSObject,CLLocationManagerDelegate,UIAlertViewDelegate {

    var currentUserLocation : CLLocation?
    var locationManager :CLLocationManager?

    var locationFetchCompletionBlock : LocationFetchCompletionBlock?
    class var sharedInstance: BMSNetworkManager {
        struct Static {
            static var instance: BMSNetworkManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = BMSNetworkManager()
        }
        
        return Static.instance!
    }
    

    override init() {
        super.init()
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func updateLocation() {
        
        if (constantStruct.IS_OS_8_AND_ABOVE) {
            locationManager?.requestWhenInUseAuthorization()
        }
        var authorizationDenied: Bool = (CLLocationManager.authorizationStatus().rawValue == CLAuthorizationStatus.Denied.rawValue)
        if (authorizationDenied)
        {
            var alert: UIAlertView = UIAlertView(title: "Location Service Disabled", message: "To enable, please go to Settings and turn on Location Service for this app.", delegate: self, cancelButtonTitle: "Not Now", otherButtonTitles: "Enable")
            alert.show()
        }
        else {
            locationManager?.startUpdatingLocation()
        }

    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
            manager.stopUpdatingLocation()
            self.currentUserLocation = newLocation
            self.locationFetchCompletionBlock!(newLocation)
            println("location fetched = \(self.currentUserLocation)")
    }
    func fetchLocation(completionBlock:LocationFetchCompletionBlock) {
        self.locationFetchCompletionBlock = completionBlock
        self.updateLocation()
    }
    
    func sendRequest(#radius:Float, type:NSString, completionBlock:RequestCompletionBlock) {
        var url = self.createURLWithParameter(radius: radius, type: type)
        var request1: NSURLRequest = NSURLRequest(URL: NSURL(string: url!)!)
        let queue:NSOperationQueue = NSOperationQueue()
        var placeResult:NSMutableArray = NSMutableArray()
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err: NSError
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            if ((error) != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(result: nil,error: error)
                })
            }else {
                println("AsSynchronous\(jsonResult)")
                var places = jsonResult.objectForKey("results") as NSArray
                for (var i = 0 ; i < places.count ; i++) {
                    println("place = \(places[i])")
                    var place = Place(dictionary: places[i] as NSDictionary)
                    println("place parsed= \(place)")
                    placeResult.addObject(place)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(result: placeResult,error: nil)
                })

            }

        })
    }

    func sendRequestForPhoto(photoReference:NSString) {
        var url = self.createPhotoURLWithParameter(photoReference)
        var request1: NSURLRequest = NSURLRequest(URL: NSURL(string: url!)!)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData?, error: NSError?) -> Void in
            var err: NSError
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            println("photo\(jsonResult)")
        })
    }
    
    func createPhotoURLWithParameter(photoReference:NSString)-> NSString? {
        var parameters:NSString
        if (self.currentUserLocation != nil) {
            var baseURL = "https://maps.googleapis.com/maps/api/place/photo?"
            var maxwidth = NSString(format: "maxwidth=%d", 400)
            var photoReference = NSString(format: "photoReference=%@", photoReference)
            var apiParameter = NSString(format: "key=%@",kAPIKey)
            
            let URLString = baseURL + maxwidth + "&" + photoReference + "&" + apiParameter
            println("url = \(URLString)")
            return URLString;
        }else {
            return nil;
        }
    }

    func createURLWithParameter(#radius:Float, type:NSString)-> NSString?{
        var parameters:NSString
        if (self.currentUserLocation != nil) {
            var coordinate : CLLocationCoordinate2D = self.currentUserLocation!.coordinate
            var locationParameter = NSString(format: "location=%f,%f",coordinate.latitude,coordinate.longitude)
            var radiusParameter = NSString(format: "radius=%f",radius)
            var typeParameter = NSString(format: "types=%@", type)
            var apiParameter = NSString(format: "key=%@",kAPIKey)
            let URLString = kBaseURL + locationParameter + "&" + radiusParameter + "&" + typeParameter + "&" + apiParameter + "&" + "sensor=true"
            println("url = \(URLString)")
            return URLString
        }else {
            return nil
        }
    }
}


