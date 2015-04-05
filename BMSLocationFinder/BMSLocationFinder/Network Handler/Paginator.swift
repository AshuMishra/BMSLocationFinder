//
//  Paginator.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 04/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit

class Paginator: NSObject {
    
    var url: String
    var parameters: NSDictionary?
    private var finalResult: NSMutableArray?
    var pageCount = 0
    var nextPageToken: NSString?
    
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
        //Load the first page of search results

        var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
        if checkInternetConnection {
            self.reset()
            
            var request: NSURLRequest = NSURLRequest(URL: NSURL(string: self.urlString())!)
            let queue:NSOperationQueue = NSOperationQueue()
           
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                var err: NSError
                var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                if (error != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(result: nil, error: error, allPagesLoaded: false)
                    })
                }
                else {
                    var fetchedResult = jsonResult.objectForKey("results") as? NSMutableArray
                    if (fetchedResult!.count > 0){
                        self.updateResult(fetchedResult!)
                        //If next page is present in reponse then make service to load more data
                        if var latestValue = jsonResult["next_page_token"] as? String {
                            self.nextPageToken = latestValue
                        }
                    }
                    var allPagesLoaded:Bool = self.nextPageToken == nil
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(result: self.finalResult,error: nil,allPagesLoaded: allPagesLoaded)
                    })
                }
            })
        }
        else {
            UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            completionBlock(result: nil, error: nil, allPagesLoaded: false)
        }
        
    }
    
    func updateResult(result:NSArray) {
        self.pageCount++
        self.finalResult?.addObjectsFromArray(result)
    }
    
    func loadNext(completionBlock:RequestCompletionBlock) {
        //To load next page if results are more than 20
        if (self.nextPageToken == nil) {
            completionBlock(result: nil, error: nil, allPagesLoaded: true)
        }
        else {
            var nextURLString = NSString(format: "%@&pagetoken=%@", self.urlString(),self.nextPageToken!)
            var request: NSURLRequest = NSURLRequest(URL: NSURL(string: nextURLString)!)
            let queue:NSOperationQueue = NSOperationQueue()
            
            var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
            if checkInternetConnection {
                NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    var err: NSError
                    var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    
                    if (error != nil) {
                        dispatch_async(dispatch_get_main_queue(), {
                            completionBlock(result: self.finalResult, error: error, allPagesLoaded: false)
                        })
                    }else {
                        var allPagesLoaded:Bool = false

                        var fetchedResult = jsonResult.objectForKey("results") as? NSMutableArray
                        if (fetchedResult!.count > 0){
                            self.updateResult(fetchedResult!)
                            var latestValue = jsonResult["next_page_token"] as? String
                            if (latestValue == nil) {
                                allPagesLoaded = true
                            }else {
                                allPagesLoaded = false
                            }
                            self.nextPageToken = latestValue
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            completionBlock(result: self.finalResult,error: nil,allPagesLoaded: allPagesLoaded)
                        })
                    }
                })
            }
            else {
                UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
                completionBlock(result: nil, error: nil, allPagesLoaded: false)
            }
        }
    }
    
    func urlString()-> NSString {
        //To make url string to load data from server
        var parameterString = ""
        var keys = self.parameters?.allKeys
        for (key, value) in self.parameters! {
            var paramKey = key as String
            var paramValue = value as String
            parameterString +=  paramKey + "=" + paramValue + "&"
        }
        let URLString = urlStruct.baseURL + url + parameterString + "key=" + urlStruct.APIKey + "&" + "sensor=true"
        return URLString
    }
    


}