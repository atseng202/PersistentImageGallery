//
//  GalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Alan Tseng on 2/10/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

let imageCache = URLCache.shared

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var draggedImageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            if imageURL != nil {
                // commented out && oldValue != imageURL
                
                fetchImage()
            }
        }
    }
    
    var aspectRatio: CGFloat? {
        if image != nil {
            return image!.size.width / image!.size.height
        }
        return nil 
    }
    
    var image: UIImage? {
        get {
            return draggedImageView?.image
        }
        set {
            draggedImageView.image = newValue
            spinner?.stopAnimating()
        }
    }
        
    private func fetchImage() {
        if let url = imageURL {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            if let cachedResponse = imageCache.cachedResponse(for: request) {
                let cachedImage = UIImage(data: cachedResponse.data)
                self.image = cachedImage
                print("DraggedImageView set its data from cache")
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
                        print("DraggedImageView set its data")
                    } else {
                        print("Image could not be loaded for this cell")
                        self?.spinner?.stopAnimating()
                    }
                }
            })
            task.resume()
            
//            spinner?.startAnimating()
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                let urlContents = try? Data(contentsOf: url)
//                DispatchQueue.main.async {
//                    if let imageData = urlContents, url == self?.imageURL  {
//                        if let image = UIImage(data: imageData) {
//
//                            self?.image = image
//                            print("DraggedImageView set its data")
//
//                        } else {
//                            print("Image could not be loaded for this cell")
//                            self?.spinner?.stopAnimating()
//                        }
//
//                    }
//                }
//            }
        }
    }
    
    
}
