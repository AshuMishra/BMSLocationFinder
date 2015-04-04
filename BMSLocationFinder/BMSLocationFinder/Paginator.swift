//
//  Paginator.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 04/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation

class Paginator: NSObject {
    var url: String
    var parameters: NSDictionary?
    private var finalResult: NSMutableArray?
    var pageCount = 0
    var nextPageToken: NSString?
//    var paginatorCompletionBlock: RequestCompletionBlock?
    
    typealias RequestCompletionBlock = (result: NSArray?, error: NSError?,allPagesLoaded:Bool) -> ()
    
    init(urlString:NSString,queryParameters:NSDictionary?) {
        url = urlString
        parameters = queryParameters
    }
    
    func reset() {
        self.pageCount = 0
        self.finalResult = []
    }
    
    
    func loadFirst(completionBlock:RequestCompletionBlock) {
 
        self.reset()
        var request: NSURLRequest = NSURLRequest(URL: NSURL(string: self.urlString())!)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err: NSError
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            if ((error) != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(result: nil, error: error, allPagesLoaded: false)
                })
            }else {
                self.pageCount++
                self.finalResult = jsonResult.objectForKey("results") as? NSMutableArray
                if let latestValue = jsonResult["next_page_token"] as? String {
                    self.nextPageToken = latestValue
                }
                var allPagesLoaded:Bool = self.nextPageToken == nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(result: self.finalResult,error: nil,allPagesLoaded: allPagesLoaded)
                })
            }
        })
    }
    
    func updateResult(result:NSArray) {
        self.pageCount++
        self.finalResult?.addObjectsFromArray(result)
    }
    
    func loadNext(completionBlock:RequestCompletionBlock) {
        if (self.nextPageToken == nil) {
            completionBlock(result: nil, error: nil, allPagesLoaded: true)
        }else {
            var nextURLString = NSString(format: "%@&pagetoken=%@", self.urlString(),self.nextPageToken!)
            println("next url = \(nextURLString)")
            var request: NSURLRequest = NSURLRequest(URL: NSURL(string: nextURLString)!)
            let queue:NSOperationQueue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                var err: NSError
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                if ((error) != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(result: nil, error: error, allPagesLoaded: false)
                    })
                }else {
                    var currentResult = jsonResult.objectForKey("results") as? NSMutableArray
                   self.updateResult(currentResult!)
                    if let latestValue = jsonResult["next_page_token"] as? String {
                        self.nextPageToken = latestValue
                    }
                    var allPagesLoaded:Bool = self.nextPageToken == nil
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(result: self.finalResult,error: nil,allPagesLoaded: allPagesLoaded)
                    })
                }
            })

        }
    }
    
    func urlString()-> NSString {
        var parameterString = ""
        var keys = self.parameters?.allKeys
        for (key, value) in self.parameters! {
            println("Property: \"\(key as String)\"")
            println("val = \(value as String)")
            var paramKey = key as String
            var paramValue = value as String
            parameterString +=  paramKey + "=" + paramValue + "&"
        }
        
        let URLString = urlStruct.baseURL + url + parameterString + "key=" + urlStruct.APIKey + "&" + "sensor=true"
        println("paginator url = \(URLString)")
        return URLString
    }
    
//    func createURLWithParameter(#radius:Float, type:NSString)-> NSString?{
//        var parameters:NSStringob
//        if (self.currentUserLocation != nil) {
//            var coordinate : CLLocationCoordinate2D = self.currentUserLocation!.coordinate
//            var locationParameter = NSString(format: "location=%f,%f",coordinate.latitude,coordinate.longitude)
//            var radiusParameter = NSString(format: "radius=%f",radius)
//            var typeParameter = NSString(format: "types=%@", type)
//            var apiParameter = NSString(format: "key=%@",kAPIKey)
//            let URLString = kBaseURL + kNearbySearchURL + locationParameter + "&" + radiusParameter + "&" + typeParameter + "&" + apiParameter + "&" + "sensor=true"
//            println("url = \(URLString)")
//            return URLString
//        }else {
//            return nil
//        }
//    }

}