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
//  RoomEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

class RoomEditViewController: UIViewController, UITextFieldDelegate{
    // contains the selected object from viewcontroller before
    weak var currentRoom : Room?
    
    @IBOutlet weak var textfieldRoomName: UITextField!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var chosenImage: UIImageView!
    
    @IBOutlet weak var bedroomIcon: UIButton!
    
    @IBOutlet weak var diningIcon: UIButton!
    
    @IBOutlet weak var kidsIcon: UIButton!
    
    @IBOutlet weak var gardenIcon: UIButton!
    
    @IBOutlet weak var bathIcon: UIButton!
    
    @IBOutlet weak var cellarIcon: UIButton!
    
    @IBOutlet weak var kitchenIcon: UIButton!
    
    @IBOutlet weak var livingIcon: UIButton!
    
    @IBOutlet weak var garageIcon: UIButton!
    
    @IBOutlet weak var homeIcon: UIButton!
    
    @IBOutlet weak var defaultIcon: UIButton!
    
    @IBOutlet weak var living2Icon: UIButton!
    
    @IBOutlet weak var officeIcon: UIButton!
    
    @IBOutlet weak var office2Icon: UIButton!
    
    @IBOutlet weak var office3Icon: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //os_log("RoomEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // UI controls color theme
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        // dismiss keyboard
        hideKeyboardWhenTappedAround()
        
        // edit or add room
        if currentRoom != nil{
            // edit
            self.title = NSLocalizedString("Edit Room", comment: "Edit Room")
            textfieldRoomName.text = currentRoom!.roomName
            
            let imageData = currentRoom!.roomImage! as Data
            let image = UIImage(data: imageData, scale:1.0)
            chosenImage.image = image
        }
        else{
            // add
            self.title = NSLocalizedString("Add Room", comment: "Add Room")
            textfieldRoomName.text = ""
            saveButtonOutlet.isEnabled = false
        }

        // focus on first text field
        textfieldRoomName.becomeFirstResponder()
        textfieldRoomName.delegate = self
        textfieldRoomName.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldRoomName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        textfieldRoomName.placeholder = Global.room
    }
    
    // when user presses return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //os_log("textFieldShouldReturn", log: OSLog.default, type: .debug)
        
        if (textField == textfieldRoomName)
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
        
        if textfieldRoomName.text?.count == 0{
            saveButtonOutlet.isEnabled = false
        }
        else{
            saveButtonOutlet.isEnabled = true
        }
        
    }
    
    // MARK: - UI actions
    
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        // close keyboard
        self.view.endEditing(true)
        
        // new room
        if (currentRoom == nil)
        {
            if CoreDataHandler.fetchRoom(roomName: textfieldRoomName.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldRoomName.becomeFirstResponder()
            }
            else{
                let context = CoreDataHandler.getContext()
                
                let room = Room(context: context)
                
                // set object with UI values
                room.roomName = textfieldRoomName.text!
                // image binary data
                let imageData = chosenImage.image!.jpegData(compressionQuality: 1.0)
                room.roomImage = imageData! as NSData
                
                currentRoom = room
                
                _ = CoreDataHandler.saveRoom(room: currentRoom!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{ // update room name
/*            if CoreDataHandler.fetchRoom(roomName: textfieldRoomName.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldRoomName.becomeFirstResponder()
            }
            else{ */
                currentRoom?.roomName = textfieldRoomName.text
                
                // image binary data
                let imageData = chosenImage.image!.jpegData(compressionQuality: 1.0)
                currentRoom?.roomImage = imageData! as NSData
                
                _ = CoreDataHandler.saveRoom(room: currentRoom!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
     //       }
        }
    }

    func showAlertDialog(){
        // Declare Alert
        let title = NSLocalizedString("Room already exists", comment: "Room already exists")
        let dialogMessage = UIAlertController(title: title, message: Global.chooseDifferentName, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: Global.ok, style: .destructive, handler: { (action) -> Void in
            //result = true
        })
        
        //Add OK button to dialog message
        dialogMessage.addAction(ok)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    // manage all icon buttons
    @IBAction func iconButton(_ sender: UIButton) {
        switch sender {
        case bedroomIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-bett-50")
            break
        case diningIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-geschirr-50")
            break
        case kidsIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-teddy-50")
            break
        case gardenIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-haus-mit-garten-50")
            break
        case garageIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-garage-50")
            break
        case bathIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-durchfall-50")
            break
        case cellarIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-keller-filled-50")
            break
        case livingIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-wohnzimmer-50")
            break
        case kitchenIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-kochtopf-50")
            break
        case homeIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-wohnung-filled-50")
            break
        case defaultIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-filled-50")
            break
        case living2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-retro-tv-filled-50")
            break
        case officeIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-arbeitsplatz-50")
            break
        case office2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-office-filled-50")
            break
        case office3Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-schreibtischlampe-filled-50")
            break
        default:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-filled-50")
            break
        }
    }
}
