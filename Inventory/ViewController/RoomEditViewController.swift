//
//  RoomEditViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class RoomEditViewController: UIViewController, UITextFieldDelegate{
    // contains the selected object from viewcontroller before
    weak var currentRoom : Room?
    
    @IBOutlet weak var textfieldRoomName: UITextField!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // edit or add room
        if currentRoom != nil{
            //
            self.title = "Edit Room"
            textfieldRoomName.text = currentRoom!.roomName
        }
        else{
            self.title = "Add Room"
            textfieldRoomName.text = ""
            saveButtonOutlet.isEnabled = false
        }

        // focus on first text field
        textfieldRoomName.becomeFirstResponder()
        textfieldRoomName.delegate = self
        textfieldRoomName.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingDidEnd)
        textfieldRoomName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControlEvents.editingChanged)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
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
                
                currentRoom = room
                
                // FIXME update will save another record instead of updating
                _ = CoreDataHandler.saveRoom(room: currentRoom!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        else{ // update room name
            if CoreDataHandler.fetchRoom(roomName: textfieldRoomName.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldRoomName.becomeFirstResponder()
            }
            else{
                currentRoom?.roomName = textfieldRoomName.text
                
                _ = CoreDataHandler.saveRoom(room: currentRoom!)
                
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func showAlertDialog(){
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Room already exists", message: "Please choose a different room name", preferredStyle: .alert)
        
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
