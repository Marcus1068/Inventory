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
//  ImagePicker.swift
//  Inventory
//
//  Created by Marcus Deuß on 05.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//


/* usage:
 class ViewController: UIViewController {
 
 @IBOutlet var imageView: UIImageView!
 
 var imagePicker: ImagePicker!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 self.imagePicker = ImagePicker(presentationController: self, delegate: self)
 }
 
 @IBAction func showImagePicker(_ sender: UIButton) {
 self.imagePicker.present(from: sender)
 }
 }
 
 extension ViewController: ImagePickerDelegate {
 
 func didSelect(image: UIImage?) {
 self.imageView.image = image
 }
 }
 */

import UIKit
import os


public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"] // for video add [public.video]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        //os_log("ImagePicker action", log: Log.viewcontroller, type: .info)
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        //os_log("ImagePicker present", log: Log.viewcontroller, type: .info)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: Global.takePhoto) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum, title: Global.cameraRoll) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: Global.photoLibrary) {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: Global.cancel, style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        //os_log("ImagePicker pickerController", log: Log.viewcontroller, type: .info)
        
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
