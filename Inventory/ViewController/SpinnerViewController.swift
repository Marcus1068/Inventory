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
//  SpinnerViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 16.05.20.
//  Copyright © 2020 Marcus Deuß. All rights reserved.
//

import UIKit

/*
 use it this way:
 func createSpinnerView() {
     let child = SpinnerViewController()

     // add the spinner view controller
     addChild(child)
     child.view.frame = view.frame
     view.addSubview(child.view)
     child.didMove(toParent: self)

     // wait two seconds to simulate some work happening
     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         // then remove the spinner view controller
         child.willMove(toParent: nil)
         child.view.removeFromSuperview()
         child.removeFromParent()
     }
 }
 */

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        
        label.textAlignment = .center
        label.text = NSLocalizedString("Please wait...", comment: "Please wait")
        label.textColor = .systemBlue
        label.backgroundColor = UIColor(white: 0, alpha: 0.7)

        view.addSubview(label)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
