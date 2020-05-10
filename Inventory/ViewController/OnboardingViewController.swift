//
//  OnboardingViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 08.05.20.
//  Copyright © 2020 Marcus Deuß. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIPointerInteractionDelegate {

    @IBOutlet weak var whatsNewLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "D", modifierFlags: .command, action: #selector(doneAction), discoverabilityTitle: Global.done),
            
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        // first thing: clean up sample data for icloud sync
        let store = CoreDataStorage.shared
        store.deleteSampleData()
        
        let fileName: String
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "WhatsNew German"
            break
            
        default: // all other languages get english privacy statement
            fileName = "WhatsNew English"
            break
        }
        
        textView.attributedText = Global.getRTFFileFromBundle(fileName: fileName)
        
        // now set user defaults to any value
        UserDefaults.standard.set("firstRun", forKey: Global.appVersion)
        
        // setup colors for UI controls
        doneButton.tintColor = themeColorUIControls
        doneButton.setTitle(Global.done, for: .normal)
        
        whatsNewLabel.text = Global.whatsNew
        
        // pointer interaction
        if #available(iOS 13.4, *) {
            customPointerInteraction(on: doneButton, pointerInteractionDelegate: self)
            
        } else {
            // Fallback on earlier versions
        }
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
        performSegue(withIdentifier: "onboardingSegue", sender: self)
        //dismiss(animated: true, completion: nil)
    }
 
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchDone]
        
        let done = NSButtonTouchBarItem(identifier: .touchDone, title: Global.done, target: self, action: #selector(doneAction(_:)))
        done.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [done]
        
        return touchBar
    }

    #endif
}
