//
//  AlbumCollectionViewController.swift
//  Smile
//
//  Created by Phil Dzugan on 5/14/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

private let reuseIdentifier = "Picture Cell"

struct FilterSegueObject {
    var pictureTitle: String
    var image: UIImage
    var shouldSaveEditedImage: Bool
}

class AlbumCollectionViewController: UICollectionViewController, DestinationViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPCManagerDelegate, AppMPCManagerDelegate {
    
    var pictures = [Picture]()
    var selectedPictureIndex = 0
    
    var filterSegueObject: FilterSegueObject!
    
    let mpcManager = AppMPCManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        // Set up right bar button items
        var rightBarButtonItems = [UIBarButtonItem]()
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addPicture))
        rightBarButtonItems.append(addBarButtonItem)
        // Add camera bar button item if the device has camera
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(AlbumCollectionViewController.takePicture))
            rightBarButtonItems.append(cameraBarButtonItem)
        }
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        // Read pictures from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let picturesData = defaults.objectForKey("pictures") as? NSData {
            pictures = NSKeyedUnarchiver.unarchiveObjectWithData(picturesData) as! [Picture]
        }
        
        mpcManager.delegate = self
        mpcManager.appDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DATA SOURCE: UICollectionView

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PictureCell
        
        let picture = pictures[indexPath.item]
    
        // Configure the cell
        cell.label.text = picture.title
        
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(picture.imageFilename)
        cell.imageView.image = UIImage(contentsOfFile: imagePath)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }

    // MARK: - DELEGATE: UICollectionView
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedPictureIndex = indexPath.item
        let pictureTitle = pictures[selectedPictureIndex].title
        
        let ac = UIAlertController(title: pictureTitle, message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Rename", style: .Default, handler: handleRename))
        ac.addAction(UIAlertAction(title: "Filter", style: .Default, handler: handleFilter))
        ac.addAction(UIAlertAction(title: "Save to Photos", style: .Default, handler: handleSaveToPhotos))
        ac.addAction(UIAlertAction(title: "Send to Friends", style: .Default, handler: handleSendToFriends))
        ac.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: handleDelete))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - DELEGATE: UIImagePicker
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let newImage: UIImage
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // Create universally unique identifier for image filename
        let imageFilename = NSUUID().UUIDString
        let error = convertImage(newImage, andWriteToFilename: imageFilename)
        if let error = error {
            displayMessage(error.localizedDescription, forTitle: "ERROR writing image file to documents directory!", onViewController: self)
        }
        
        let picture = Picture(title: "Unknown", imageFilename: imageFilename)
        pictures.append(picture)
        collectionView?.reloadData()
        savePictures()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - DELEGATE: DestinationViewController
    
    func readyToDisappearDestinationViewController(destinationViewController: UIViewController, didPassObject object: Any) {
        filterSegueObject = object as! FilterSegueObject
        
        destinationViewController.dismissViewControllerAnimated(true, completion: nil)
        
        if filterSegueObject.shouldSaveEditedImage {
            let error = convertImage(filterSegueObject.image, andWriteToFilename: pictures[selectedPictureIndex].imageFilename)
            if let error = error {
                displayMessage(error.localizedDescription, forTitle: "ERROR writing image file to documents directory!", onViewController: self)
            }
            collectionView?.reloadData()
        }
    }
    
    // MARK: - DELEGATE: MPCManager
    
    func sessionDidChangeStateToConnectedForPeer(peer: MCPeerID) {
    }
    
    func sessionDidChangeStateToNotConnectedForPeer(peer: MCPeerID) {
    }
    
    func browserFoundPeer(peer: MCPeerID) {
    }
    
    func browserLostPeer(peer: MCPeerID) {
    }
    
    func advertiserDidReceiveInvitationFromPeerForAlertController(ac: UIAlertController) {
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: - DELEGATE: AppMPCManager
    
    func sessionDidReceiveDataForPicture(picture: Picture?, withError error: NSError?) {
        // When data is received, it might not be on the main thread
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            if let error = error {
                displayMessage(error.localizedDescription, forTitle: "ERROR writing image file to documents directory!", onViewController: self)
            } else {
                if let picture = picture {
                    self.pictures.append(picture)
                }
                self.collectionView?.reloadData()
            }
        }
    }
    
    // MARK: - SEGUE
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Filter Segue" {
            let filterViewController = (segue.destinationViewController as! UINavigationController).topViewController as! FilterViewController
            filterViewController.destinationViewControllerDelegate = self
            
            let picture = pictures[selectedPictureIndex]
            let indexPath = NSIndexPath(forRow: selectedPictureIndex, inSection: 0)
            let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! PictureCell
            filterSegueObject = FilterSegueObject(pictureTitle: picture.title, image: cell.imageView.image!, shouldSaveEditedImage: false)
            filterViewController.filterSegueObject = filterSegueObject
        }
    }
    
    // MARK: - ACTIONS & HANDLERS
    
    func addPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func takePicture() {
        let picker = UIImagePickerController()
        picker.sourceType = .Camera
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func handleRename(action: UIAlertAction) {
        let ac = UIAlertController(title: "Rename Picture", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler() { [unowned self] (textField: UITextField) in
            textField.text = self.pictures[self.selectedPictureIndex].title
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "OK", style: .Default) { [unowned self, ac] _ in
            let textField = ac.textFields![0]
            self.pictures[self.selectedPictureIndex].title = textField.text ?? ""
            self.collectionView?.reloadData()
            self.savePictures()
        })
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func handleFilter(action: UIAlertAction) {
        performSegueWithIdentifier("Filter Segue", sender: self)
    }
    
    func handleSaveToPhotos(action: UIAlertAction) {
        let indexPath = NSIndexPath(forRow: selectedPictureIndex, inSection: 0)
        let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! PictureCell
        
        // UIKit function to save image to Photos album
        UIImageWriteToSavedPhotosAlbum(cell.imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func handleSendToFriends(action: UIAlertAction) {
        // Check if there are any friends to send to
        if mpcManager.session.connectedPeers.isEmpty {
            displayMessage("Go to \"Find Friends\" on the app menu.", forTitle: "Not Connected With Any Friends!", onViewController: self)
        } else {
            // Convert the image to a NSData object
            // png or jpeg ?????
            let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(pictures[selectedPictureIndex].imageFilename)
//            if let imageData = UIImagePNGRepresentation(UIImage(contentsOfFile: imagePath)!) {
            if let imageData = UIImageJPEGRepresentation(UIImage(contentsOfFile: imagePath)!, 1.0) {
                do {
                    try mpcManager.session.sendData(imageData, toPeers: mpcManager.session.connectedPeers, withMode: .Reliable)
                } catch let error as NSError {
                    displayMessage(error.localizedDescription, forTitle: "ERROR Sending Picture To Friends!", onViewController: self)
                }
            }
        }
    }
    
    func handleDelete(action: UIAlertAction) {
        let ac = UIAlertController(title: "Delete Picture", message: "Are you sure you want to delete \"\(pictures[selectedPictureIndex].title)\"?", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Delete", style: .Destructive) { [unowned self] _ in
            // Delete image file from documents directory
            let fileManager = NSFileManager.defaultManager()
            let imageFilename = self.pictures[self.selectedPictureIndex].imageFilename
            let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageFilename)
            do {
                try fileManager.removeItemAtPath(imagePath)
            } catch let error as NSError {
                displayMessage(error.localizedDescription, forTitle: "ERROR deleting image file from documents directory!", onViewController: self)
            }
            
            self.pictures.removeAtIndex(self.selectedPictureIndex)
            self.collectionView?.reloadData()
            self.savePictures()
        })
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: - METHODS: Internal
    
    func savePictures() {
        let picturesData = NSKeyedArchiver.archivedDataWithRootObject(pictures)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(picturesData, forKey: "pictures")
    }
    
    // Handle any errors from UIKit function image(_:didFinishSavingWithError:contextInfo:)
    // that is run in handleSaveToPhotos(_:) method
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved to Photos", message: "Picture of \"\(pictures[selectedPictureIndex].title)\" has been saved to Photos album.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "ERROR Saving \"\(pictures[selectedPictureIndex].title)\" Picture to Photos! ", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
}

























