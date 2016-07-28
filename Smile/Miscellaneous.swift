//
//  Miscellaneous.swift
//  Smile
//
//  Created by Phil Dzugan on 5/15/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit

// MARK: - PROTOCOLS

protocol DestinationViewControllerDelegate {
    func readyToDisappearDestinationViewController(destinationViewController: UIViewController, didPassObject object: Any)
}

// MARK: FUNCTIONS

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func displayMessage(message: String, forTitle title: String, onViewController viewController: UIViewController) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    viewController.presentViewController(ac, animated: true, completion: nil)
}

func convertImage(image: UIImage, andWriteToFilename filename: String) -> NSError? {
    // Convert image to NSData object and write to documents directory
    let path = getDocumentsDirectory().stringByAppendingPathComponent(filename)
    if let jpegData = UIImageJPEGRepresentation(image, 1.0) {
        do {
            try jpegData.writeToFile(path, options: .DataWritingAtomic)
        } catch let error as NSError {
            return error
        }
    }
    
    return nil
}


























