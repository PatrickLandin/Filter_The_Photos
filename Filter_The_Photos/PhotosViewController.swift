//
//  PhotosViewController.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/14/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var assetsFetchResults : PHFetchResult!
  var assetCollection : PHAssetCollection!
  var imageManager = PHCachingImageManager()

  var collectionView : UICollectionView!
  
  var destinationImageSize : CGSize!
  
  var delegate : imageSelectedProtocol?
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    // flow layout
    self.collectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.itemSize = CGSize(width: 131, height: 131)
    
    rootView.addSubview(collectionView)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let views = ["collectionView" : self.collectionView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.navigationItem.title = NSLocalizedString("Cloud", comment: "Nav bar title for PhotosVC")
      
      self.imageManager = PHCachingImageManager()
      self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(nil)
      
      self.collectionView.dataSource = self
      self.collectionView.delegate = self
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")

        // Do any additional setup after loading the view.
    }

  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.assetsFetchResults.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryCell
    let asset = self.assetsFetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      cell.imageView.image = requestedImage
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //Requesting another image for mainVC that is of many bigger size
    let selectedAsset = self.assetsFetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(selectedAsset, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (bigRequestedImage, bigInfo) -> Void in
      println("xcode is shhtupid")
      self.delegate?.controllerDidSelectImage(bigRequestedImage)
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
  }
  
  func setupConstraintsOnRootView(rootView : UIView, forViews views: [String : AnyObject]) {
    
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVertical)
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintHorizontal)
    // collection view knows to avoid nav controller
  }

}
