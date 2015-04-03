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

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
  //  var profileObj: ProfileModalData?

   
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        var filePath = OnlineDataManager.writeDataToPlist(constantStruct.profileFile)
//        var fileManager = NSFileManager.defaultManager()
//        if (fileManager.fileExistsAtPath(filePath))
//        {
//            var data = NSData(contentsOfFile: filePath)
//            var profileResp = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as ProfileModalData
//            profileObj = profileResp
//            LSKUtil .changeViewToCircle(self.userNameLabel.layer, bordorWidth: 0, cornerRadius: self.userNameLabel.frame.size.height / 2, borderColor: UIColor.clearColor())
//
//            
//            let imageURL: String = NSString(format: "%@%@", LSKProfileController.imagesURLStruct.imageURL, profileObj?.imageURL as String)
//            if countElements(imageURL)>0 {
//                LSKUtil.imageDownloader(imageURL, {(data:NSData) -> Void in
//                    var imgObj = UIImage(data: data)
//                    if imgObj != nil {
//                        self.userImageView.image = UIImage(data: data)
//                    }
//                    else{
//                        self.userImageView.image = UIImage(contentsOfFile: NSString(format: "%@/%@", NSBundle.mainBundle().resourcePath!,"Contact_Male.png"))
//                    }
//                    self.userNameLabel.text = self.profileObj?.name
//
//                })
//            }
//        }
    }

    override init() {
        super.init()        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
