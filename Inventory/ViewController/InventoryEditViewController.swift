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
//  EditInventoryViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 19.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit
import os.log
import MobileCoreServices
import AVKit

protocol InventoryEditViewControllerDelegate {
    //func addGeotificationViewController(_ controller: InventoryEditViewController, didAdd geotification: Geotification)
    //func addGeotificationViewController(_ controller: AddGeotificationViewController, didChange oldGeotifcation: Geotification, to newGeotification: Geotification)
    func inventoryEditViewController(_ controller: InventoryEditViewController, didSelect action: UIPreviewAction, for previewedController: UIViewController, which inventory: Inventory)
}

private let store = CoreDataStorage.shared

class InventoryEditViewController: UITableViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate,
                                    UIDropInteractionDelegate, UITextFieldDelegate, UIPointerInteractionDelegate{

    @IBOutlet weak var textfieldInventoryName: UITextField!
    @IBOutlet weak var textfieldPrice: UITextField!
    @IBOutlet weak var textfieldSerialNumber: UITextField!
    @IBOutlet weak var textfieldRemark: UITextField!
    
    @IBOutlet weak var warrantySegmentControl: UISegmentedControl!
    
    @IBOutlet weak var cameraNavBarButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var choosePDFButton: UIButton!
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var dateofPurchaseLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    //@IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var inMonthsLabel: UILabel!
    
    @IBOutlet weak var roomButtonLabel: UIButton!
    @IBOutlet weak var categoryButtonLabel: UIButton!
    @IBOutlet weak var brandButtonLabel: UIButton!
    @IBOutlet weak var ownerButtonLabel: UIButton!
    
    @IBOutlet weak var saveButtonLabel: UIBarButtonItem!
    @IBOutlet weak var cancelButtonLabel: UIBarButtonItem!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var sharePDFBarButton: UIBarButtonItem!
    
    // contains the selected object from viewcontroller before
    // either inventory for edit or nil, then add new inventory to database
    var currentInventory : Inventory?
    
    var delegate: InventoryEditViewControllerDelegate?
    
    // get all detail infos
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    
    var imagePicker : ImagePicker!
    
    var url : URL?   // for choosing pdf file
    
    enum EditMode {
        case edit
        case add
    }
    
    var editmode : EditMode = EditMode.edit
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(cancelButton), input: "D", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.cancel, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(saveButton), input: "S", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.save, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(cameraNavBarAction), input: "F", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.takePhoto, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(choosePDFButton(_:)), input: "I", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.invoice, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(roomButton(_:)), input: "1", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.room, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(categoryButton(_:)), input: "2", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.category, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(brandButton(_:)), input: "3", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.brand, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(ownerButton(_:)), input: "4", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.owner, state: .on)
        ]
    }
    
    // MARK: view initializers
    override func viewDidLoad() {
        super.viewDidLoad()

        //os_log("InventoryEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // initialize image picker class
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        textfieldPrice.delegate = self
        
        // support iPad Drop of PDF invoice files into edit inventory collection
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
        view.isUserInteractionEnabled = true
        
        // setup colors for UI controls
        datePicker.tintColor = themeColorUIControls
        warrantySegmentControl.tintColor = themeColorUIControls
        roomButtonLabel.tintColor = themeColorUIControls
        categoryButtonLabel.tintColor = themeColorUIControls
        ownerButtonLabel.tintColor = themeColorUIControls
        brandButtonLabel.tintColor = themeColorUIControls
        cameraButtonOutlet.tintColor = themeColorUIControls
        cameraNavBarButton.tintColor = themeColorUIControls
        choosePDFButton.tintColor = themeColorUIControls
        sharePDFBarButton.tintColor = themeColorUIControls
        pdfView.tintColor = themeColorUIControls
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        // register tap gesture for showing pdf in fullscreen
        pdfViewGestureWhenTapped()
        
        // register tap gesture for showing image in fullscreen
        imageViewGestureWhenTapped()
        
        currencyLabel.text = Local.currencySymbol!
        
        // focus on first text field
        //textfieldInventoryName.becomeFirstResponder()
        
        // needed for reaction on text fields, e.g. return key
        textfieldInventoryName.delegate = self
        
        textfieldInventoryName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        // get the data from Core Data
        rooms = store.fetchAllRooms()
        brands = store.fetchAllBrands()
        owners = store.fetchAllOwners()
        categories = store.fetchAllCategories()
        
        // set item button texts
        roomButtonLabel.setTitle(currentInventory?.inventoryRoom?.roomName!, for: UIControl.State.normal)
        categoryButtonLabel.setTitle(currentInventory?.inventoryCategory?.categoryName!, for: UIControl.State.normal)
        brandButtonLabel.setTitle(currentInventory?.inventoryBrand?.brandName!, for: UIControl.State.normal)
        ownerButtonLabel.setTitle(currentInventory?.inventoryOwner?.ownerName!, for: UIControl.State.normal)
        
        // edit inventory
        if (currentInventory != nil)
        {
            editmode = EditMode.edit
            
            self.title = NSLocalizedString("Edit Inventory", comment: "Edit Inventory")
            
            // inventory name
            textfieldInventoryName.text = currentInventory?.inventoryName
            
            // inventory price
            textfieldPrice.text = String(currentInventory!.price)
            
            // inventory serial number
            textfieldSerialNumber.text = currentInventory?.serialNumber
            
            // inventory remark
            textfieldRemark.text = currentInventory?.remark
            
            // inventory warranty
            switch currentInventory!.warranty{
            case 0:
                warrantySegmentControl.selectedSegmentIndex = 0
                break
            case 6:
                warrantySegmentControl.selectedSegmentIndex = 1
                break
            case 12:
                warrantySegmentControl.selectedSegmentIndex = 2
                break
            case 24:
                warrantySegmentControl.selectedSegmentIndex = 3
                break
            case 36:
                warrantySegmentControl.selectedSegmentIndex = 4
                break
            case 48:
                warrantySegmentControl.selectedSegmentIndex = 5
                break
            case 60:
                warrantySegmentControl.selectedSegmentIndex = 6
                break
            default:
                warrantySegmentControl.selectedSegmentIndex = 0
            }
            
            // inventory PDF
            if currentInventory!.invoice != nil{
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .vertical
                pdfView.document = PDFDocument(data: (currentInventory!.invoice! as NSData) as Data)
                
                // scroll PDF to top
                DispatchQueue.main.async
                    {
                        guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                        self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
                }
                
                // FIXME
                let pdfFolderPath = URL.createFolder(folderName: "Share")
                let pathURLpdf = pdfFolderPath!.appendingPathComponent(currentInventory!.invoiceFileName!)
                
                let invoiceData = currentInventory!.invoice! as Data
                do {
                    // writes the PDF data to disk
                    try invoiceData.write(to: pathURLpdf, options: .atomic)
                    //print("pdf file saved")
                } catch {
                    print("error saving pdf file:", error)
                    os_log("InventoryEditViewController viewDidLoad", log: Log.viewcontroller, type: .error)
                }
                
                self.url = pathURLpdf
                // register tap gesture for showing pdf in fullscreen, enable only when a pdf has been loaded
                //pdfViewGestureWhenTapped()
            }
            else{
                self.url = nil
            }
            
            // inventory image
            if currentInventory!.image != nil{
                let imageData = currentInventory!.image! as Data
                let image = UIImage(data: imageData, scale: 1.0)
                imageView.image = image
            }
            
            // inventory date
            datePicker.date = currentInventory!.dateOfPurchase! as Date
            
            // set timestamp label
            let msg = NSLocalizedString("Created at: ", comment: "Created at: ")
            
            let dateformatter = DateFormatter()
            dateformatter.locale = Locale(identifier: Local.currentLocaleForDate())
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            let myDate = dateformatter.string(from: currentInventory!.timeStamp! as Date)
            
            timeStampLabel.text = msg + " " + myDate
        }
        else    // add new inventory
        {
            editmode = EditMode.add
            
            saveButtonLabel.isEnabled = false
            
            self.title = NSLocalizedString("Add Inventory", comment: "Add Inventory")
            
            // display default data for new empty inventory object
            textfieldInventoryName.text = ""
            textfieldPrice.text = ""
            
            // default warranty
            warrantySegmentControl.selectedSegmentIndex = 0
            
            // set item button default texts (first item element for default)
            roomButtonLabel.setTitle(rooms[0].roomName, for: UIControl.State.normal)
            categoryButtonLabel.setTitle(categories[0].categoryName, for: UIControl.State.normal)
            brandButtonLabel.setTitle(brands[0].brandName, for: UIControl.State.normal)
            ownerButtonLabel.setTitle(owners[0].ownerName, for: UIControl.State.normal)
            
            // set timestamp label
            let msg = NSLocalizedString("Creating: ", comment: "Creating: ")
            
            let dateformatter = DateFormatter()
            dateformatter.locale = Locale(identifier: Local.currentLocaleForDate())
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            let myDate = dateformatter.string(from: Date())
            
            timeStampLabel.text = msg + " " + myDate
        }
        
        // pointer interaction
        if #available(iOS 13.4, *) {
            customPointerInteraction(on: choosePDFButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: cameraButtonOutlet, pointerInteractionDelegate: self)
            customPointerInteraction(on: roomButtonLabel, pointerInteractionDelegate: self)
            customPointerInteraction(on: categoryButtonLabel, pointerInteractionDelegate: self)
            customPointerInteraction(on: brandButtonLabel, pointerInteractionDelegate: self)
            customPointerInteraction(on: ownerButtonLabel, pointerInteractionDelegate: self)
            
            customPointerInteraction(on: datePicker, pointerInteractionDelegate: self)
            customPointerInteraction(on: imageView, pointerInteractionDelegate: self)
            customPointerInteraction(on: pdfView, pointerInteractionDelegate: self)
        } else {
            // Fallback on earlier versions
        }
        
        // enable long press context menu with image view
        imageView.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(interaction)
        let pdfInteraction = UIContextMenuInteraction(delegate: self)
        pdfView.addInteraction(pdfInteraction)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
       
        hideKeyboardWhenTappedAround()
        
        // disable camera buttons unless user grants access to system privilege
        cameraNavBarButton.isEnabled = false
        cameraButtonOutlet.isEnabled = false
        
        if Global.checkCameraPermission() == true{
            cameraNavBarButton.isEnabled = true
            cameraButtonOutlet.isEnabled = true
        }
        
        // get the data from Core Data
        rooms = store.fetchAllRooms()
        brands = store.fetchAllBrands()
        owners = store.fetchAllOwners()
        categories = store.fetchAllCategories()
        /*
        // set item button texts
        roomButtonLabel.setTitle(currentInventory?.inventoryRoom?.roomName!, for: UIControl.State.normal)
        categoryButtonLabel.setTitle(currentInventory?.inventoryCategory?.categoryName!, for: UIControl.State.normal)
        brandButtonLabel.setTitle(currentInventory?.inventoryBrand?.brandName!, for: UIControl.State.normal)
        ownerButtonLabel.setTitle(currentInventory?.inventoryOwner?.ownerName!, for: UIControl.State.normal)
        */
    }
    
    // call delegate
    private func handle(action: UIPreviewAction, and controller: UIViewController) {
        delegate?.inventoryEditViewController(self, didSelect: action, for: controller, which: currentInventory!)
    }

    
    // MARK: - drag and drop support
    
    // To enable a view to consume data from a drop session, you implement three delegate methods.
    // First, your app can refuse the drag items based on their uniform type identifiers (UTIs), the state of your app, or other requirements.
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        //os_log("InventoryEditViewController dropInteraction canHandle", log: Log.viewcontroller, type: .info)
        
        // must be of kUTTypePDF, otherwise other drop methods will not be called
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeFileURL as String, kUTTypePDF as String, kUTTypeImage as String]) && session.items.count == 1
    }

    // Second, you must tell the system how you want to consume the data, which is typically by copying it. You specify this choice by way of a drop proposal:
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //os_log("InventoryEditViewController dropInteraction sessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        let dropLocation = session.location(in: view)
        //updateLayers(forDropLocation: dropLocation)
        
        let operation: UIDropOperation
        
        //print(view.frame)
        if view.frame.contains(dropLocation) {
            /*
             If you add in-app drag-and-drop support for the .move operation,
             you must write code to coordinate between the drag interaction
             delegate and the drop interaction delegate.
             */
            operation = session.localDragSession == nil ? .copy : .move
        } else {
            // Do not allow dropping outside of the pdf view.
            operation = .cancel
        }
        
        return UIDropProposal(operation: operation)
    }
    
    // Finally, after the user lifts their finger from the screen, indicating their intent to drop the drag items, your view has one opportunity to request particular data representations of the drag items
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //os_log("InventoryEditViewController dropInteraction performDrop", log: Log.viewcontroller, type: .info)
     
        // check for image file drop
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]){
            session.loadObjects(ofClass: UIImage.self) { imageItems in
                let images = imageItems as! [UIImage]
    
                DispatchQueue.main.async
                {
                    self.imageView.image = images.first

                    // create a sound ID, in this case its the tweet sound.
                    let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                    
                    // to play sound
                    AudioServicesPlaySystemSound (systemSoundID)
                }
            }
        }
        
        // check for pdf file drop
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePDF as String]){
            session.loadObjects(ofClass: DropFile.self) { items in
                if let fileItems = items as? [DropFile] {
                    let url = Global.createTempDropObject(fileItems: fileItems)
                    let pdf = PDFDocument(url: url!)
                    
                    DispatchQueue.main.async
                    {
                        self.pdfView.autoScales = true
                        self.pdfView.displayMode = .singlePageContinuous
                        self.pdfView.displayDirection = .vertical
                        self.pdfView.document = pdf
                        guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                        self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
                        
                        // create a sound ID, in this case its the tweet sound.
                        let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                        
                        // to play sound
                        AudioServicesPlaySystemSound (systemSoundID)
                    }
                }
            }
        }
    }
    
    // MARK: - document picker methods
    
    // called by system with resulting document URL
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]){
        
        print(urls.count)
        self.url = urls[0]
        
        pdfDisplay(file: self.url!)
    }
    
    // in case somebody clicks cancel and does not choose a document then simply dismiss
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }

    // MARK: table view stuff
    
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        //os_log("InventoryEditViewController accessoryButtonTappedForRowWith", log: Log.viewcontroller, type: .info)
        //print(indexPath.row)
        //let idx = IndexPath(row: indexPath.row, section: 0)
        //tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //os_log("InventoryEditViewController didSelectRowAt", log: Log.viewcontroller, type: .info)
        
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
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
    
    // check in price textfield for comma or dot characters - somehow people change keyboard input type from decimal to text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == textfieldPrice{
            if let char = string.cString(using: String.Encoding.utf8) {
                let isDot = strcmp(char, ".")
                
                if isDot == 0{
                    return false
                }
                
                let isComma = strcmp(char, ",")
                
                if isComma == 0{
                    return false
                }
            }
        }
        return true
    }
    
    
    // takes care of scrolling content top for the size of the current displayed keyboard
    // uses scrollView
    // will be called from viewDidLoad()
