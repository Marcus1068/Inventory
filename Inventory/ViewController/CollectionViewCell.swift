//
//  CollectionViewCell.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var warrantyMonthsLabel: UILabel!
    
    @IBOutlet weak var warrantyLabel: UILabel!
    // select background color, works only on TVOS
    func markSelected(state: Bool){
        os_log("CollectionViewCell markSelected", log: Log.viewcontroller, type: .info)
        
        if state == true{
            self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        }
        else{
            self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
    }
    
    @objc func capital(_ sender: Any!) {
        os_log("CollectionViewCell capital", log: Log.viewcontroller, type: .info)
        
        // find my collection view
        var v : UIView = self
        repeat { v = v.superview! } while !(v is UICollectionView)
        let cv = v as! UICollectionView
        // ask it what index path we are
        let ip = cv.indexPath(for: self)!
        // relay to its delegate
        cv.delegate?.collectionView?(cv, performAction:#selector(capital), forItemAt: ip, withSender: sender)
    }
}
