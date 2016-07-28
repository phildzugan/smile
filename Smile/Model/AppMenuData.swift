//
//  AppMenuData.swift
//  Smile
//
//  Created by Phil Dzugan on 5/12/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import Foundation

struct AppMenuData {
    
    let sectionNames = ["", "CONNECTED FRIENDS"]
    let sectionNumbers = [0, 1]
    
    let itemNames = ["Album", "Find Friends"]
    let itemSections = [0, 0]
    let itemRows = [0, 1]
    
    let connectedFriendsSection = 1
    
    let mpcManager = AppMPCManager.sharedInstance
    
    // MARK: - METHODS
    
    func numberOfSections() -> Int {
        return sectionNames.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == connectedFriendsSection {
            return mpcManager.session.connectedPeers.count
        } else {
            let itemSectionsCountedSet = NSCountedSet(array: itemSections)
            return itemSectionsCountedSet.countForObject(section)
        }
    }
    
    func objectAtSection(section: Int, row: Int) -> String {
        if section == connectedFriendsSection {
            return mpcManager.session.connectedPeers[row].displayName
        } else {
            for (index, value) in itemSections.enumerate() {
                if value == section && itemRows[index] == row {
                    return itemNames[index]
                }
            }
        }
        
        return ""
    }
}