/*    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWasShown(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    } */
/*
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
  */

    // prepare to transfer data to PDF view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "pdfSegue" {
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            destination.currentPath = self.url
            if let name = textfieldInventoryName.text{
                if name.count == 0{
                    destination.currentTitle = Global.invoice
                }
                else{
                    destination.currentTitle = Global.invoice + " " + NSLocalizedString("for", comment: "for") + " " + name
                }
            }
        }
        
        if segue.identifier == "roomSegue" {
            _ = segue.destination as! RoomTableViewController
        }
        
        if segue.identifier == "categorySegue" {
            _ = segue.destination as! CategoryTableViewController
        }
        
        if segue.identifier == "ownerSegue" {
            _ = segue.destination as! OwnerTableViewController
        }
        
        if segue.identifier == "brandSegue" {
            _ = segue.destination as! BrandTableViewController
        }
        
        if segue.identifier == "imageSegue" {
            let destination = segue.destination as! ImageViewController
            destination.image = imageView.image
            destination.titleForImage = textfieldInventoryName.text
        }
    }
    
    // MARK: - UI Actions
    
    // use this method in viewDidLoad to enable tap gesture for pdf view
    func pdfViewGestureWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InventoryEditViewController.pdfViewGestureAction))
        tap.cancelsTouchesInView = false
        // register tap with pdfview only
        pdfView.addGestureRecognizer(tap)
    }
    
    // use this method in viewDidLoad to enable tap gesture for image view
    func imageViewGestureWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InventoryEditViewController.imageViewGestureAction))
        tap.cancelsTouchesInView = false
        // register tap with pdfview only
        imageView.addGestureRecognizer(tap)
    }
    
    // show fullscreen image view
    @objc func imageViewGestureAction() {
        // show image view fullscreen
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    // show fullscreen pdf view
    @objc func pdfViewGestureAction() {
        // show pdf view fullscreen
        performSegue(withIdentifier: "pdfSegue", sender: nil)
    }
    
    // take a new picture
    @IBAction func cameraNavBarAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.imagePicker.present(from: cameraButtonOutlet as UIView) // trick: use UIBarButtonItem would crash since not allowed in this context
        // will show popup on iPad over cameraButtonOutlet/imageButton
    }
    
    // take a new image/take a picture
    @IBAction func imageButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.imagePicker.present(from: sender as UIView)
    }
    
    // choose a PDF file
    @IBAction func choosePDFButton(_ sender: Any) {
        
        // choose only PDF files from document picker
        //pdfPlaceholderImage.isHidden = true
        let types: NSArray = NSArray(object: kUTTypePDF as NSString)
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
        
        // pdfDisplay(fileName: "geographic")
    }
    
    // choose room with an action sheet filled with all room names
    @IBAction func roomButton(_ sender: Any) {
        let message = NSLocalizedString("Choose your room", comment: "Choose your room")
        
        let myActionSheet = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for room in rooms{
            let action = UIAlertAction(title: room.roomName, style: UIAlertAction.Style.default) { (ACTION) in
                self.roomButtonLabel.setTitle(room.roomName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose category with an action sheet filled with all category names
    @IBAction func categoryButton(_ sender: Any) {
        let message = NSLocalizedString("Choose your category", comment: "Choose your category")
        
        let myActionSheet = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for category in categories{
            let action = UIAlertAction(title: category.categoryName, style: UIAlertAction.Style.default) { (ACTION) in
                self.categoryButtonLabel.setTitle(category.categoryName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose brand with an action sheet filled with all brand names
    @IBAction func brandButton(_ sender: Any) {
        let message = NSLocalizedString("Choose your brand", comment: "Choose your brand")
        
        let myActionSheet = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for brand in brands{
            let action = UIAlertAction(title: brand.brandName, style: UIAlertAction.Style.default) { (ACTION) in
                self.brandButtonLabel.setTitle(brand.brandName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose owner with an action sheet filled with all owner names
    @IBAction func ownerButton(_ sender: Any) {
        let message = NSLocalizedString("Choose your owner", comment: "Choose your owner")
        
        let myActionSheet = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for owner in owners{
            let action = UIAlertAction(title: owner.ownerName, style: UIAlertAction.Style.default) { (ACTION) in
                self.ownerButtonLabel.setTitle(owner.ownerName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
    
    // called when segment index changes
    @IBAction func warrantySegmentIndex(_ sender: Any) {
     
    }
    
    // do nothing, close view controller
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    // save inventory, either creating new object or update existing object
    @IBAction func saveButton(_ sender: Any) {
        
        // get new context only if adding new object
        if editmode == EditMode.add{
            //let context = CoreDataHandler.getContext()
            currentInventory = Inventory(context: store.getContext()) // setup new inventory object
        }
        
        currentInventory?.id = UUID()
        currentInventory?.inventoryName = (textfieldInventoryName.text)!.trimmingCharacters(in: .whitespaces)   // can only save when inventory name is entered
        currentInventory?.dateOfPurchase = datePicker.date as NSDate?
        
        // check for valid number in price textfield
        if textfieldPrice.text == nil{
            currentInventory?.price = 0
        }
        else{
            if Int32(textfieldPrice.text!) == nil{
                currentInventory?.price = 0
            }
            else{
                currentInventory?.price = Int32(textfieldPrice.text!)!
            }
        }
        //currentInventory?.price = textfieldPrice.text!.count > 0 ? Int32(textfieldPrice.text!)! : Int32(0)
        currentInventory?.remark = textfieldRemark.text!.count > 0 ? textfieldRemark.text : ""
        currentInventory?.serialNumber = textfieldSerialNumber.text!.count > 0 ? textfieldSerialNumber.text : ""
        
        // warranty will be set via segment control
        
        switch warrantySegmentControl.selectedSegmentIndex
        {
        case 0: // 0 months
            currentInventory?.warranty = Int32(0)
        case 1: // 6 months
            currentInventory?.warranty = Int32(6)
        case 2: // 12 months
            currentInventory?.warranty = Int32(12)
        case 3: // 24 months
            currentInventory?.warranty = Int32(24)
        case 4: // 36 months
            currentInventory?.warranty = Int32(36)
        case 5: // 48 months
            currentInventory?.warranty = Int32(48)
        case 6: // 60 months
            currentInventory?.warranty = Int32(60)
        default:
            break
        }
        
        for owner in owners{
            if ownerButtonLabel.titleLabel!.text! == owner.ownerName{
                currentInventory?.inventoryOwner = owner
            }
        }
        
        for room in rooms{
            if roomButtonLabel.titleLabel!.text! == room.roomName{
                currentInventory?.inventoryRoom = room
            }
        }
        
        for category in categories{
            if categoryButtonLabel.titleLabel!.text! == category.categoryName{
                currentInventory?.inventoryCategory = category
            }
        }
        
        for brand in brands{
            if brandButtonLabel.titleLabel!.text! == brand.brandName{
                currentInventory?.inventoryBrand = brand
            }
        }
        
        currentInventory?.timeStamp = Date() as NSDate?
        
        // image binary data
        let imageData = imageView.image!.jpegData(compressionQuality: Global.imageQuality)
        currentInventory?.image = imageData! as NSData
        currentInventory?.imageFileName = generateFilename(invname: currentInventory!.inventoryName!) + ".jpg"
        
        
        // PDF data
        if pdfView.document != nil{
            currentInventory?.invoice = pdfView.document!.dataRepresentation()! as NSData?
            currentInventory?.invoiceFileName = generateFilename(invname: currentInventory!.inventoryName!) + ".pdf"
        }
        
    /*    currentInventory?.invoice = pdfView.document!.dataRepresentation()! as NSData?
        if(currentInventory?.invoice != nil){
            currentInventory?.invoiceFileName = generateFilename(invname: currentInventory!.inventoryName!) + ".pdf"
        } */
        
        // add data
        if (editmode == EditMode.add)
        {
            _ = store.saveInventory(inventory: currentInventory!)
        }
        else{ // edit data
            _ = store.updateInventory(inventory: currentInventory!)
        }
        
        // FIXME calling view controller viewdidload() always gets called
        navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: pdf handling
    // display pdf file from chosen URL
    func pdfDisplay(file: URL){
        //os_log("InventoryEditViewController pdfDisplay", log: Log.viewcontroller, type: .info)
        
        if let pdfDocument = PDFDocument(url: file) {
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            
            // scroll PDF to top
            DispatchQueue.main.async
                {
                    guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                    self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
            }
            
            pdfView.document = pdfDocument
        }
    }
    
/*
    // generate PDF thumbnail as imageView image
    func captureThumbnails(pdfDocument:PDFDocument) {
        if let page1 = pdfDocument.page(at: 1) {
            pdfImageView.image = page1.thumbnail(of: CGSize(
                width: pdfImageView.frame.size.width,
                height: pdfImageView.frame.size.height), for: .artBox)
        }
        /*
        if let page2 = pdfDocument.page(at: 2) {
            page2ImageView.image = page2.thumbnail(of: CGSize(
                width: page2ImageView.frame.size.width,
                height: page2ImageView.frame.size.height), for: .artBox)
        } */
    } */
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchCancel, .flexibleSpace, .touchPicture, .touchPDF, .fixedSpaceSmall, .touchRoom, .touchCategory, .touchBrand, .touchOwner, .fixedSpaceSmall, .touchOK]
        
        let ok = NSButtonTouchBarItem(identifier: .touchOK, title: Global.save, target: self, action: #selector(saveButton(_:)))
        ok.bezelColor = Global.colorGreen
        let cancel = NSButtonTouchBarItem(identifier: .touchCancel, title: Global.cancel, target: self, action: #selector(cancelButton(_:)))
        cancel.bezelColor = Global.colorRed
        let picture = NSButtonTouchBarItem(identifier: .touchPicture, image: UIImage(systemName: "camera")!, target: self, action: #selector(cameraNavBarAction(_:)))
        let pdf = NSButtonTouchBarItem(identifier: .touchPDF, image: UIImage(systemName: "doc.richtext")!, target: self, action: #selector(choosePDFButton(_:)))
        let room = NSButtonTouchBarItem(identifier: .touchRoom, image: UIImage(systemName: "bed.double.fill")!, target: self, action: #selector(roomButton(_:)))
        let category = NSButtonTouchBarItem(identifier: .touchCategory, image: UIImage(systemName: "book")!, target: self, action: #selector(categoryButton(_:)))
        let brand = NSButtonTouchBarItem(identifier: .touchBrand, image: UIImage(systemName: "cube.box")!, target: self, action: #selector(brandButton(_:)))
        let owner = NSButtonTouchBarItem(identifier: .touchOwner, image: UIImage(systemName: "person.2.fill")!, target: self, action: #selector(ownerButton(_:)))
        
        touchBar.templateItems = [ok, cancel, picture, pdf, room, category, brand, owner]
        
        return touchBar
    }

    #endif
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

extension InventoryEditViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}


// context menu extension
// long press on image gets IOS system share sheet for sending the photo somewhere
extension InventoryEditViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        // switch interactions since we have more than one context menu in same view controller
        switch interaction.view{
        case imageView:
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

                return self.makeImageContextMenu()
            })
            
        case pdfView:
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

                return self.makePDFContextMenu()
            })

        default:
            // error should never happen
            break
            
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.makeImageContextMenu()
        })
    }
    
    func makeImageContextMenu() -> UIMenu {
        // Create a UIAction for sharing
        let share = UIAction(title: Global.share, image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
            
            // first save file to temp dir
            let pathURL = URL.createFolder(folderName: "Share")
            if self.currentInventory?.imageFileName == "" {
                self.currentInventory?.imageFileName = self.generateFilename(invname: self.currentInventory!.inventoryName!) + ".jpg"
            }
            let pathURLjpeg = pathURL!.appendingPathComponent(self.currentInventory!.imageFileName!)

            
            let image = self.imageView.image
            if let data = image!.jpegData(compressionQuality: 0.0),
                !FileManager.default.fileExists(atPath: pathURLjpeg.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: pathURLjpeg, options: .atomic)
                    
                } catch {
                    print("error saving jpg file:", error)
                }
            }
            
            self.shareAction(currentPath: pathURLjpeg)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: Global.images, children: [share])
    }
    
    func makePDFContextMenu() -> UIMenu {
        // if no pdf file no context menu
        guard ((self.currentInventory?.invoice) != nil) else {
            return UIMenu(title: "nix")
        }
        // Create a UIAction for sharing
        let share = UIAction(title: Global.pdf, image: UIImage(systemName: "doc.richtext")) { action in
            // Show system share sheet
            
            self.shareAction(currentPath: self.url!)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: Global.share, children: [share])
    }
}
