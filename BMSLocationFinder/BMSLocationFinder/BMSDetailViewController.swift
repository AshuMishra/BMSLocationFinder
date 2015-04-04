//
//  BMSDetailViewController.swift
//  BMSLocationFinder
//
//  Created by Ashutosh on 03/04/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import Foundation
import UIKit

class BMSDetailViewController: UIViewController {
    var currentPlace:Place?
    
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeNameLabel.text = self.currentPlace?.placeName
//        self.distanceLabel.text = 
        BMSNetworkManager.sharedInstance.sendRequestForPhoto(self.currentPlace!.photoReference, completionBlock: { (image, error) -> () in
            self.placeImageView.image = image
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
