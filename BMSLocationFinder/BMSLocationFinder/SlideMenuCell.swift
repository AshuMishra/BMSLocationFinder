//
//  SlideMenuCell.swift
//  SkoolConnect
//
//  Created by Ashutosh on 19/02/2015.
//  Copyright (c) 2015 Ashutosh. All rights reserved.
//

import UIKit
import Foundation

class SlideMenuCell: UITableViewCell {
   
    @IBOutlet weak var selectedRadiusLabel: UILabel!
    @IBOutlet weak var chooseRadiusSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init() {
        super.init()        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func sliderValueChanged(sender: AnyObject) {
        self.selectedRadiusLabel.text = NSString(format: "%d", Int( self.chooseRadiusSlider.value))
    }
}
