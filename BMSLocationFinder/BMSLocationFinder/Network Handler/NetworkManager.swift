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



typealias LocationFetchCompletionBlock = (CLLocation?,error:NSError?) -> ()
typealias RequestCompletionBlock = (result: NSArray?, error: NSError?) -> ()
typealias PhotoRequestCompletionBlock = (image:UIImage?, error: NSError?) -> ()


class BMSNetworkManager : NSObject,CLLocationManagerDelegate,UIAlertViewDelegate {

    var currentUserLocation :CLLocation?
    var locationManager :CLLocationManager?
    var placePaginator : Paginator?

    //Shared Instance
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
        //Initialize Location manager to update location
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func updatePlacePaginator(#radius:Int, type:NSString) {
        //To update your location and pass required parameter to load the page using Paginator class
        var coordinate : CLLocationCoordinate2D = self.currentUserLocation!.coordinate
        var locationString = NSString(format: "%f,%f", coordinate.latitude,coordinate.longitude)
        var parameterDictionary = ["location":locationString,"radius":NSString(format: "%d",radius),"types":type]
        self.placePaginator = Paginator(urlString: urlStruct.placeSearchURL, queryParameters: parameterDictionary)
    }
    
    func updateLocation() {
        //To check what method we use to update the location depending upon on ios version
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
        self.locationFetchCompletionBlock!(nil,error: error)

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        //This method is used to update the user location
            manager.stopUpdatingLocation()
            self.currentUserLocation = newLocation
            self.locationFetchCompletionBlock!(newLocation,error: nil)
    }
    
    func fetchLocation(completionBlock:LocationFetchCompletionBlock) {
        self.locationFetchCompletionBlock = completionBlock
        self.updateLocation()
    }

    func sendRequestForPhoto(photoReference:NSString,completionBlock:PhotoRequestCompletionBlock) {
        //Method is used for to download place image when seeing it's deatil
        var url = self.createPhotoURLWithParameter(photoReference)
        ImageDownloader.sharedInstance.fetchImage(url!, completionBlock: completionBlock)
    }
    
    func createPhotoURLWithParameter(photoReference:NSString)-> NSString? {
        
        //This method is used to make proper string to fetch place image.
        var parameters:NSString
        if (self.currentUserLocation != nil) {
            var maxwidth = NSString(format: "maxwidth=%d", 400)
            var photoReference = NSString(format: "photoreference=%@", photoReference)
            var apiParameter = NSString(format: "key=%@",urlStruct.APIKey)
            
            let URLString = urlStruct.baseURL + urlStruct.photoFetchURL + maxwidth + "&" + photoReference + "&" + apiParameter
            return URLString;
        }else {
            return nil;
        }
    }
}


