//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Alan Tseng on 2/10/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"



class ImageGalleryCollectionViewController: UICollectionViewController {
    
    // MARK: - Cache
    var imageStore: ImageStore!
    
    // MARK: - Model
    var imageGalleryModel: ImageGallery? {
        get {
            var temporaryURLModel = [Int: [URL: Double]]()
            if imageGallery != nil {
                for index in imageGallery.indices {
                    let urlInfo = imageGallery[index]
                    temporaryURLModel[index] = [urlInfo.url!: Double(urlInfo.aspectRatio!)]
                }
                return ImageGallery(urlInfo: temporaryURLModel)
            }
            return nil
        }
        set {
           // print("Model set with: \(newValue)")
            var tempImageGallery = [(url: URL?, aspectRatio: CGFloat?)]()
            if let sortedGalleryModel = newValue?.urlInfo.sorted(by: { $0.key < $1.key }) {
                
                for index in sortedGalleryModel.indices {
                    let urlTuple = sortedGalleryModel[index]
                    if let url = urlTuple.value.keys.first {
                        if let aspectRatio = urlTuple.value.values.first {
                            tempImageGallery.append((url: url, aspectRatio: CGFloat(aspectRatio)))
                            print("Temp gallery count: \(tempImageGallery.count)")
                        }
                    }
                }
            }
            imageGallery = tempImageGallery
            print("Successfully set up imageGallery with count: \(imageGallery.count)")
            print("Hope imageGallery reloads data")
            collectionView!.reloadData()
        }
    }
    
    var document: ImageGalleryDocument?

    // MARK: - Passed off info from model
    var imageGallery: [(url: URL?, aspectRatio: CGFloat?)]! {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    deinit {
        print("ImageGalleryCollectionVC has left the heap")
    }
    
    // MARK: - Actions
    private func save() {
        var temporaryURLModel = [Int: [URL: Double]]()
        for index in imageGallery.indices {
            let urlInfo = imageGallery[index]
            print(urlInfo)
            temporaryURLModel[index] = [urlInfo.url!: Double(urlInfo.aspectRatio!)]
        }
        document?.imageGallery = ImageGallery(urlInfo: temporaryURLModel)
        
        if document?.imageGallery != nil {
            document?.updateChangeCount(.done)
            print("Updated change count")
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        save()
        if document?.imageGallery != nil {
            document?.thumbnail = collectionView?.snapshot
        }
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var scaleForWidthOfCells: CGFloat = 1.0 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load")
        collectionView?.dropDelegate = self
        collectionView?.dragDelegate = self
        collectionView?.dragInteractionEnabled = true 
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.changeWidthScale(byReactingTo:)))
        collectionView?.addGestureRecognizer(pinch)
        
        
        // self.navigationItem.rightBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("CollectionView will appear")
        
        document?.open { success in
            
            if success {
                self.title = self.document?.localizedName
                self.imageGalleryModel = self.document?.imageGallery
                // print("Tried to open doc and set model", self.document?.imageGallery)
                self.collectionView?.reloadData()
            } else {
                print("Error opening document")
            }
        }
        
//        collectionView?.reloadData()
        flowLayout?.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("Image gallery count: \(imageGallery?.count ?? 0)")
    }
    
    // MARK: - Gesture Methods
    @objc func changeWidthScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scaleForWidthOfCells *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "showImage"?:
            if let cell = sender as? GalleryCollectionViewCell, let indexPath = collectionView?.indexPath(for: cell) {
                if let imageVC = segue.destination.contentsOfController as? ImageViewController {
                    imageVC.imageURL = cell.imageURL
                    imageVC.title = self.title! + " Image"
                    save()
                    if document?.imageGallery != nil {
                        document?.thumbnail = collectionView?.snapshot
                    }
                    self.document?.close()
                }
            }
        default:
            assertionFailure("Unable to identify segue identifier")
            break
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageGallery?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
    
        // Configure the cell
        if let imageCell = cell as? GalleryCollectionViewCell {
            imageCell.image = nil
            
            
            imageCell.imageURL = imageGallery?[indexPath.item].url
        }
    
        return cell
    }
    
    

}

extension ImageGalleryCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView?.cellForItem(at: indexPath) as? GalleryCollectionViewCell)?.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
        
        
    }
}

extension ImageGalleryCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isLocalSession = session.localDragSession != nil
        return session.canLoadObjects(ofClass: UIImage.self) && (isLocalSession || session.canLoadObjects(ofClass: NSURL.self))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy , intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                // item confirmed to come locally
                if let image = item.dragItem.localObject as? UIImage {
                    let itemToBeInserted = imageGallery?[sourceIndexPath.item]
                    collectionView.performBatchUpdates({
                        self.imageGallery?.remove(at: sourceIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        self.imageGallery?.insert(itemToBeInserted!, at: destinationIndexPath.item)
                        collectionView.insertItems(at: [destinationIndexPath])
                    }, completion: nil)
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                // dragged item is not local, is outside of app like safari
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                
                var galleryInfo: (URL?, CGFloat?)
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, imageError) in
                    if let image = provider as? UIImage {
                        DispatchQueue.main.async {
                            let aspectRatio = image.size.width / image.size.height
                            galleryInfo.1 = aspectRatio
                        }
                    } else {
                        print("Error with providing UIImage representation: \(imageError!)")
                        placeholderContext.deletePlaceholder()
                        return
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = provider as? URL {
                        let imageURL = url.imageURL
                        DispatchQueue.main.async {
                            galleryInfo.0 = imageURL
                            
                            placeholderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.imageGallery?.insert(galleryInfo, at: insertionIndexPath.item)
                            })
                        }
                    } else {
                        print("Error with providing url representation: \(error!)")
                        placeholderContext.deletePlaceholder()
                    }
                }
            }
        }
    }

}

extension ImageGalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let aspectRatio = imageGallery?[indexPath.item].aspectRatio {
            let cellWidth = CGFloat(200.0) * scaleForWidthOfCells
            let cellHeight = cellWidth / aspectRatio
            return CGSize(width: cellWidth, height: cellHeight)
        }
        return CGSize(width: 200, height: 200)
    }
}

