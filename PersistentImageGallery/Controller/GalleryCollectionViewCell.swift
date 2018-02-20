//
//  GalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Alan Tseng on 2/10/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

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
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL  {
                        if let image = UIImage(data: imageData) {
                            self?.image = image
                            print("DraggedImageView set its data")
                        } else {
                            print("Image could not be loaded for this cell")
                            self?.spinner?.stopAnimating()
                        }
                        
                    }
                }
            }
        }
    }
    
    
}
