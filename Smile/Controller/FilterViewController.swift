//
//  FilterViewController.swift
//  Smile
//
//  Created by Phil Dzugan on 5/19/16.
//  Copyright © 2016 Phil Dzugan. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var changeFilterButton: UIButton!
    
    var destinationViewControllerDelegate: DestinationViewControllerDelegate?
    
    var filterSegueObject: FilterSegueObject!
    
    var filterNames: [(name: String, display: String)] = [
        ("CIBumpDistortion", "Bump Distortion"),
        ("CIGaussianBlur", "Gaussian Blur"),
        ("CIPixellate", "Pixellate"),
        ("CISepiaTone", "Sepia Tone"),
        ("CITwirlDistortion", "Twirl Distortion"),
        ("CIUnsharpMask", "Unsharp Mask"),
        ("CIVignette", "Vignette")
    ]
    
    var ciContext: CIContext!
    
    var ciFilter: CIFilter! {
        didSet {
            for case (ciFilter.name, let display) in filterNames {
                changeFilterButton.setTitle("Change \(display) Filter", forState: .Normal)
            }
        }
    }
    
    // MARK: - METHODS: Overridden
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = filterSegueObject.pictureTitle
        imageView.image = filterSegueObject.image
        
        ciContext = CIContext(options: nil)
        setFilter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS & HANDLERS

    @IBAction func handleCancel(sender: UIBarButtonItem) {
        destinationViewControllerDelegate?.readyToDisappearDestinationViewController(self, didPassObject: filterSegueObject)
    }
    
    @IBAction func handleSave(sender: UIBarButtonItem) {
        filterSegueObject.image = imageView.image!
        filterSegueObject.shouldSaveEditedImage = true
        destinationViewControllerDelegate?.readyToDisappearDestinationViewController(self, didPassObject: filterSegueObject)
    }
    
    @IBAction func intensityChanged(sender: UISlider) {
        processImage()
    }
    
    @IBAction func changeFilter(sender: UIButton) {
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .ActionSheet)
        for (_, display) in filterNames {
            ac.addAction(UIAlertAction(title: display, style: .Default, handler: setFilter))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func setFilter(action: UIAlertAction? = nil) {
        var filterName = ""
        if action == nil {
            // Read filter name from NSUserDefaults
            let defaults = NSUserDefaults.standardUserDefaults()
            filterName = defaults.stringForKey("filterName") ?? "CISepiaTone"
        } else {
            for case (let name, action!.title!) in filterNames {
                filterName = name
                
                // Write filter name to NSUserDefaults
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(filterName, forKey: "filterName")
                
                break
            }
        }
        ciFilter = CIFilter(name: filterName)
        let ciImage = CIImage(image: filterSegueObject.image)
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        processImage()
    }
    
    // MARK: - METHODS: Internal
    
    func processImage() {
        let inputKeys = ciFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { ciFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { ciFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { ciFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { ciFilter.setValue(CIVector(x: filterSegueObject.image.size.width / 2, y: filterSegueObject.image.size.height / 2), forKey: kCIInputCenterKey) }
        
        let cgImage = ciContext.createCGImage(ciFilter.outputImage!, fromRect: ciFilter.outputImage!.extent)
        let processedImage = UIImage(CGImage: cgImage)
        imageView.image = processedImage
    }
}

























