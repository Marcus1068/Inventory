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
            navigationItem.largeTitleDisplayMode = .always
        }
        
        self.title = "Edit Room"
        
        if currentRoom != nil{
            //
            textfieldRoomName.text = currentRoom!.roomName
        }
        else{
            textfieldRoomName.text = ""
            saveButtonOutlet.isEnabled = false
        }

        // focus on first text field
        textfieldRoomName.becomeFirstResponder()
        textfieldRoomName.delegate = self
        textfieldRoomName.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingDidEnd)
        textfieldRoomName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControlEvents.editingChanged)

        
        // Do any additional setup after loading the view.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    @IBAction func saveButton(_ sender: Any) {
        // close keyboard
        self.view.endEditing(true)
        
        // new room
        if (currentRoom == nil)
        {
            let context = CoreDataHandler.getContext()
            
            let room = Room(context: context)
            
            // set object with UI values
            room.roomName = textfieldRoomName.text!
            
            currentRoom = room
            
            // FIXME update will save another record instead of updating
            _ = CoreDataHandler.saveRoom(roomName: currentRoom!.roomName!)
        }
        else{
            // update room name
            currentRoom?.roomName = textfieldRoomName.text
            
            _ = CoreDataHandler.updateRoom(room: currentRoom!)
        }
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

}
