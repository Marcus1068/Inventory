//
//  ManageViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

// will be used to call room edit, add views etc.

import UIKit
import os

class ManageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("ManageTableViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        // Do any additional setup after loading the view.
        
        //self.tableView.layer.cornerRadius = 8.0
        //self.tableView.layer.masksToBounds = true
        
        //self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = NSLocalizedString("Manage items", comment: "Manage items table view title")
        //navigationController?.navigationBar.barTintColor = themeColor
        
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        
        //tableView.isScrollEnabled = false
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        os_log("ManageTableViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
  /*      if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }*/
    }

    
    // define table view header size
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    
    // define table view header layout
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 38)!
        header.textLabel?.textColor = UIColor.lightGray
    }
    
}
