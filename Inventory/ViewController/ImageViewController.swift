//
//  ImageViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 13.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//  look at https://www.raywenderlich.com/560-uiscrollview-tutorial-getting-started for getting info
//  about imageView and embedding in scroll view
//  set content mode of imageView to aspect fill for getting image to max screen size and avoid empty scroll view areas

import UIKit
import os


class ImageViewController: UIViewController {

    var image : UIImage?
    var titleForImage: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ImageViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = titleForImage // NSLocalizedString("Show Image", comment: "Show Image")
        
        imageView.image = image
        
        //scrollView.setContentOffset(CGPoint(x:0, y:40), animated: true)
        
        //scrollView.bounces = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        os_log("ImageViewController viewWillLayoutSubviews", log: Log.viewcontroller, type: .info)
        
        updateMinZoomScaleForSize(view.bounds.size)
    }

    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        os_log("ImageViewController viewForZooming", log: Log.viewcontroller, type: .info)
        
        return imageView
    }
}
