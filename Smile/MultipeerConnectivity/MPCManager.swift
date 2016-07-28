//
//  MPCManager.swift
//  Smile
//
//  Created by Phil Dzugan on 5/26/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

//import Foundation
import UIKit
import MultipeerConnectivity


protocol MPCManagerDelegate {
    func sessionDidChangeStateToConnectedForPeer(peer: MCPeerID)
    func sessionDidChangeStateToNotConnectedForPeer(peer: MCPeerID)
    func browserFoundPeer(peer: MCPeerID)
    func browserLostPeer(peer: MCPeerID)
    func advertiserDidReceiveInvitationFromPeerForAlertController(ac: UIAlertController)
}


private let serviceType = "phil-smile"


class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var delegate: MPCManagerDelegate?
    
    var peer: MCPeerID!
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var nearbyPeers = Set<MCPeerID>()
    var sortedNearbyPeers = [MCPeerID]()
    var advertiserIsOn = false
    
    var invitationHandler: ((Bool, MCSession) -> Void)!
    
    // MARK: - SINGLETON
    
//    static let sharedInstance = MPCManager()
    
    // MARK: - METHODS: Overridden
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        // Service type is a 1-15 character string that uniquely identifies the application.
        // It can contain only lowercase letters (a-z), numbers and hyphens,
        // and usually includes a reference to your company.
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
    }
    
    // MARK: - DELEGATE: MCSession
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // Required but not using
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Required but not using
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        // Required but not using
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        // Required but not using
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            print("Connected: \(peerID.displayName)")
            delegate?.sessionDidChangeStateToConnectedForPeer(peerID)
        case .Connecting:
            print("Connecting: \(peerID.displayName)")
        case .NotConnected:
            print("Not Connected: \(peerID.displayName)")
            delegate?.sessionDidChangeStateToNotConnectedForPeer(peerID)
        }
    }
    
    // MARK: - DELEGATE: MCNearbyServiceBrowser
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Browser found peer: \(peerID.displayName)")
        nearbyPeers.insert(peerID)
        sortNearbyPeers()
        delegate?.browserFoundPeer(peerID)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Browser lost peer: \(peerID.displayName)")
        
        if nearbyPeers.contains(peerID) {
            nearbyPeers.remove(peerID)
        }
        sortNearbyPeers()
        delegate?.browserLostPeer(peerID)
    }
    
    // MARK: - DELEGATE: MCNearbyServiceAdvertiser
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        let ac = UIAlertController(title: "Multipeer Connectivity", message: "\"\(peerID.displayName)\" wants to connect with you.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .Default) { [unowned self] _ in
            invitationHandler(true, self.session)
            })
        ac.addAction(UIAlertAction(title: "Decline", style: .Cancel) { [unowned self] _ in
            invitationHandler(false, self.session)
            })
        
        delegate?.advertiserDidReceiveInvitationFromPeerForAlertController(ac)
    }
    
    // MARK: - METHODS: Private
    
    private func sortNearbyPeers() {
        sortedNearbyPeers = Array(nearbyPeers).sort { $0.displayName < $1.displayName }
    }
}

























