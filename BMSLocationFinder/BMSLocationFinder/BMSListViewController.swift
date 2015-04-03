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

class BMSListViewController: UIViewController, ENSideMenuDelegate {
    
    @IBOutlet weak var listTableView: UITableView!
    var placesArray: NSArray?
    var currentPlaceType: PlaceType = .Food
    var radius: Float = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesArray = NSArray()
        listTableView.tableFooterView = UIView()// To hide cell layout while there is no cell
        
         self.sideMenuController()?.sideMenu?.delegate = self
        BMSUtil.showProressHUD()
        BMSNetworkManager.sharedInstance.fetchLocation({(location:CLLocation) -> () in
            BMSNetworkManager.sharedInstance.sendRequest(radius: self.radius, type: self.stringForPlaceType(self.currentPlaceType), completionBlock: { (resultArray: NSArray?, error) -> () in
                println("dict = \(resultArray)")
                self.placesArray = resultArray
                self.listTableView.reloadData()
                BMSUtil.hideProgressHUD()
            })
        })

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
        
        //To add addition height to row seprator
//        var additionalSeparator: UIView = UIView(frame: CGRectMake(0,cell.frame.size.height-1,cell.frame.size.width,1))
//        additionalSeparator.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
//        cell.addSubview(additionalSeparator)
        return cell
    }
   
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        loadImagesForVisibleCell()
//    }
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        loadImagesForVisibleCell()
//    }
//    func loadImagesForVisibleCell(){
//        
//        var visibleCells = self.contactTableView.visibleCells() as [LSKContactsTableViewCell]
//        
//        for cell in visibleCells{
//            var contactsDict: ProfileModalData!
//            var indexPath =  self.contactTableView.indexPathForCell(cell)
//            switch self.returnSelectedButtonIndex() {
//            case 0: contactsDict = self.recentArray.objectAtIndex(indexPath!.row) as? ProfileModalData
//            case 1: contactsDict = self.trustedUserArray.objectAtIndex(indexPath!.row) as? ProfileModalData
//            case 2: contactsDict = self.contactsArray.objectAtIndex(indexPath!.row) as? ProfileModalData
//            default: break
//            }
//            let imageURL: String = NSString(format: "%@%@", LSKProfileController.imagesURLStruct.imageURL, contactsDict?.imageURL as String)
//            if countElements(imageURL)>0 {
//                LSKUtil.imageDownloader(imageURL, {(data:NSData) -> Void in
//                    var imgObj = UIImage(data: data)
//                    if imgObj != nil {
//                        cell.contactImageView.image = UIImage(data: data)
//                    }
//                    else {
//                        cell.contactImageView.image = UIImage(contentsOfFile: NSString(format: "%@/%@", NSBundle.mainBundle().resourcePath!,"Contact_Male.png"))
//                    }
//                    
//                })
//            }
//            else {
//                cell.contactImageView.image = UIImage(contentsOfFile: NSString(format: "%@/%@", NSBundle.mainBundle().resourcePath!,"Contact_Male.png"))
//            }
//        }
//    }

}

