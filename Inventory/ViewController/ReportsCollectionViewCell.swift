//
//  ReportsCollectionViewCell.swift
//  Inventory
//
//  Created by Marcus Deuß on 26.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class ReportsCollectionViewCell: UICollectionViewCell {
 /*
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
   */
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var romeNameLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    
    // select background color, works only on TVOS
    func markSelected(state: Bool){
        if state == true{
            self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        }
        else{
            self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
    }
    
    @objc func capital(_ sender: Any!) {
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
