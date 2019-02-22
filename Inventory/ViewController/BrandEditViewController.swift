//
//  BrandEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class BrandEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var textfieldBrand: UITextField!
    
    // contains the selected object from viewcontroller before
    weak var currentBrand : Brand?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // edit or add brand
        if currentBrand != nil{
            //
            self.title = NSLocalizedString("Edit Brand", comment: "Edit Brand")
            textfieldBrand.text = currentBrand!.brandName
        }
        else{
            self.title = NSLocalizedString("Add Brand", comment: "Add Brand")
            textfieldBrand.text = ""
            saveButtonOutlet.isEnabled = false
        }
        
        // focus on first text field
        textfieldBrand.becomeFirstResponder()
        textfieldBrand.delegate = self
        textfieldBrand.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldBrand.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        textfieldBrand.placeholder = "Brand"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //os_log("textFieldShouldReturn", log: OSLog.default, type: .debug)
        
        if (textField == textfieldBrand)
        {
            // close keyboard
            self.view.endEditing(true)
        }
        
        return false
    }
    
    @objc func textDidChange(_ textField:UITextField) {
        
    }
    
    // called for every typed keyboard stroke
    @objc func textIsChanging(_ textField:UITextField) {
        
        if textfieldBrand.text?.count == 0{
            saveButtonOutlet.isEnabled = false
        }
        else{
            saveButtonOutlet.isEnabled = true
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // save or update
    @IBAction func saveButton(_ sender: Any) {
        // close keyboard
        self.view.endEditing(true)
        
        // new brand
        if (currentBrand == nil)
        {
            if CoreDataHandler.fetchBrand(brandName: textfieldBrand.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldBrand.becomeFirstResponder()
            }
            else{
                let context = CoreDataHandler.getContext()
                
                let brand = Brand(context: context)
                
                // set object with UI values
                brand.brandName = textfieldBrand.text!
                
                currentBrand = brand
                
                _ = CoreDataHandler.saveBrand(brand: currentBrand!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{
            currentBrand?.brandName = textfieldBrand.text
            
            _ = CoreDataHandler.saveBrand(brand: currentBrand!)
            
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertDialog(){
        // Declare Alert
        let title = NSLocalizedString("Brand already exists", comment: "Brand already exists")
        let message = NSLocalizedString("Please choose a different brand name", comment: "Please choose a different brand name")
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let okMsg = NSLocalizedString("OK", comment: "OK")
        let ok = UIAlertAction(title: okMsg, style: .destructive, handler: { (action) -> Void in
            //result = true
        })
        
        //Add OK button to dialog message
        dialogMessage.addAction(ok)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
