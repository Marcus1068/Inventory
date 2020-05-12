/*
 
 Copyright 2019 Marcus Deuß
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

//
//  BrandEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

private let store = CoreDataStorage.shared

class BrandEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var textfieldBrand: UITextField!
    
    // contains the selected object from viewcontroller before
    weak var currentBrand : Brand?
    
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(cancelButton), input: "D", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.cancel, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(saveButton), input: "S", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.save, state: .on)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //os_log("BrandEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // UI controls color theme
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        // dismiss keyboard
        hideKeyboardWhenTappedAround()
        
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
        //textfieldBrand.becomeFirstResponder()
        textfieldBrand.delegate = self
        textfieldBrand.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldBrand.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        textfieldBrand.placeholder = Local.brand
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
        let text = textfieldBrand.text?.trimmingCharacters(in: .whitespaces)
        if text?.count == 0{
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
        
        if textfieldBrand.text?.count == 0{
            displayAlert(title: Global.invalidBrandName, message: "", buttonText: Global.ok)
            return
        }
        
        // new brand
        if (currentBrand == nil)
        {
            if store.fetchBrand(brandName: textfieldBrand.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldBrand.becomeFirstResponder()
            }
            else{
                //let context = CoreDataHandler.getContext()
                
                let brand = Brand(context: store.getContext())
                
                // set object with UI values
                brand.brandName = (textfieldBrand.text!).trimmingCharacters(in: .whitespaces)
                
                currentBrand = brand
                
                _ = store.saveBrand(brand: currentBrand!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{
            currentBrand?.brandName = textfieldBrand.text
            
            _ = store.saveBrand(brand: currentBrand!)
            
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertDialog(){
        // Declare Alert
        let title = NSLocalizedString("Brand already exists", comment: "Brand already exists")
        displayAlert(title: title, message: Global.chooseDifferentName, buttonText: Global.ok)
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchCancel, .fixedSpaceSmall, .touchSave]
        
        let save = NSButtonTouchBarItem(identifier: .touchSave, title: Global.save, target: self, action: #selector(saveButton(_:)))
        save.bezelColor = Global.colorGreen
        
        let cancel = NSButtonTouchBarItem(identifier: .touchCancel, title: Global.cancel, target: self, action: #selector(cancelButton(_:)))
        cancel.bezelColor = Global.colorRed
        
        touchBar.templateItems = [save, cancel]
        
        return touchBar
    }

    #endif
}
