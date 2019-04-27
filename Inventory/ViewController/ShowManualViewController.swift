//
//  ShowManualViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 27.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit
import os


class ShowManualViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var doneAction: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ShowManualViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = NSLocalizedString("Inventory Manual", comment: "Inventory Manual")
        
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        var fileURL : URL?
        
        switch Global.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileURL = Bundle.main.url(forResource: "Inventory App Handbuch", withExtension: "pdf")
            break
            
        default: // all other languages get english manual
            fileURL = Bundle.main.url(forResource: "Inventory App Manual", withExtension: "pdf")
            break
        }
        
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: fileURL!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doneAction(_ sender: UIButton) {
        os_log("ShowManualViewController doneAction", log: Log.viewcontroller, type: .info)
        
        dismiss(animated: true, completion: nil)
    }
}
