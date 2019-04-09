//
//  CategoryEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

class CategoryEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var textfieldCategory: UITextField!
    
    // contains the selected object from viewcontroller before
    weak var currentCategory : Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("CategoryEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // edit or add room
        if currentCategory != nil{
            //
            self.title = NSLocalizedString("Edit Category", comment: "Edit Category")
            textfieldCategory.text = currentCategory!.categoryName
        }
        else{
            self.title = NSLocalizedString("Add Category", comment: "Add Category")
            textfieldCategory.text = ""
            saveButtonOutlet.isEnabled = false
        }
        
        // focus on first text field
        textfieldCategory.becomeFirstResponder()
        textfieldCategory.delegate = self
        textfieldCategory.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldCategory.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        textfieldCategory.placeholder = NSLocalizedString("Category", comment: "Category")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //os_log("textFieldShouldReturn", log: OSLog.default, type: .debug)
        
        if (textField == textfieldCategory)
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
        
        if textfieldCategory.text?.count == 0{
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
        
        os_log("CategoryEditViewController saveButton", log: Log.viewcontroller, type: .info)
        
        // close keyboard
        self.view.endEditing(true)
        
        // new category
        if (currentCategory == nil)
        {
            if CoreDataHandler.fetchCategory(categoryName: textfieldCategory.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldCategory.becomeFirstResponder()
            }
            else{
                let context = CoreDataHandler.getContext()
                
                let category = Category(context: context)
                
                // set object with UI values
                category.categoryName = textfieldCategory.text!
                
                currentCategory = category
                
                _ = CoreDataHandler.saveCategory(category: currentCategory!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{ // update category name
 /*           if CoreDataHandler.fetchCategory(categoryName: textfieldCategory.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldCategory.becomeFirstResponder()
            }
            else{ */
                currentCategory?.categoryName = textfieldCategory.text
                
                _ = CoreDataHandler.saveCategory(category: currentCategory!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
  //          }
        }
    }
    
    func showAlertDialog(){
        // Declare Alert
        let title = NSLocalizedString("Category already exists", comment: "Category already exists")
        let message = NSLocalizedString("Please choose a different category name", comment: "Please choose a different category name")
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
