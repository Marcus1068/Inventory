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
//  OwnerEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

private let store = CoreDataStorage.shared

class OwnerEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var textfieldOwner: UITextField!
    
    // contains the selected object from viewcontroller before
    weak var currentOwner : Owner?
    
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(cancelButton), input: "D", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.cancel, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(saveButton), input: "S", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.save, state: .on)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //os_log("OwnerEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // UI controls color theme
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        // dismiss keyboard
        hideKeyboardWhenTappedAround()
        
        // edit or add owner
        if currentOwner != nil{
            //
            self.title = NSLocalizedString("Edit Owner", comment: "Edit Owner")
            textfieldOwner.text = currentOwner!.ownerName
        }
        else{
            self.title = NSLocalizedString("Add Owner", comment: "Add Owner")
            textfieldOwner.text = ""
            saveButtonOutlet.isEnabled = false
        }
        
        // focus on first text field
        //textfieldOwner.becomeFirstResponder()
        textfieldOwner.delegate = self
        textfieldOwner.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldOwner.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        textfieldOwner.placeholder = Local.owner
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
        let text = textfieldOwner.text?.trimmingCharacters(in: .whitespaces)
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
        
        if textfieldOwner.text?.count == 0{
            displayAlert(title: Global.invalidOwnerName, message: "", buttonText: Global.ok)
            return
        }
        
        // new brand
        if (currentOwner == nil)
        {
            if store.fetchOwner(ownerName: textfieldOwner.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldOwner.becomeFirstResponder()
            }
            else{
                //let context = CoreDataHandler.getContext()
                
                let owner = Owner(context: store.getContext())
                
                // set object with UI values
                owner.ownerName = (textfieldOwner.text!).trimmingCharacters(in: .whitespaces)
                
                currentOwner = owner
                
                _ = store.saveOwner(owner: currentOwner!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{
            currentOwner?.ownerName = textfieldOwner.text
            
            _ = store.saveOwner(owner: currentOwner!)
            
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertDialog(){
        // Declare Alert
        let title = NSLocalizedString("Owner already exists", comment: "Owner already exists")
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
