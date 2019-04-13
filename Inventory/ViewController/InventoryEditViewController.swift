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

class InventoryEditViewController: UITableViewController, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var textfieldInventoryName: UITextField!
    @IBOutlet weak var textfieldPrice: UITextField!
    @IBOutlet weak var textfieldSerialNumber: UITextField!
    @IBOutlet weak var textfieldRemark: UITextField!
    
    @IBOutlet weak var warrantySegmentControl: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var cameraNavBarOutlet: UIBarButtonItem!
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
    
    // contains the selected object from viewcontroller before
    // either inventory for edit or nil, then add new inventory to database
    var currentInventory : Inventory? // FIXME weak migth be wrong
    
    // get all detail infos
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    
    let imagePicker = UIImagePickerController()
    
    enum EditMode {
        case edit
        case add
    }
    
    var editmode : EditMode = EditMode.edit
    
    
    // MARK: view initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("InventoryEditViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }

        // register tap gesture for showing pdf in fullscreen
        pdfViewGestureWhenTapped()
        
        // register tap gesture for showing image in fullscreen
        imageViewGestureWhenTapped()
        
        // when tapping somewhere on view dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        imagePicker.delegate = self
        
        
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
        
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
            default:
                warrantySegmentControl.selectedSegmentIndex = 0
            }
            
            // inventory PDF
            if currentInventory!.invoice != nil{
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .vertical
                pdfView.document = PDFDocument(data: (currentInventory!.invoice! as NSData) as Data)
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
            timeStampLabel.text = msg + (currentInventory?.timeStamp?.toString(withFormat: "MM/dd/yy"))!   // FIXME needs to change with US/UK etc.
        }
        else    // add new inventory
        {
            editmode = EditMode.add
            
            let context = CoreDataHandler.getContext()
            currentInventory = Inventory(context: context) // setup new inventory object
            
            saveButtonLabel.isEnabled = false
            
            self.title = NSLocalizedString("Add Inventory", comment: "Add Inventory")
            
            // display default data for new empty inventory object
            textfieldInventoryName.text = ""
            textfieldPrice.text = ""
            
            // default placeholder graphic
    //        imageView.image = UIImage(named: "Inventory.png");
            let imageData = imageView.image!.jpegData(compressionQuality: 0.1)
            currentInventory?.image = imageData! as NSData

            // default warranty
            warrantySegmentControl.selectedSegmentIndex = 0
            currentInventory?.warranty = Int32(12)
            
            // set item button default texts (first item element for default)
            roomButtonLabel.setTitle(rooms[0].roomName, for: UIControl.State.normal)
            currentInventory?.inventoryRoom = rooms[0]
            categoryButtonLabel.setTitle(categories[0].categoryName, for: UIControl.State.normal)
            currentInventory?.inventoryCategory = categories[0]
            brandButtonLabel.setTitle(brands[0].brandName, for: UIControl.State.normal)
            currentInventory?.inventoryBrand = brands[0]
            ownerButtonLabel.setTitle(owners[0].ownerName, for: UIControl.State.normal)
            currentInventory?.inventoryOwner = owners[0]
            
            // set timestamp label
            let today = Date()
            let msg = NSLocalizedString("Creating: ", comment: "Creating: ")
            timeStampLabel.text = msg + today.toString(withFormat: "MM/dd/yy")  // FIXME hardcoded date format
        }
        
        // focus on first text field
        textfieldInventoryName.becomeFirstResponder()
        
        // needed for reaction on text fields, e.g. return key
        textfieldInventoryName.delegate = self as? UITextFieldDelegate
        //textfieldPrice.delegate = self
        //textfieldPrice.keyboardType = UIKeyboardType.numberPad  // allow only numbers to be entered
        
        textfieldInventoryName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        
        // auto scroll to top so that all text fields can be entered
        //registerForKeyboardNotifications()
    }

    // refresh data when view will be redrawn, after choosing room table view etc.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
       
        os_log("InventoryEditViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        // disable camera buttons unless user grants access to system privilege
        cameraNavBarOutlet.isEnabled = false
        cameraButtonOutlet.isEnabled = false
        
        // check for camera permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied: // The user has previously denied access.
            break
        case .restricted: // The user can't grant access due to restrictions.
            break
        @unknown default:
            os_log("InventoryEditViewController viewWillAppear", log: Log.viewcontroller, type: .error)
        }
        
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
        
        // set item button texts
        roomButtonLabel.setTitle(currentInventory?.inventoryRoom?.roomName!, for: UIControl.State.normal)
        categoryButtonLabel.setTitle(currentInventory?.inventoryCategory?.categoryName!, for: UIControl.State.normal)
        brandButtonLabel.setTitle(currentInventory?.inventoryBrand?.brandName!, for: UIControl.State.normal)
        ownerButtonLabel.setTitle(currentInventory?.inventoryOwner?.ownerName!, for: UIControl.State.normal)
    }
    
    // camera enabled
    func setupCaptureSession(){
        // enable camera buttons
        cameraNavBarOutlet.isEnabled = true
        cameraButtonOutlet.isEnabled = true
    }
    
    // MARK: document picker methods
    
    // called by system with resulting document URL
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        
        pdfDisplay(file: myURL)
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
        os_log("InventoryEditViewController tableView", log: Log.viewcontroller, type: .info)
        //print(indexPath.row)
        //let idx = IndexPath(row: indexPath.row, section: 0)
        //tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Delegates
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    // cancel picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    // prepare to transfer data to PDF view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
 /*       switch segue.identifier {
        case "pdfSegue":
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            break
        case "roomSegue":
            let destination = segue.destination as! RoomTableViewController
            break
        
        default:
            break
        }
   */
        
        if segue.identifier == "pdfSegue" {
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            destination.currentTitle = NSLocalizedString("PDF invoice", comment: "PDF invoice")
        }
        
        if segue.identifier == "roomSegue" {
            _ = segue.destination as! RoomTableViewController
        }
        
        if segue.identifier == "imageSegue" {
            let destination = segue.destination as! ImageViewController
            destination.image = imageView.image
        }
    }
    
    // use this method in viewDidLoad to enable tap gesture for pdf view
    func pdfViewGestureWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InventoryEditViewController.pdfViewGestureAction))
        tap.cancelsTouchesInView = false
        // register tap with pdfview only
        pdfView.addGestureRecognizer(tap)
    }
    
    // show fullscreen pdf view
    @objc func pdfViewGestureAction() {
        os_log("InventoryEditViewController pdfViewGestureAction", log: Log.viewcontroller, type: .info)
        
        // show pdf view fullscreen
        performSegue(withIdentifier: "pdfSegue", sender: nil)
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
        os_log("InventoryEditViewController imageViewGestureAction", log: Log.viewcontroller, type: .info)
        
        // show image view fullscreen
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    // MARK: - UI Acions
    
    // take a new image/take a picture
    @IBAction func imageButton(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        //imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // choose a picture from picture library
    @IBAction func chooseImageButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        //imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // choose a PDF file
    @IBAction func choosePDFButton(_ sender: Any) {
        
        // choose only PDF files from document picker
        let types: NSArray = NSArray(object: kUTTypePDF as NSString)
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
        
        // pdfDisplay(fileName: "geographic")
    }
    
    // choose room with an action sheet filled with all room names
    @IBAction func roomButton(_ sender: Any) {
        let title = NSLocalizedString("Room", comment: "Room")
        let message = NSLocalizedString("Choose your room", comment: "Choose your room")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        for room in rooms{
            let action = UIAlertAction(title: room.roomName, style: UIAlertAction.Style.default) { (ACTION) in
                self.currentInventory?.inventoryRoom? = room
                self.roomButtonLabel.setTitle(self.currentInventory?.inventoryRoom?.roomName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        let action = UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose category with an action sheet filled with all category names
    @IBAction func categoryButton(_ sender: Any) {
        let title = NSLocalizedString("Category", comment: "Category")
        let message = NSLocalizedString("Choose your category", comment: "Choose your category")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        for category in categories{
            let action = UIAlertAction(title: category.categoryName, style: UIAlertAction.Style.default) { (ACTION) in
                self.currentInventory?.inventoryCategory? = category
                self.categoryButtonLabel.setTitle(self.currentInventory?.inventoryCategory?.categoryName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        let action = UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose brand with an action sheet filled with all brand names
    @IBAction func brandButton(_ sender: Any) {
        let title = NSLocalizedString("Brand", comment: "Brand")
        let message = NSLocalizedString("Choose your brand", comment: "Choose your brand")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        for brand in brands{
            let action = UIAlertAction(title: brand.brandName, style: UIAlertAction.Style.default) { (ACTION) in
                self.currentInventory?.inventoryBrand? = brand
                self.brandButtonLabel.setTitle(self.currentInventory?.inventoryBrand?.brandName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        let action = UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose owner with an action sheet filled with all owner names
    @IBAction func ownerButton(_ sender: Any) {
        let title = NSLocalizedString("Owner", comment: "Owner")
        let message = NSLocalizedString("Choose your owner", comment: "Choose your owner")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        for owner in owners{
            let action = UIAlertAction(title: owner.ownerName, style: UIAlertAction.Style.default) { (ACTION) in
                self.currentInventory?.inventoryOwner? = owner
                self.ownerButtonLabel.setTitle(self.currentInventory?.inventoryOwner?.ownerName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        let action = UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // called when segment index changes
    @IBAction func warrantySegmentIndex(_ sender: Any) {
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
        default:
            break
        }
    }
    
    // do nothing, close view controller
    @IBAction func cancelButton(_ sender: Any) {
        // workaround for adding new element by mistake if Add will be chosen and cancel clicked
        if editmode == EditMode.add
        {
            let context = CoreDataHandler.getContext()
            context.delete(currentInventory!)
        }
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // save inventory, either creating new object or update existing object
    @IBAction func saveButton(_ sender: Any) {
        
        currentInventory?.id = UUID()
        currentInventory?.inventoryName = textfieldInventoryName.text   // can only save when inventory name is entered
        currentInventory?.dateOfPurchase = datePicker.date as NSDate?
        currentInventory?.price = textfieldPrice.text!.count > 0 ? Int32(textfieldPrice.text!)! : Int32(0)
        currentInventory?.remark = textfieldRemark.text!.count > 0 ? textfieldRemark.text : ""
        currentInventory?.serialNumber = textfieldSerialNumber.text!.count > 0 ? textfieldSerialNumber.text : ""
        // warranty will be set via segment control
        
        currentInventory?.timeStamp = Date() as NSDate?
        
        // image binary data
        let imageData = imageView.image!.jpegData(compressionQuality: 0.1)
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
            _ = CoreDataHandler.saveInventory(inventory: currentInventory!)
        }
        else{ // edit data
            _ = CoreDataHandler.updateInventory(inventory: currentInventory!)
        }
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: pdf handling
    // display pdf file from chosen URL
    func pdfDisplay(file: URL){
        if let pdfDocument = PDFDocument(url: file) {
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
            
            //currentInventory?.invoice = pdfView.document!.dataRepresentation()! as NSData?
            //currentInventory?.invoiceFileName = generateFilename(invname: currentInventory!.inventoryName!) + ".pdf" // FIXME crashes when new object, works with existing object to attach a pdf
            // show thumbnail as well
            //captureThumbnails(pdfDocument:pdfDocument)
        }
    }
    
    // give filename based on current date
    func generateFilename(invname: String) -> String{
        
        let date :NSDate = NSDate()
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd'_'HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"      // FIXME hard coded date format
        
        dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        
        let imageName = invname + "_" + "\(dateFormatter.string(from: date as Date))"
        
        return imageName
        
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
}



// MARK: extensions
// to get string from a date
// usage: yourString = yourDate.toString(withFormat: "yyyy")
extension Date {
    
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}

extension NSDate {
    
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self as Date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
