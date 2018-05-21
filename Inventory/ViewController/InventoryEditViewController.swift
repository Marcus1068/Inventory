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

class InventoryEditViewController: UITableViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    @IBOutlet weak var textfieldInventoryName: UITextField!
    @IBOutlet weak var textfieldPrice: UITextField!
    @IBOutlet weak var textfieldSerialNumber: UITextField!
    @IBOutlet weak var textfieldRemark: UITextField!
    
    @IBOutlet weak var warrantySegmentControl: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var pdfImageView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var dateofPurchaseLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var inMonthsLabel: UILabel!
    
    @IBOutlet weak var roomButtonLabel: UIButton!
    @IBOutlet weak var categoryButtonLabel: UIButton!
    @IBOutlet weak var brandButtonLabel: UIButton!
    @IBOutlet weak var ownerButtonLabel: UIButton!
    
    @IBOutlet weak var saveButtonLabel: UIBarButtonItem!
    @IBOutlet weak var cancelButtonLabel: UIBarButtonItem!
    
    // contains the selected object from viewcontroller before
    // either inventory for edit or nil, then add new inventory to database
    weak var currentInventory : Inventory?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }

        imagePicker.delegate = self
        
        
        // Do any additional setup after loading the view.
        
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
            
            // inventory image
            let imageData = currentInventory!.image! as Data
            let image = UIImage(data: imageData, scale: 1.0)
            imageView.image = image
            
            // inventory date
            datePicker.date = currentInventory!.dateOfPurchase! as Date
            
            // set timestamp label
            timeStampLabel.text = "Created at: " + (currentInventory?.timeStamp?.toString(withFormat: "MM/dd/yy"))!   // FIXME needs to change with US/UK etc.
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
            imageView.image = UIImage(named: "Inventory.png");
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)
            currentInventory?.image = imageData! as NSData
            
            // default warranty
            warrantySegmentControl.selectedSegmentIndex = 0
            currentInventory?.warranty = Int32(12)
            
            // set item button default texts (first item element for default)
            roomButtonLabel.setTitle(rooms[0].roomName, for: UIControlState.normal)
            currentInventory?.inventoryRoom = rooms[0]
            categoryButtonLabel.setTitle(categories[0].categoryName, for: UIControlState.normal)
            currentInventory?.inventoryCategory = categories[0]
            brandButtonLabel.setTitle(brands[0].brandName, for: UIControlState.normal)
            currentInventory?.inventoryBrand = brands[0]
            ownerButtonLabel.setTitle(owners[0].ownerName, for: UIControlState.normal)
            currentInventory?.inventoryOwner = owners[0]
            
            // set timestamp label
            let today = Date()
            timeStampLabel.text = "Creating: " + today.toString(withFormat: "MM/dd/yy")
        }
        
        // focus on first text field
        textfieldInventoryName.becomeFirstResponder()
        
        // needed for reaction on text fields, e.g. return key
        textfieldInventoryName.delegate = self as? UITextFieldDelegate
        //textfieldPrice.delegate = self
        //textfieldPrice.keyboardType = UIKeyboardType.numberPad  // allow only numbers to be entered
        
        textfieldInventoryName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControlEvents.editingChanged)
        
        // auto scroll to top so that all text fields can be entered
        //registerForKeyboardNotifications()
    }

    // refresh data when view will be redrawn, after choosing room table view etc.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
        
        // set item button texts
        roomButtonLabel.setTitle(currentInventory?.inventoryRoom?.roomName!, for: UIControlState.normal)
        categoryButtonLabel.setTitle(currentInventory?.inventoryCategory?.categoryName!, for: UIControlState.normal)
        brandButtonLabel.setTitle(currentInventory?.inventoryBrand?.brandName!, for: UIControlState.normal)
        ownerButtonLabel.setTitle(currentInventory?.inventoryOwner?.ownerName!, for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        os_log("accessoryButtonTappedForRowWith", log: OSLog.default, type: .debug)
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
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    // cancel picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    // take a new image/take a picture
    @IBAction func imageButton(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // choose from picture library
    @IBAction func chooseImageButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    // choose a PDF file
    @IBAction func choosePDFButton(_ sender: Any) {
        
    }
    
    // choose room with an action sheet filled with all room names
    @IBAction func roomButton(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "Room", message: "Choose your room", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for room in rooms{
            let action = UIAlertAction(title: room.roomName, style: UIAlertActionStyle.default) { (ACTION) in
                self.currentInventory?.inventoryRoom? = room
                self.roomButtonLabel.setTitle(self.currentInventory?.inventoryRoom?.roomName!, for: UIControlState.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose category with an action sheet filled with all category names
    @IBAction func categoryButton(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "Category", message: "Choose your category", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for category in categories{
            let action = UIAlertAction(title: category.categoryName, style: UIAlertActionStyle.default) { (ACTION) in
                self.currentInventory?.inventoryCategory? = category
                self.categoryButtonLabel.setTitle(self.currentInventory?.inventoryCategory?.categoryName!, for: UIControlState.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose brand with an action sheet filled with all brand names
    @IBAction func brandButton(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "Brand", message: "Choose your brand", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for brand in brands{
            let action = UIAlertAction(title: brand.brandName, style: UIAlertActionStyle.default) { (ACTION) in
                self.currentInventory?.inventoryBrand? = brand
                self.brandButtonLabel.setTitle(self.currentInventory?.inventoryBrand?.brandName!, for: UIControlState.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // choose owner with an action sheet filled with all owner names
    @IBAction func ownerButton(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "Owner", message: "Choose your owner", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for owner in owners{
            let action = UIAlertAction(title: owner.ownerName, style: UIAlertActionStyle.default) { (ACTION) in
                self.currentInventory?.inventoryOwner? = owner
                self.ownerButtonLabel.setTitle(self.currentInventory?.inventoryOwner?.ownerName!, for: UIControlState.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (ACTION) in
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
    
    // save inventory, either new or update old object
    @IBAction func saveButton(_ sender: Any) {
        
        currentInventory?.inventoryName = textfieldInventoryName.text   // can only save when inventory name is entered
        currentInventory?.dateOfPurchase = datePicker.date as NSDate?
        currentInventory?.price = textfieldPrice.text!.count > 0 ? Int32(textfieldPrice.text!)! : Int32(0)
        currentInventory?.remark = textfieldRemark.text!.count > 0 ? textfieldRemark.text : ""
        currentInventory?.serialNumber = textfieldSerialNumber.text!.count > 0 ? textfieldSerialNumber.text : ""
        // warranty will be set via segment control
        
        currentInventory?.timeStamp = Date() as NSDate?
        // image binary data
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)
        currentInventory?.image = imageData! as NSData
        
        // invoice PDF binary data
        let arr : [UInt32] = [32,4,123,4,5,2]
        let myinvoice = NSData(bytes: arr, length: arr.count * 32)
        currentInventory?.invoice = myinvoice
        
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
    
    // display pdf file
    func pdfDisplay(fileName: String){
        if let path = Bundle.main.path(forResource: fileName, ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            if let pdfDocument = PDFDocument(url: url) {
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
                
                captureThumbnails(pdfDocument:pdfDocument)
            }
        }
    }
    
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
    }
}




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
