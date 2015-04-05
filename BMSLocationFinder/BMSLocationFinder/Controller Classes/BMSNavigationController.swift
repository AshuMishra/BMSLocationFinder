//
//  BMSNavigationController.swift
//  SwiftSideMenu
//
//  Created by Ashutosh Mishra.
//  Copyright (c) 2014 Ashutosh Mishra. All rights reserved.
//

import UIKit

class BMSNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: BMSSlideMenuTableViewController(), menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        sideMenu?.menuWidth = screenWidth * 0.85 // optional, default is 160
        //sideMenu?.bouncingEnabled = false
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
        
        
        
    }
    func callTripScreen(tripId:NSString,context:NSString){
    //LSKSlideMenuTableViewController().getTripScreen(tripId,context:context)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
}
