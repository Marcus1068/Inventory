//
//  OwnerEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class OwnerEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var textfieldOwner: UITextField!
    
    // contains the selected object from viewcontroller before
    weak var currentOwner : Owner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // edit or add owner
        if currentOwner != nil{
            //
            self.title = "Edit Owner"
            textfieldOwner.text = currentOwner!.ownerName
        }
        else{
            self.title = "Add Owner"
            textfieldOwner.text = ""
            saveButtonOutlet.isEnabled = false
        }
        
        // focus on first text field
        textfieldOwner.becomeFirstResponder()
        textfieldOwner.delegate = self
        textfieldOwner.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingDidEnd)
        textfieldOwner.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControlEvents.editingChanged)
        
        textfieldOwner.placeholder = "Owner"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //os_log("textFieldShouldReturn", log: OSLog.default, type: .debug)
        
        if (textField == textfieldOwner)
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
        
        if textfieldOwner.text?.count == 0{
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
        if (currentOwner == nil)
        {
            if CoreDataHandler.fetchOwner(ownerName: textfieldOwner.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldOwner.becomeFirstResponder()
            }
            else{
                let context = CoreDataHandler.getContext()
                
                let owner = Owner(context: context)
                
                // set object with UI values
                owner.ownerName = textfieldOwner.text!
                
                currentOwner = owner
                
                _ = CoreDataHandler.saveOwner(owner: currentOwner!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{
            currentOwner?.ownerName = textfieldOwner.text
            
            _ = CoreDataHandler.saveOwner(owner: currentOwner!)
            
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertDialog(){
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Owner already exists", message: "Please choose a different owner name", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            //result = true
        })
        
        //Add OK button to dialog message
        dialogMessage.addAction(ok)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
}
