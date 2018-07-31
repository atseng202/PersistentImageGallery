//
//  ImageViewController.swift
//  Cassini
//
//  Created by Alan Tseng on 2/8/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var imageView = UIImageView()
    
    var imageURL: URL? {
        didSet {
            image = nil
        
            // check if view is onscreen
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            if let cachedResponse = imageCache.cachedResponse(for: request) {
                let cachedImage = UIImage(data: cachedResponse.data)
                self.image = cachedImage
                print("ScrolledImageView set its data from cache")
                return
            }
            
            spinner?.startAnimating()
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    if let downloadedImage = UIImage(data: data!), url == self?.imageURL {
                        imageCache.storeCachedResponse(CachedURLResponse.init(response: response!, data: data!), for: request)
                        self?.image = downloadedImage
                        print("ScrollableImageView set the downloaded image")
                    } else {
                        print("Image could not be loaded for this VC")
                        self?.spinner?.stopAnimating()
                    }
                }
            })
            task.resume()
            // spinner.startAnimating()
            
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                let urlContents = try? Data(contentsOf: url)
//                DispatchQueue.main.async {
//                    if let imageData = urlContents, url == self?.imageURL {
//                        self?.image = UIImage(data: imageData)
//                    }
//                }
//            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if imageURL == nil {
//            imageURL = DemoURLs.stanford
//        }
    }

}
