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

let kBaseURL = "https://maps.googleapis.com/maps/api/place/"
let kNearbySearchURL = "nearbysearch/json?"
let kPhotoURL = "photo?"
let kAPIKey = "AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c"

typealias LocationFetchCompletionBlock = (CLLocation) -> ()

typealias RequestCompletionBlock = (result: NSArray?, error: NSError?) -> ()
typealias PhotoRequestCompletionBlock = (image:UIImage?, error: NSError?) -> ()


class BMSNetworkManager : NSObject,CLLocationManagerDelegate,UIAlertViewDelegate {

    var currentUserLocation :CLLocation?
    var locationManager :CLLocationManager?
    var placePaginator : Paginator?

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
      //        paginator.loadFirst ({(result, error, allPagesLoaded) -> () in
//            println("sskdfdk")
//            paginator.loadNext ({ (result, error, allPagesLoaded) -> () in
//                println("sskdfdk")
//                
//            })
//        })
    }
    
    func updatePlacePaginator(#radius:Float, type:NSString) {
        var coordinate : CLLocationCoordinate2D = self.currentUserLocation!.coordinate
        var locationString = NSString(format: "%f,%f", coordinate.latitude,coordinate.longitude)
        var parameterDictionary = ["location":locationString,"radius":NSString(format: "%f",radius),"types":type]
        self.placePaginator = Paginator(urlString: urlStruct.placeSearchURL, queryParameters: parameterDictionary)
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
//    ttps://maps.googleapis.com/maps/api/place/nearbysearch/json?location=28.777700,77.355550&radius=5000.000000&types=food&key=AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c&sensor=true
//    
    func sendRequest(#radius:Float, type:NSString, completionBlock:RequestCompletionBlock) {
//        var coordinate : CLLocationCoordinate2D = self.currentUserLocation!.coordinate
//        var locationString = NSString(format: "%f,%f", coordinate.latitude,coordinate.longitude)
//        var parameterDictionary = ["location":locationString,"radius":NSString(format: "%f",radius),"types":type]
//        var paginator = Paginator(urlString: urlStruct.placeSearchURL, queryParameters: parameterDictionary)
//        paginator.loadFirst ({(result, error, allPagesLoaded) -> () in
//            println("sskdfdk")
//            paginator.loadNext ({ (result, error, allPagesLoaded) -> () in
//                println("sskdfdk")
//                
//            })
//        })
//        

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
                var places = jsonResult.objectForKey("results") as NSArray
                for (var i = 0 ; i < places.count ; i++) {
                    var place = Place(dictionary: places[i] as NSDictionary)
                    placeResult.addObject(place)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(result: placeResult,error: nil)
                })

            }

        })
    }

    func sendRequestForPhoto(photoReference:NSString,completionBlock:PhotoRequestCompletionBlock) {
        var url = self.createPhotoURLWithParameter(photoReference)
        var request1: NSURLRequest = NSURLRequest(URL: NSURL(string: url!)!)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                var image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(image: image,error: nil)
                })
            }else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(image:nil,error: error)
                })
            }
        })
    }
    
    func createPhotoURLWithParameter(photoReference:NSString)-> NSString? {
        var parameters:NSString
        if (self.currentUserLocation != nil) {
            var maxwidth = NSString(format: "maxwidth=%d", 400)
            var photoReference = NSString(format: "photoreference=%@", photoReference)
            var apiParameter = NSString(format: "key=%@",kAPIKey)
            
            let URLString = kBaseURL + kPhotoURL + maxwidth + "&" + photoReference + "&" + apiParameter
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
            let URLString = kBaseURL + kNearbySearchURL + locationParameter + "&" + radiusParameter + "&" + typeParameter + "&" + apiParameter + "&" + "sensor=true"
            println("url = \(URLString)")
            return URLString
        }else {
            return nil
        }
    }
}


