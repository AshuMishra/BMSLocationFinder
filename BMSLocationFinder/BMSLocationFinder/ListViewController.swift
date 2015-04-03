//
//  ListViewController.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ListViewController: UIViewController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.sideMenuController()?.sideMenu?.delegate = self
        NetworkManager.sharedInstance.fetchLocation({(location:CLLocation) -> () in
            NetworkManager.sharedInstance.sendRequest(radius: 500, type: "food", completionBlock: { (dictionary, error) -> () in
                println("dict = \(dictionary)")
            })
        })
//        let url:NSURL = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=28.577409,77.322391&radius=500&types=food&key=AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c&sensor=true")!
//        
//        var request1: NSURLRequest = NSURLRequest(URL: url)
//        let queue:NSOperationQueue = NSOperationQueue()
//        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            var err: NSError
//            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
//            println("AsSynchronous\(jsonResult)")
//        })
        
    }
    
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        self.view.userInteractionEnabled = false
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
        self.view.userInteractionEnabled = true
        
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return true;
    }
    
    //MARK: IBAction Methods:-
    
    @IBAction func popoverButtonPressed(sender: AnyObject) {
        //Toggle slide menu
        toggleSideMenuView()
        
    }
}

