//
//  Picture.swift
//  Smile
//
//  Created by Phil Dzugan on 5/15/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit

class Picture: NSObject, NSCoding {
    
    var title: String
    var imageFilename: String
    
    init(title: String, imageFilename: String) {
        self.title = title
        self.imageFilename = imageFilename
    }
    
    // The following methods are needed to conform to the NSCoding protocol
    
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        imageFilename = aDecoder.decodeObjectForKey("imageFilename") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(imageFilename, forKey: "imageFilename")
    }
}
