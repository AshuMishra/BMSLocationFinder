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
    
    var placesArray: NSMutableArray?
    var currentPlaceType: PlaceType = .Food
    var radius: Float = 5000
    var shouldShowLoadMore: Bool = false
    var shouldShowFavorite: Bool = false
    
    var footerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesArray = NSMutableArray()
        listTableView.tableFooterView = UIView()// To hide cell layout while there is no cell
        self.initFooterView()
        
        if (self.shouldShowFavorite) {
            self.configureForFavorites()
        }else {
            self.configureForPlaceType()
        }

    }
    
    func configureForFavorites() {
        self.fetchFavoritePlaces()
    }
    
    func fetchFavoritePlaces() {
        let fetchRequest = NSFetchRequest(entityName: "FavoritePlace")
        if let fetchResults = CoreDataManager.sharedManager.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [FavoritePlace] {
            if (fetchResults.count == 0) {
                println("show alert")
            }else {
            for i in 0...fetchResults.count-1 {
                var favoritePlace = fetchResults[i] as FavoritePlace
                var place = Place()
                place.placeId = favoritePlace.placeId
                place.placeName = favoritePlace.placeName
                place.iconUrl = favoritePlace.placeImageUrl
                place.photoReference = favoritePlace.placeImagePhotoReference
                place.latitude = favoritePlace.placeLatitude.doubleValue
                place.longitude = favoritePlace.placeLongitude.doubleValue
                place.isFavorite = true
                self.placesArray?.addObject(place)
                }
            }
        }
    }
    
    func configureForPlaceType() {
        self.sideMenuController()?.sideMenu?.delegate = self
        BMSUtil.showProressHUD()
        BMSNetworkManager.sharedInstance.fetchLocation({(location:CLLocation) -> () in
            BMSNetworkManager.sharedInstance.updatePlacePaginator(radius: self.radius, type: self.stringForPlaceType(self.currentPlaceType))
            BMSNetworkManager.sharedInstance.placePaginator?.loadFirst({ (result, error, allPagesLoaded) -> () in
                for (var i = 0 ; i < result?.count ; i++) {
                    var place = Place(dictionary: result?[i] as NSDictionary)
                    self.placesArray?.addObject(place)
                }
                self.shouldShowLoadMore = !allPagesLoaded
                self.listTableView.reloadData()
                BMSUtil.hideProgressHUD()
            })
        })
    }
    
    func initFooterView() {
        footerView = UIView(frame: CGRectMake(0.0, 0.0, 320.0, 60.0))
        var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.tag = 10
        activityIndicator.frame = CGRectMake(130.0, 15.0, 30, 30.0)
        activityIndicator.hidesWhenStopped = true
        footerView?.addSubview(activityIndicator)
        activityIndicator = nil
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
        cell.configure(placeObject: self.placesArray?.objectAtIndex(indexPath.row) as Place)
        
         return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.placesArray!.count - 1 && self.shouldShowLoadMore) {
        self.listTableView.tableFooterView = self.footerView
        (self.footerView?.viewWithTag(10) as UIActivityIndicatorView).startAnimating()
        BMSNetworkManager.sharedInstance.placePaginator?.loadNext({ (result, error, allPagesLoaded) -> () in
            for (var i = 0 ; i < result?.count ; i++) {
                var place = Place(dictionary: result?[i] as NSDictionary)
                self.placesArray?.addObject(place)
            }
            self.shouldShowLoadMore = !allPagesLoaded
            self.listTableView.reloadData()
            BMSUtil.hideProgressHUD()
        })
        }else {
            (self.footerView?.viewWithTag(10) as UIActivityIndicatorView).stopAnimating()
            self.listTableView.tableFooterView = nil
        }
    }

//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        var endOfTable: Bool = ((scrollView.contentOffset.y) >= CGFloat((self.placesArray?.count * 60) - scrollView.frame.size.height)); // Here 40 is row height
//        
//        if (self.hasMoreData && endOfTable && !self.isLoading && !scrollView.dragging && !scrollView.decelerating) {
//            self.tableView.tableFooterView = footerView
//            [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
//        }
//
//    }

    //MARK: Segue Method:-
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationController = segue.destinationViewController as BMSDetailViewController
        var indexPath: NSIndexPath = self.listTableView.indexPathForSelectedRow()!
        destinationController.currentPlace = self.placesArray?.objectAtIndex(indexPath.row) as? Place
    }

    @IBAction func handleNext(sender: AnyObject) {
        BMSNetworkManager.sharedInstance.placePaginator?.loadNext({ (result, error, allPagesLoaded) -> () in
            for (var i = 0 ; i < result?.count ; i++) {
                var place = Place(dictionary: result?[i] as NSDictionary)
                self.placesArray?.addObject(place)
            }
            self.listTableView.reloadData()
            BMSUtil.hideProgressHUD()
        })
    }
}

