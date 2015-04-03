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
   // var profileObj: ProfileModalData?
    var isFromProfile: Bool?
    var destViewController : UIViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(20.0, 0, 0, 0) //
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = false
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
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 4
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
                cell!.textLabel?.textColor = UIColor.lightGrayColor()
                let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
                selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                cell!.selectedBackgroundView = selectedBackgroundView
            }
            switch indexPath.row {
            case 1: cell!.textLabel?.text = "Trips"
            case 2: cell!.textLabel?.text = "Contacts"
            case 3: cell!.textLabel?.text = " Profile"
            default : break
            }
            //Change cell's tint color
            cell?.tintColor = UIColor.whiteColor()
            cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 23.0)
            cell?.accessoryType = (lastSelectedIndexPath?.row == indexPath.row) ? .Checkmark : .None
            cell?.selectionStyle = .Default
            return cell!
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 190.0
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
        if indexPath.row == 0 {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            lastSelectedIndexPath = NSIndexPath(forRow: 3, inSection: 0)
            let newCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath!)
            newCell?.accessoryType = .Checkmark
        }
        
        if (indexPath.row == selectedMenuItem) {
            self.toggleSideMenuView()
            return
        }
        selectedMenuItem = indexPath.row
            
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        switch (indexPath.row) {
        case 0:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LSKProfileController") as UIViewController
            break
        case 1:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LSKTripsController") as UIViewController
            break
        case 2:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LSKContactController") as UIViewController
            break
        default:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LSKProfileController") as UIViewController
            break
        }
        sideMenuController()?.setContentViewController(destViewController)
    }
    
    
    
}
