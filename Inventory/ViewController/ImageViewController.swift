//
//  ImageViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 13.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
// look at https://www.raywenderlich.com/560-uiscrollview-tutorial-getting-started for getting info
// about imageView and embedding in scroll view

import UIKit
import os


class ImageViewController: UIViewController {

    var image : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ImageViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.title = NSLocalizedString("Show Image", comment: "Show Image")
        
        imageView.image = image
        
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        os_log("ImageViewController viewForZooming", log: Log.viewcontroller, type: .info)
        
        return imageView
    }
}
