//
//  ParentViewController.swift
//  Smile
//
//  Created by Phil Dzugan on 5/11/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit

private let firstTopChildIdentifier = "Album"

class ParentViewController: UIViewController, UIGestureRecognizerDelegate, AppMenuTableViewControllerDelegate {
    
    var bottomChildIsVisible = false
    var currentTopChildIdentifier = firstTopChildIdentifier
    var incomingTopChildIdentifier = firstTopChildIdentifier
    var userInteractionEnabledForSubviews = [Bool]()
    var tapGestureRecognizer = UITapGestureRecognizer()
    var rightSwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    // MARK: - METHODS: Overridden

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show bottom (menu) child view controller
        let bottomChildViewController = (storyboard!.instantiateViewControllerWithIdentifier("App Menu"))
        addChildViewController(bottomChildViewController)
        view.addSubview(bottomChildViewController.view)
        bottomChildViewController.didMoveToParentViewController(self)
        
        // The bottom child view controller is a navigation controller.
        // The navigation controller's top view controller is AppMenuTableViewController.
        // Set the AppMenuTableViewController's delegate to this ParentViewController (self).
        let appMenuTableViewController = (bottomChildViewController as! UINavigationController).topViewController as! AppMenuTableViewController
        appMenuTableViewController.delegate = self
        
        // Show top child view controller
        let topChildViewController = setUpTopChildViewControllerWithIdentifier(firstTopChildIdentifier)
        addChildViewController(topChildViewController)
        view.addSubview(topChildViewController.view)
        topChildViewController.didMoveToParentViewController(self)
        
        // Set up tap gesture recognizer
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        // The number of fingers that must be on the screen
        tapGestureRecognizer.numberOfTouchesRequired = 1
        // The total number of taps to be performed before the gesture is recognized
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up right swipe gesture recognizer
        rightSwipeGestureRecognizer.addTarget(self, action: #selector(handleRightSwipe(_:)))
        rightSwipeGestureRecognizer.direction = .Right
        // The number of fingers that must be on the screen
        rightSwipeGestureRecognizer.numberOfTouchesRequired = 1
        rightSwipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set status bar style to white content.
    // This method needs to be overridden on the ParentViewController as
    // the image picker controller changes the status bar and
    // the top most navigation view controller will be queried for the preferredStatusBarStyle
    // after the image picker controller is dismissed.
    // Note that the following can no longer be done application-wide:
    //     Set the "Status Bar Style" to "Light" on Target->General->Deployment Info
    //     Set the "View controller-based status bar appearance" to "NO"
    // Also set the navigation bar style
    // (especially on navigation controllers that are presented modally)
    // to "Black" in the storyboard.
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
//    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        let message: String
//        switch newCollection.verticalSizeClass {
//        case .Regular:
//            // iPhone is changing to portrait orientation
//            message = "Flipping to portrait"
//        case .Compact:
//            // iPhone is changing to landscape orientation
//            message = "Flipping to landscape"
//        default:
//            message = "Flipping to ?"
//        }
//        print(message)
//    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // iPhone is changing portrait/landscape orientation
        if bottomChildIsVisible {
            // Re-position top child view controller
            // by subtracting old width (height) from new width
            // and adding the result to the center x position
            let topChildViewController = childViewControllers[1]
            topChildViewController.view.center.x += (size.width - size.height)
        }
    }
    
    // MARK: - DELEGATE: AppMenuTableViewController
    
    func selectionMadeForIdentifier(identifier: String) {
        incomingTopChildIdentifier = identifier
        slideTopChildViewController()
    }
    
    // MARK: - DELEGATE: UIGestureRecognizer
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let window = UIApplication.sharedApplication().keyWindow!
        let touchPoint = touch.locationInView(window)
        let windowWidth = window.frame.size.width
        
        // Only allow gestures if the app menu is visible
        // and the touch occus on the right hand side of the screen,
        // or if the app menu is not visible
        // and the touch occurs on the view of the top view controller
        // of the top child view navigation controller
        // and the gesture recognizer is the right swipe gesture recognizer
        let topChildViewController = childViewControllers[1]
        if bottomChildIsVisible && (windowWidth - touchPoint.x) <= 44.0 {
            return true
        } else if !bottomChildIsVisible && touch.view == (topChildViewController as! UINavigationController).topViewController?.view && gestureRecognizer == rightSwipeGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - GESTURES
    
