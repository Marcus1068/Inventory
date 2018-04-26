//
//  EditInventoryViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 19.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class InventoryEditViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    //let context = (UIApplication.shared.delegate as! AppDelegate)
    
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
    
    // get all detail infos
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        os_log("viewDidLoad in InventoryEditViewController", log: OSLog.default, type: .debug)
        
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }

        picker.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(imageTap(recognizer:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        imageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        
        // edit inventory
        if (currentInventory != nil)
        {
            self.title = NSLocalizedString("Edit Inventory", comment: "Edit Inventory")
            
            // inventory name
            textfieldInventoryName.text = currentInventory?.inventoryName
            
            // inventory price
            textfieldPrice.text = String(currentInventory!.price)
            
            // inventory image
            let imageData = currentInventory!.image! as Data
            let image = UIImage(data: imageData, scale:1.0)
            imageView.image = image
        }
        else    // add new inventory
        {
            saveButtonLabel.isEnabled = false
            
            self.title = NSLocalizedString("Add Inventory", comment: "Add Inventory")
            
            // display default data for new empty inventory object
            textfieldInventoryName.text = ""
            textfieldPrice.text = ""
            
            // placeholder graphic
            imageView.image = UIImage(named: "Inventory.png");
        }
        
        // focus on first text field
        textfieldInventoryName.becomeFirstResponder()
        
        // needed for reaction on text fields, e.g. return key
        textfieldInventoryName.delegate = self
        textfieldPrice.delegate = self
        textfieldPrice.keyboardType = UIKeyboardType.numberPad  // allow only numbers to be entered
        
        textfieldInventoryName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControlEvents.editingChanged)
        
        // auto scroll to top so that all text fields can be entered
        registerForKeyboardNotifications()
        
        
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning in InventoryEditViewController", log: OSLog.default, type: .debug)
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // click on image opens camera
    @objc func imageTap(recognizer: UITapGestureRecognizer) {
        os_log("imageTap in InventoryEditViewController", log: OSLog.default, type: .debug)
        
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // save data back to core data
    @IBAction func saveButton(_ sender: Any) {
        
        // add data
        if (currentInventory == nil)
        {
            
            //inventory.inventoryName = textfieldInventoryName.text
            
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)
            //inventory.image = imageData! as NSData
            
            let today = Date() as NSDate // today
            let arr : [UInt32] = [32,4,123,4,5,2]
            let myinvoice = NSData(bytes: arr, length: arr.count * 32)
            
            // FIXME hard coded input
            _ = CoreDataHandler.saveInventory(inventoryName: textfieldInventoryName.text!, dateOfPurchase: today, price: Int32(textfieldPrice.text!)!, remark: "", serialNumber: "", warranty: Int32(textfieldPrice.text!)!, image: imageData! as NSData, invoice: myinvoice, brand: brands[1], category: categories[1], owner: owners[1], room: rooms[1])
            
            
        }
        else{ // edit data
            currentInventory?.inventoryName = textfieldInventoryName.text
            currentInventory?.price = Int32(textfieldPrice.text!)!
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)
            currentInventory?.image = imageData! as NSData
            
            _ = CoreDataHandler.updateInventory(inventory: currentInventory!)
        }
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        os_log("textFieldShouldReturn in InventoryEditViewController", log: OSLog.default, type: .debug)
  /*
        if (textField == textfieldInventoryName)
        {
            textfieldPrice.becomeFirstResponder()
        }
        
 
        if (textField == textfieldPrice)
        {
            self.view.endEditing(true)
        }
    */
        return false
    }
    
    // called for every typed keyboard stroke
    @objc func textIsChanging(_ textField:UITextField) {
        
        // check if inventory name entered, otherwise disable save bar item button
        if textfieldInventoryName.text?.count == 0{
            saveButtonLabel.isEnabled = false
        }
        else{
            saveButtonLabel.isEnabled = true
        }
        
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
        os_log("imagePickerController in InventoryEditViewController", log: OSLog.default, type: .debug)
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        os_log("imagePickerControllerDidCancel in InventoryEditViewController", log: OSLog.default, type: .debug)
        
        dismiss(animated:true, completion: nil)
    }
    
}
