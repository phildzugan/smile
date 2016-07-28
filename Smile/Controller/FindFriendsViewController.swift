//
//  FindFriendsViewController.swift
//  Smile
//
//  Created by Phil Dzugan on 6/1/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MPCManagerDelegate {
    
    @IBOutlet weak var imVisibleSwitch: UISwitch!
    @IBOutlet weak var nearbyFriendsTableView: UITableView!
    
    let mpcManager = AppMPCManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        mpcManager.delegate = self
        mpcManager.browser.startBrowsingForPeers()
        
        if mpcManager.advertiserIsOn {
            imVisibleSwitch.on = true
        } else {
            imVisibleSwitch.on = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DATA SOURCE: UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mpcManager.sortedNearbyPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Nearby Friends Cell", forIndexPath: indexPath)
        cell.textLabel?.text = mpcManager.sortedNearbyPeers[indexPath.row].displayName
        
        if mpcManager.session.connectedPeers.contains(mpcManager.sortedNearbyPeers[indexPath.row]) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // MARK: - DELEGATE: UITableView
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == .Checkmark {
            mpcManager.session.disconnect()
        } else {
            mpcManager.browser.invitePeer(mpcManager.sortedNearbyPeers[indexPath.row], toSession: mpcManager.session, withContext: nil, timeout: 30)
        }
    }
    
    // MARK: DELEGATE: MPCManager
    
    func sessionDidChangeStateToConnectedForPeer(peer: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.nearbyFriendsTableView.reloadData()
        }
    }
    
    func sessionDidChangeStateToNotConnectedForPeer(peer: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.nearbyFriendsTableView.reloadData()
        }
    }
    
    func browserFoundPeer(peer: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.nearbyFriendsTableView.reloadData()
        }
    }
    
    func browserLostPeer(peer: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.nearbyFriendsTableView.reloadData()
        }
    }
    
    func advertiserDidReceiveInvitationFromPeerForAlertController(ac: UIAlertController) {
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: ACTIONS & HANDLERS
    
    @IBAction func handleImVisible(sender: UISwitch) {
        if sender.on {
            mpcManager.advertiser.startAdvertisingPeer()
            mpcManager.advertiserIsOn = true
        } else {
            mpcManager.advertiser.stopAdvertisingPeer()
            mpcManager.advertiserIsOn = false
        }
    }
}

























