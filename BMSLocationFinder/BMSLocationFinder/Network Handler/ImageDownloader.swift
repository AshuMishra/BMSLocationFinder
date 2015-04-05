//
//  ImageDownloader.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 04/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadCompletionBlock = (image:UIImage?, error: NSError?) -> ()


class ImageDownloader: NSObject {
    
    var imageCache: NSMutableDictionary = NSMutableDictionary()
    
    //Shared Instance
    class var sharedInstance: ImageDownloader {
        struct Static {
            static var instance: ImageDownloader?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = ImageDownloader()
        }
        return Static.instance!
    }
    
    func fetchImage(urlString:NSString,completionBlock:ImageDownloadCompletionBlock) {
        var imageForURL:UIImage? = self.imageCache.objectForKey(urlString) as UIImage!
       
        //To check from where we have to pick the image- Server, Cache?
        if (imageForURL != nil) {
            completionBlock(image: imageForURL,error: nil)
        }
        else {
            var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
            
            if checkInternetConnection {
                //To download Image Asynchronously from server
                var request: NSURLRequest = NSURLRequest(URL: NSURL(string: urlString)!)
                let queue:NSOperationQueue = NSOperationQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        var image: UIImage? = UIImage(data: data!)
                        if (image != nil) {
                            self.imageCache.setObject(image!, forKey: urlString)
                        }
                        //Dispatch Image to main queue to update UI
                        dispatch_async(dispatch_get_main_queue(), {
                            completionBlock(image: image,error: nil)
                        })
                    }else {
                        //Dispatch Image to main queue to update UI
                        dispatch_async(dispatch_get_main_queue(), {
                            completionBlock(image:nil,error: error)
                        })
                    }
                })
            }
            else {
                UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
                completionBlock(image: nil,error: nil)
            }
            
        }
    }
}
