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
    @IBOutlet weak var pdfAttachment: UIImageView!
    /*
    // gets called when user selects a cell in collection view
    override var isSelected: Bool {
        didSet {
            //myImage.layer.borderWidth = isSelected ? 10 : 0
            //print("is selected")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //myImage.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
 
 */
    
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
    
    func toggleSelected()
    {
        if (isSelected){
            backgroundColor = UIColor.systemGreen
        }else {
            backgroundColor = UIColor.systemGray
        }
    }
}
