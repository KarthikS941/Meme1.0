//
//  MMMemeUtility.swift
//  Meme1.0
//
//  Created by Karthik Sankar on 9/5/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//
import UIKit

// MARK: - Utility Class
class MMMemeUtility {
    
    // Generate Meme from Container View
    class func generateMemeImageFrom(view: UIView) -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(view.bounds.size)   // Use Bounds to make sure we focus on view boundaries
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    // Share Meme with Friends
    class func shareMeme(meme: MMMeme, inViewController vc: UIViewController) {
        // Create Activity View Controller
        let activityViewController = UIActivityViewController(activityItems: [meme.image ?? "No Image"], applicationActivities: nil)
        // Present Activity View Controller
        vc.present(activityViewController, animated: true, completion: {})
        // Completion of Activity View Controller
        activityViewController.completionWithItemsHandler = { (type,success,items,error) in
            // Save Meme that was shared
            MMCache.sharedMemory.saveShared(meme: meme)
        }
    }
}

// MARK: -Constants
struct MMConstants {
    
    static let bottomPanelConstraint_hide: CGFloat = -80.0      // Bottom Panel Hide Constant
    static let bottomPanelConstraint_show: CGFloat = 20.0       // Bottom Panel Show Constant
    
    static let topPanelConstraint_hide: CGFloat = -140.0        // Top Panel Hide Constant
    static let topPanelConstraint_show: CGFloat = -9.0          // Top Panel Show Constant
    
    static let bottomPanelCameraAvailable: CGFloat = 200        // Bottom Panel if Camera is not available
    static let bottomPanelCameraNotAvailable: CGFloat = 100     // Bottom Panel if Camera is available
    
    static let memeTopDefault = "Top Text"              // Default Text for Meme Top Text Field
    static let memeBottomDefault = "Bottom Text"        // Default Text for Meme Bottom Text Field
}

// MARK: - View Controller Extension
extension UIViewController {
    // Hide Keybaord when tapped outside of view
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap) // Add Gesture to View
    }
    
    // Dismiss Keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Add Notifications for Keyboard Show / Hide
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Function called when Keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            // Get Current Active Text Field , Check if its behind keyboard
            let viewInput = checkIfActiveViewIsBehindKeyboardIn(viewController: self, keyboardHeight: keyboardSize.height)
            
            // If Yes ,Move View up for text field to be visible to user
            if viewInput.isHidden {
                // Get Height of Keyboard
                let totalHeight = keyboardSize.height
                // Get Height of view
                let vewHeight = self.view.frame.size.height - ((viewInput.view?.frame.origin.y)! + (viewInput.view?.frame.size.height)!)
                // Move Distance
                self.view.frame.origin.y -= keyboardSize.height - (totalHeight - vewHeight)
                
                UIView.animate(withDuration: duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // Convenince menthod to check if view is nehind keyboard
    func checkIfActiveViewIsBehindKeyboardIn(viewController vc:UIViewController,keyboardHeight: CGFloat) -> (view: UIView?,isHidden: Bool) {
        // Check if view is active
        if let view = vc.view.currentFirstResponder() {
            let viewY = view.frame.origin.y + view.frame.size.height
            let visibleViewY = vc.view.frame.size.height - keyboardHeight
            
            if viewY > visibleViewY {
                // View is Behind Keyboard
                return (view,true)
            }
        }
        
        return (nil,false)
    }
    
    // Function called when Keyboard hidden notification is received
    func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        self.view.frame.origin.y = 0        // Move to original position
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Remove Keyboard Show / Hide Notification
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

// MARK : - View Extension
extension UIView {
    // Get Current First Responder
    func currentFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        // Loop through all subviews
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
