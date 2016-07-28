//
//  AppMenuTableViewController.swift
//  Smile
//
//  Created by Phil Dzugan on 5/11/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol AppMenuTableViewControllerDelegate {
    func selectionMadeForIdentifier(identifier: String)
}


class AppMenuTableViewController: UITableViewController {
    
    var delegate: AppMenuTableViewControllerDelegate?
    let appMenuData = AppMenuData()
    
    // Set the selected index path to the first row
    var selectedIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    // Cool fonts:
    //     Chalkduster
    //     MarkerFelt-Wide
    //     Futura-CondensedExtraBold
    var navigationBarTitleTextAttributes: [String : AnyObject] = [
        NSFontAttributeName: UIFont(name: "Chalkduster", size: 18)!,
        NSForegroundColorAttributeName: UIColor.whiteColor()
    ]

    // MARK: - METHODS: Overridden
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Set the navigation bar title's font and text color
        navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
        
        tableView.separatorColor = UIColor.blackColor()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(sessionDidChangeStateToConnected), name: Notification.SessionDidChangeStateToConnected.rawValue, object: nil)
        nc.addObserver(self, selector: #selector(sessionDidChangeStateToNotConnected), name: Notification.SessionDidChangeStateToNotConnected.rawValue, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Select the row
        tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DATA SOURCE: UITableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return appMenuData.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appMenuData.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("App Menu Cell", forIndexPath: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = appMenuData.objectAtSection(indexPath.section, row: indexPath.row)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return appMenuData.sectionNames[section]
    }
    
    // MARK: - DELEGATE: UITableView
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)   // Very dark gray color
        
        if indexPath.section == appMenuData.connectedFriendsSection {
            cell.selectionStyle = .None
//            cell.textLabel?.textColor = UIColor.yellowColor()
            cell.textLabel?.textColor = UIColor.greenColor()
//            cell.textLabel?.textColor = UIColor.cyanColor()
//            cell.textLabel?.textColor = UIColor(red: 64.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)   // Fern color
//            cell.textLabel?.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)   // Clover color
//            cell.textLabel?.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 64.0/255.0, alpha: 1.0)   // Moss color
//            cell.textLabel?.textColor = UIColor(red: 128.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)   // Lime color
        } else {
            cell.textLabel?.textColor = UIColor.whiteColor()
        }
    
        // Change the selected background color of the cell
        let selectedBackgroundView = UIImageView(frame: cell.frame)
//        selectedBackgroundView.backgroundColor = UIColor(red: 0.0/255.0, green: 111.0/255.0, blue: 255.0/255.0, alpha: 1.0)   // Blue color
        selectedBackgroundView.backgroundColor = UIColor(red: 155.0/255.0, green: 133.0/255.0, blue: 166.0/255.0, alpha: 1.0)   // Mauve color
        cell.selectedBackgroundView = selectedBackgroundView
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Change the header view background color to black and text color to dark gray
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.blackColor()
        headerView.textLabel?.textColor = UIColor.darkGrayColor()
        
//        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
//        tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == appMenuData.connectedFriendsSection {
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set selected index path so if view disappears (when a modal view is opened),
        // the row will be selected again in the viewDidAppear method
        selectedIndexPath = indexPath
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let identifier = cell.textLabel?.text {
//                let identifier: String
//                switch text {
//                case "Album":
//                    identifier = text
//                case "Find Friends":
//                    identifier = text
//                default:
//                    identifier = "Blank"
//                }
                delegate?.selectionMadeForIdentifier(identifier)
            }
        }
    }
    
    // MARK: Notifications
    
    func sessionDidChangeStateToConnected(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
            self.tableView.selectRowAtIndexPath(self.selectedIndexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func sessionDidChangeStateToNotConnected(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
            self.tableView.selectRowAtIndexPath(self.selectedIndexPath, animated: false, scrollPosition: .None)
        }
    }
}

