    func handleTap(sender: UITapGestureRecognizer) {
        slideTopChildViewController()
    }
    
    func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        slideTopChildViewController()
    }

    // MARK: - METHODS: Private
    
    private func setUpTopChildViewControllerWithIdentifier(identifier: String) -> UIViewController {
        let topChildViewController = storyboard!.instantiateViewControllerWithIdentifier(identifier)
        
        // All incoming top child view controllers will be navigation controllers
        // so that the Menu bar button item can be added
        let menuBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: self, action: #selector(slideTopChildViewController))
        let topViewController = (topChildViewController as! UINavigationController).topViewController
        topViewController?.navigationItem.leftBarButtonItem = menuBarButtonItem
        
        return topChildViewController
    }
    
    // MARK: METHODS: Internal
    
    func slideTopChildViewController() {
        if bottomChildIsVisible {
            if currentTopChildIdentifier == incomingTopChildIdentifier {
                // The top child view controller is not changing.
                // It's view is now on the right hand side of the screen.
                // Animate this view to move to the left and cover the entire screen.
                let topChildViewController = childViewControllers[1]
                UIView.animateWithDuration(0.5, animations: { [unowned self] in
                    topChildViewController.view.center.x = self.view.center.x
                }) { [unowned self] (value: Bool) in
                    // Reapply UserInteractionEnabled setting for each subview
                    // of the top child view controller view
                    if let topChildView = (topChildViewController as! UINavigationController).topViewController?.view {
                        for (index, subview) in topChildView.subviews.enumerate() {
                        subview.userInteractionEnabled = self.userInteractionEnabledForSubviews[index]
                        }
                    }
                }
            } else {
                // The top child view controller is changing.
                // It's current view is now on the right hand side of the screen.
                // Animate this view to move off the screen to the right.
                // Animate the incoming view to move left from off the screen on the right
                // to cover the entire screen.
                switchTopChildViewController()
            }
        } else {
            // The top child view controller's view is now covering the entire screen.
            // Animate this view to move to the far right of the screen.
            let topChildViewController = childViewControllers[1]
            UIView.animateWithDuration(0.5, animations: { [unowned self] in
                topChildViewController.view.center.x += (self.view.bounds.width - 44.0)
            }) { [unowned self] (value: Bool) in
                // Ignor user events such as touch on the subviews of the
                // top child view controller view.
                // Save UserInteractionEnabled setting for each subview
                // so that these can be reapplied if the same view is made full screen.
                if let topChildView = (topChildViewController as! UINavigationController).topViewController?.view {
                    self.userInteractionEnabledForSubviews.removeAll()
                    for subview in topChildView.subviews {
                        if subview.userInteractionEnabled {
                            self.userInteractionEnabledForSubviews.append(true)
                            subview.userInteractionEnabled = false
                        } else {
                            self.userInteractionEnabledForSubviews.append(false)
                        }
                    }
                }
            }
        }
        
        bottomChildIsVisible = !bottomChildIsVisible
    }
    
    func switchTopChildViewController() {
        let incomingViewController = setUpTopChildViewControllerWithIdentifier(incomingTopChildIdentifier)
        let outgoingViewController = childViewControllers[1]
        
        UIView.animateWithDuration(0.2, animations: {
            outgoingViewController.view.center.x += 44.0
        }) { [unowned self] (value: Bool) in
            outgoingViewController.view.removeFromSuperview()
            outgoingViewController.removeFromParentViewController()
            self.addChildViewController(incomingViewController)
            self.view.addSubview(incomingViewController.view)
            incomingViewController.didMoveToParentViewController(self)
            incomingViewController.view.center.x += self.view.bounds.width
            UIView.animateWithDuration(0.6) { [unowned self] in
                incomingViewController.view.center.x = self.view.center.x
            }
            self.bottomChildIsVisible = false
            self.currentTopChildIdentifier = self.incomingTopChildIdentifier
        }
    }
}




















