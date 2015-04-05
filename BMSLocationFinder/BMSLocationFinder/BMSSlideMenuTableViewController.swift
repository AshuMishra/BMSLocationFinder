//
//  LSKSlideMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Ashutosh Mishra
//  Copyright (c) 2014 Ashutosh Mishra. All rights reserved.
//

import UIKit

class BMSSlideMenuTableViewController: UITableViewController {
    var selectedMenuItem : Int = 1
    var lastSelectedIndexPath: NSIndexPath?
    var isFromProfile: Bool?
    var destViewController : BMSListViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = true
        lastSelectedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        
//        var backGroundImageV = UIImageView(image: UIImage(contentsOfFile: NSString(format: "%@/%@", NSBundle.mainBundle().resourcePath!,"Hamburger.png")))
//        backGroundImageV.frame = tableView.frame
//        self.tableView.backgroundView = backGroundImageV
        tableView.tableFooterView = UIView()
        
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        tableView.registerNib(UINib(nibName: "SlideMenuCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 8
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            var cellObj: SlideMenuCell?
            cellObj = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? SlideMenuCell
            
            return cellObj!
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
                cell!.backgroundColor = UIColor.clearColor()
                let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
                selectedBackgroundView.backgroundColor = UIColor.whiteColor()
                cell!.selectedBackgroundView = selectedBackgroundView
                cell?.textLabel?.textColor = UIColor.darkGrayColor()
            }
            switch indexPath.row {
            case 1: cell!.textLabel?.text = "Food"
            case 2: cell!.textLabel?.text = "Gym"
            case 3: cell!.textLabel?.text = "Hospital"
            case 4: cell!.textLabel?.text = "Restaurant"
            case 5: cell!.textLabel?.text = "School"
            case 6: cell!.textLabel?.text = "Spa"
            case 7: cell!.textLabel?.text = "Favorites"
            default : break
            }
            //Change cell's tint color
            cell?.tintColor = UIColor.darkGrayColor()
            cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 23.0)
            cell?.accessoryType = (lastSelectedIndexPath?.row == indexPath.row) ? .Checkmark : .None
            cell?.selectionStyle = .None
            return cell!
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 75.0
        }
        
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("did select row: \(indexPath.row)")
        
        if indexPath.row != lastSelectedIndexPath?.row  && indexPath.row != 0 {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            lastSelectedIndexPath = indexPath
        }
        
        selectedMenuItem = indexPath.row
            
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        switch (indexPath.row) {
        case  1, 2, 3, 4, 5, 6:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BMSListViewController") as BMSListViewController
            destViewController.currentPlaceType = PlaceType(rawValue: indexPath.row)!
            var sliderIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            var cell: SlideMenuCell = tableView.cellForRowAtIndexPath(sliderIndexPath) as SlideMenuCell
            destViewController.radius =  Int(cell.chooseRadiusSlider.value)
            sideMenuController()?.setContentViewController(destViewController)
        case 7:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BMSListViewController") as BMSListViewController
            destViewController.shouldShowFavorite = true
            sideMenuController()?.setContentViewController(destViewController)
            
        default:
            break
        }
        
    }
    
    
    
}
