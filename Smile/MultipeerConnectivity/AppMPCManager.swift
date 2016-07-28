//
//  AppMPCManager.swift
//  Smile
//
//  Created by Phil Dzugan on 6/24/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum Notification: String {
    case SessionDidChangeStateToConnected
    case SessionDidChangeStateToNotConnected
}

protocol AppMPCManagerDelegate {
    func sessionDidReceiveDataForPicture(picture: Picture?, withError error: NSError?)
}

class AppMPCManager: MPCManager {
    
    var appDelegate: AppMPCManagerDelegate?
    
    // MARK: SINGLETON
    
    static let sharedInstance = AppMPCManager()
    
    // MARK: - METHODS: Overridden
    
    override func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            let imageFilename = NSUUID().UUIDString
            let error = convertImage(image, andWriteToFilename: imageFilename)
            if let error = error {
                appDelegate?.sessionDidReceiveDataForPicture(nil, withError: error)
            } else {
                let picture = Picture(title: "Unknown", imageFilename: imageFilename)
                var pictures = [Picture]()
                
                // Read pictures from NSUserDefaults
                let defaults = NSUserDefaults.standardUserDefaults()
                if let picturesData = defaults.objectForKey("pictures") as? NSData {
                    pictures = NSKeyedUnarchiver.unarchiveObjectWithData(picturesData) as! [Picture]
                }
                
                pictures.append(picture)
                
                // Write pictures to NSUserDefaults
                let picturesData = NSKeyedArchiver.archivedDataWithRootObject(pictures)
                defaults.setObject(picturesData, forKey: "pictures")
                
                appDelegate?.sessionDidReceiveDataForPicture(picture, withError: nil)
            }
        }
    }
    
    override func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        super.session(session, peer: peerID, didChangeState: state)
        
        switch state {
        case .Connected:
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(Notification.SessionDidChangeStateToConnected.rawValue, object: nil)
        case .Connecting:
            break
        case .NotConnected:
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(Notification.SessionDidChangeStateToNotConnected.rawValue, object: nil)
        }
    }
}
























