//
//  FirstViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var myInventory : [Inventory] = (UIApplication.shared.delegate as! AppDelegate).fetchInventory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (myInventory.count == 0){
            (UIApplication.shared.delegate as! AppDelegate).generateSampleData()
        }
        //let x = (UIApplication.shared.delegate as! AppDelegate)
        
        (UIApplication.shared.delegate as! AppDelegate).showSampleData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

