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
//  ReportsCollectionViewCell.swift
//  Inventory
//
//  Created by Marcus Deuß on 26.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

class InventoryCollectionViewCell: UICollectionViewCell {
 /*
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
   */
    @IBOutlet weak var inventoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // select background color, works only on TVOS
 /*   func markSelected(state: Bool){
        if state == true{
            self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        }
        else{
            self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
    }
    */
 /*   override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: nil)
            }
        }
    } */
  /*
    @objc func capital(_ sender: Any!) {
        // find my collection view
        var v : UIView = self
        repeat { v = v.superview! } while !(v is UICollectionView)
        let cv = v as! UICollectionView
        // ask it what index path we are
        let ip = cv.indexPath(for: self)!
        // relay to its delegate
        cv.delegate?.collectionView?(cv, performAction:#selector(capital), forItemAt: ip, withSender: sender)
    } */
}
