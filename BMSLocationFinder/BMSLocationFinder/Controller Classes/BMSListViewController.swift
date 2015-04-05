//
//  BMSListViewController.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class BMSListViewController: UIViewController, ENSideMenuDelegate {
    
    @IBOutlet weak var listTableView: UITableView!
    
    var placesArray: NSArray?
    var currentPlaceType: PlaceType = .Food
    var radius: Int = 5000
    var shouldShowLoadMore: Bool = false
    var shouldShowFavorite: Bool = false
    var refreshControl: UIRefreshControl!
    var footerView: UIView?
    
    @IBOutlet weak var noResultMessageLabel: UILabel!
    @IBOutlet weak var noResultScreen: UIImageView!
    
  //MARK: View LifeCycle Methods:-
    override func viewDidLoad() {
        
        super.viewDidLoad()
        placesArray = NSArray()
        listTableView.tableFooterView = UIView()// To hide cell layout while there is no cell
        self.initFooterView()
        
        //To add pull to refresh in tableview.
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refreshPlace:", forControlEvents: UIControlEvents.ValueChanged)
        self.listTableView.addSubview(refreshControl)
        self.configureTable()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //MARK: User defined methods:-
    func configureTable() {
        // To check from where to show values in UITableView
        if (!self.shouldShowFavorite) {
            self.navigationItem.title = self.stringForPlaceType(self.currentPlaceType).capitalizedString
            self.configureForPlaceType()
        }
        else {
            self.navigationItem.title = "Favorites"
            self.configureForFavorites()
        }
    }
    
    func refreshPlace(sender:AnyObject) {
        //Pull to refresh method
      self.configureForPlaceType()
    }
    
    func configureForFavorites() {
        //To fetch data from favorites.
        self.placesArray = DataModel.sharedModel.fetchFavoritePlaces()
        self.updateViews()
    }
    
    func configureForPlaceType() {
        self.sideMenuController()?.sideMenu?.delegate = self
        var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
       
        if checkInternetConnection {
            BMSUtil.showProressHUD()
            BMSNetworkManager.sharedInstance.fetchLocation({(location:CLLocation?,error:NSError?) -> () in
                if (error != nil) {
                    UIAlertView(title: "Error", message: "Location could not be updated. Please check internet connection and settings and try again", delegate: nil, cancelButtonTitle: "OK").show()
                }else {
                    //To make url for downloading first page.
                    BMSNetworkManager.sharedInstance.updatePlacePaginator(radius: self.radius, type: self.stringForPlaceType(self.currentPlaceType))
                    //To hit web service to get data
                    BMSNetworkManager.sharedInstance.placePaginator?.loadFirst({ (result, error, allPagesLoaded) -> () in
                        self.updatePlacesArray(result)
                        self.shouldShowLoadMore = true
                        self.updateViews()
                        BMSUtil.hideProgressHUD()
                        self.refreshControl.endRefreshing()
                        
                    })
                }
            })
        }
        else {
            //To hide refresh control
            self.refreshControl.endRefreshing()
            self.shouldShowLoadMore = true
            UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
        }
        
    }
    
    func updateViews() {
        self.noResultMessageLabel.text = self.shouldShowFavorite ? "No Favorites yet." : "Please increase the radius of search."
        if self.placesArray?.count == 0 {
            self.noResultScreen.hidden = false
            self.listTableView.hidden = true
        }else {
            self.noResultScreen.hidden = true
            self.listTableView.hidden = false
            self.listTableView.reloadData()
        }
    }
    
    func initFooterView() {
        //Make custom footer view to indicate load more data
        footerView = UIView(frame: CGRectMake(0.0, 0.0, 320.0, 60.0))
        var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.tag = 10
        activityIndicator.frame = CGRectMake(160, 15.0, 30, 30.0)
        activityIndicator.hidesWhenStopped = true
        footerView?.addSubview(activityIndicator)
    }
    
   
    func stringForPlaceType(placetype:PlaceType)-> NSString! {
        switch(placetype) {
        case PlaceType.Food: return "food"
        case PlaceType.Gym: return "gym"
        case PlaceType.Hospital: return "hospital"
        case PlaceType.Restaurant: return "restaurant"
        case PlaceType.School: return "school"
        case PlaceType.Spa: return "spa"
        }
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
    
    //MARK: UITableView Datasource and Delegate Methods:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return(self.placesArray)?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var currentPlace: Place = self.placesArray?.objectAtIndex(indexPath.row) as Place
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as ListCell
        cell.backgroundColor = UIColor.whiteColor()
        cell.separatorInset = UIEdgeInsetsMake(0.0, cell.frame.size.width, 0.0, cell.frame.size.width)
        //Configure cell to show data
        cell.configure(placeObject: self.placesArray?.objectAtIndex(indexPath.row) as Place)
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == self.placesArray!.count - 1 && self.shouldShowLoadMore) {
            self.listTableView.tableFooterView = self.footerView
            (self.footerView?.viewWithTag(10) as UIActivityIndicatorView).startAnimating()
            
            //To load more data if exists
            var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
            if checkInternetConnection {
                BMSNetworkManager.sharedInstance.placePaginator?.loadNext({ (result, error, allPagesLoaded) -> () in
                    self.updatePlacesArray(result)
                    self.shouldShowLoadMore = !allPagesLoaded
                    self.listTableView.reloadData()
                    BMSUtil.hideProgressHUD()
                })
                
            }
            else {
                UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
            
        }else {
            (self.footerView?.viewWithTag(10) as UIActivityIndicatorView).stopAnimating()
            self.listTableView.tableFooterView = UIView()
        }
    }
    
    func updatePlacesArray(result:NSArray?) {
        var newPlaceArray = NSMutableArray()
        for (var i = 0 ; i < result?.count ; i++) {
            var place = Place(dictionary: result?[i] as NSDictionary)
            newPlaceArray.addObject(place)
        }
        self.placesArray = newPlaceArray
        var descriptor: NSSortDescriptor? = NSSortDescriptor(key: "distance", ascending: true)//Sort the array according to it's distance
        var sortedResults: NSArray = self.placesArray!.sortedArrayUsingDescriptors(NSArray(object: descriptor!))
        self.placesArray = sortedResults
    }

    func registerNotification() {
        //Register notification to load the table with new data
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "configureTable",
            name: notificationStruct.didSetFavorite,
            object: nil)
    }

    //MARK: Segue Method:-
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.registerNotification()
        var destinationController = segue.destinationViewController as BMSDetailViewController
        var indexPath: NSIndexPath = self.listTableView.indexPathForSelectedRow()!
        destinationController.currentPlace = self.placesArray?.objectAtIndex(indexPath.row) as? Place
    }
}

