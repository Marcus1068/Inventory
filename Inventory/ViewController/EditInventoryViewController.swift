//
//  EditInventoryViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 19.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class EditInventoryViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var cancelButtonLabel: UIBarButtonItem!
    @IBOutlet weak var saveButtonLabel: UIBarButtonItem!
    
    @IBOutlet weak var labelInventoryName: UILabel!
    @IBOutlet weak var textfieldInventoryName: UITextField!
    
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var textfieldPrice: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    // contains the selected object from viewcontroller before
    weak var currentInventory : Inventory?
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        os_log("viewDidLoad in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        super.viewDidLoad()

        picker.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(imageTap(recognizer:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        imageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        
        // edit data or add data
        if (currentInventory != nil)
        {
            self.title = NSLocalizedString("Edit Inventory", comment: "Edit Inventory")
            textfieldInventoryName.text = currentInventory?.inventoryName
            //imageView.image =
            
            let imageData = currentInventory!.image! as Data
            let image = UIImage(data: imageData, scale:1.0)
            imageView.image = image
        }
        else
        {
            self.title = NSLocalizedString("Add Inventory", comment: "Add Inventory")
            
            textfieldInventoryName.text = ""
        }
        
        // focus on first text field
        textfieldInventoryName.becomeFirstResponder()
        
        // needed for reaction on text fields, e.g. return key
        textfieldInventoryName.delegate = self
        textfieldPrice.delegate = self
        
        // auto scroll to top so that all text fields can be entered
        registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // click on image opens camera
    @objc func imageTap(recognizer: UITapGestureRecognizer) {
        os_log("imageTap in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        os_log("cancelButton in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        os_log("saveButton in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)
        currentInventory?.image = imageData! as NSData
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        os_log("textFieldShouldReturn in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        if (textField == textfieldInventoryName)
        {
            textfieldPrice.becomeFirstResponder()
        }
        
 
        if (textField == textfieldPrice)
        {
            self.view.endEditing(true)
        }
    
        return false
    }
    
    // takes care of scrolling content top for the size of the current displayed keyboard
    // uses scrollView
    // will be called from viewDidLoad()
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWasShown(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification){
        guard let info = notification.userInfo,
            let keyBoardFrameValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {return}
        
        let keyboardFrame = keyBoardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification){
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Delegates
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        os_log("imagePickerController in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        os_log("imagePickerControllerDidCancel in EditInventoryViewController", log: OSLog.default, type: .debug)
        
        dismiss(animated:true, completion: nil)
    }
    
}
