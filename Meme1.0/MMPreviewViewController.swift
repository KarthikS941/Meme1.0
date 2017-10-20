//
//  ViewController.swift
//  Meme1.0
//
//  Created by Karthik Sankar on 9/3/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//

import UIKit

typealias MMImageImporterProtocol = UIImagePickerControllerDelegate & UINavigationControllerDelegate

// Defines Importer Source
enum MMImporterSource: Int {
    case album          // Get Pictures from Album
    case camera         // Get Picture from Camera
}

class MMPreviewViewController: UIViewController {

    @IBOutlet weak var noMemeView: UIView!
    // Outlets
    @IBOutlet weak var memeContainerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var memeBottomTextField: UITextField!
    @IBOutlet weak var memeTopTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    
    // Constraints
    @IBOutlet weak var bottomPanelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tpPanelRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bttPanelBottomConstraint: NSLayoutConstraint!
    
    
    // Global Vars
    let picker = UIImagePickerController()  // Image Picker Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Setup UI
        setupUI()
    }
    
    // Setup UI
    func setupUI() {
        // Set Initial Panel Constraints
        bttPanelBottomConstraint.constant = MMConstants.bottomPanelConstraint_hide
        tpPanelRightConstraint.constant = MMConstants.topPanelConstraint_hide
        
        // Check for Camera Source
        checkForCameraSource()
        view.layoutIfNeeded()
        
        // Add Keyboard dismiss feature
        hideKeyboardWhenTappedAround()
        // Reset text values
        resetTexts()
        // Show Default View
        noMemeView.isHidden = false
    }
    
    // View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        // Add Keyboard Show / Hide Notifications
        addKeyboardNotifications()
    }
    // View Will Disappear
    override func viewDidDisappear(_ animated: Bool) {
        // Remove Keyboard Show / Hide Notifications
        removeKeyboardNotifications()
    }
    
    // for every view appear we cann animate Botton Panel
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate Bottom Panel
        animateBottomPanel()
    }
    
    // Cancel Tapped on Meme Editor
    @IBAction func cancelTapped(_ sender: Any) {
        noMemeView.isHidden = false
        animateEditPanel(show: false)
    }
    // Initialize Camera Modules.
    @IBAction func cameraTapped(_ sender: Any) {
        getImageFrom(source: .camera)
    }
    // Initialize Album Modules
    @IBAction func albumTapped(_ sender: Any) {
        getImageFrom(source: .album)
    }
    // Share Button Tapped
    @IBAction func shareTapped(_ sender: Any) {
        // Create a Meme Image
        let memeImage = MMMemeUtility.generateMemeImageFrom(view: memeContainerView)
        
        // Top Text
        guard let topText = memeTopTextField.text else {
            return
        }
        // Bottom Text
        guard let bottomText = memeBottomTextField.text else {
            return
        }
        
        let currentMeme = MMMeme(topText: topText , bottomText: bottomText , image: memeImage)
        
        // Meme Share Meme
        MMMemeUtility.shareMeme(meme: currentMeme, inViewController: self)
    }
}

// MARK: - View Animations
extension MMPreviewViewController {

    // Animate Bottom Panel
    func animateBottomPanel() {
        bttPanelBottomConstraint.constant = MMConstants.bottomPanelConstraint_show
        animateConstriantWith(duration: 1.3)
    }
    
    // Animate Edit Panel / Top Panel
    func animateEditPanel(show:Bool) {
        if show {
            // Show Animation
            tpPanelRightConstraint.constant = MMConstants.topPanelConstraint_show
        }
        else {
            // Hide Top Panel
            tpPanelRightConstraint.constant = MMConstants.topPanelConstraint_hide
        }
        animateConstriantWith(duration: 1.0)
    }
    
    // Animation Helper Class to perform draw
    func animateConstriantWith(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - Image Importer Methods
extension MMPreviewViewController: MMImageImporterProtocol {
    
    // Checks if current device has camera or not
    func checkForCameraSource() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Camera Not Available
            // Disable Camera Button
            cameraButton.isEnabled = false
            return
        }
        
        // Enable Camera Controls
        cameraButton.isEnabled = true
    }
    
    // Presents Image Source selected . Camera or Gallery
    func getImageFrom(source: MMImporterSource) {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType(rawValue:source.rawValue)!
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    // Picker View Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get Selected Image
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        memeImageView.contentMode = .scaleAspectFit
        memeImageView.image = selectedImage
        // Show Edit Pane
        animateEditPanel(show: true)
        resetTexts()
        noMemeView.isHidden = true
        // Dismiss Picker View Controller
        dismiss(animated:true, completion: nil)
    }
    
    // Picker View Delegate on Cancel Tapped
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss Picker View Controller
        dismiss(animated: true, completion: nil)
    }
    
    // Reset Top and Bottom Meme Text Fields
    func resetTexts() {
        memeTopTextField.text = MMConstants.memeTopDefault
        memeBottomTextField.text = MMConstants.memeBottomDefault
    }
}
