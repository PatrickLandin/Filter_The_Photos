//
//  ViewController.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/12/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, imageSelectedProtocol, UICollectionViewDataSource {
  
  let alertController = UIAlertController(title: "Stuff", message: "More Stuff", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let imageView = UIImageView()
//  let imageViewPic = UIImage(named: "AustinJackson")
//  let imageView = UIImageView(image: imageViewPic)
  var collectionView : UICollectionView!
  var collectionViewYConstraint : NSLayoutConstraint!
  var originalThumbnail : UIImage!
  var filterNames = [String]()
  let imageQueue = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.blackColor()
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(imageView)
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 20.0
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(photoButton)
    photoButton.setTitle("Photo Options", forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    rootView.addSubview(collectionView)
    self.collectionView.dataSource = self
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    
    let views = ["photoButton" : photoButton, "imageView" : self.imageView, "collectionView" : self.collectionView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    var doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed") //Use a selector
    navigationItem.rightBarButtonItem = doneButton
    var saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButtonPressed")
    navigationItem.leftBarButtonItem = saveButton
//    navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    title = "Filter"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Filet the Photos"
    
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery Pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true )
    }
    self.alertController.addAction(galleryOption)
    
    let galleryCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
    }
    self.alertController.addAction(galleryCancel)
    
    let galleryFilter = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectionViewYConstraint.constant = 10
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    }
    self.alertController.addAction(galleryFilter)
    
    let options = [kCIContextWorkingColorSpace : NSNull()] // helps keep things fast
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail)
    }
  }
  
  //MARK: Navigation button methods
  func doneButtonPressed() {
    self.collectionViewYConstraint.constant = (-200)
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func saveButtonPressed() {
    println("Save button pressed")
  }
  
  // MARK: ImageSelectedDelegate
  func controllerDidSelectImage(image: UIImage) {
    println("image selected (controllerDidSelect)")
    self.imageView.image = image
    self.generateThumbnail(image)
    
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
    }
    self.collectionView.reloadData()
  }
  
  // MARK: Button Stuff
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func generateThumbnail(originalImage : UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
  }
  
  // MARK: UICollectionView DataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnails.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
    let thumbnail = self.thumbnails[indexPath.row]
    if thumbnail.originalImage != nil {
      if thumbnail.filteredImage == nil {
        thumbnail.generateFilteredImage()
        cell.imageView.image = thumbnail.filteredImage!
      }
    }
    
    cell.layer.cornerRadius = 10.0
    cell.layer.masksToBounds = true
    
    return cell
  }
  
  // MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView : UIView, forViews views: [String : AnyObject]) {
    
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(photoButtonConstraintVertical)
    let photoButton = views["photoButton"] as UIView!
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(photoButtonConstraintHorizontal)
    photoButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)
    
    let imageView = views["imageView"] as UIView!
    let imageViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-75-[imageView]-20-[photoButton]", options: nil, metrics: nil, views: views)
    //72 to get just below nav bar
    rootView.addConstraints(imageViewConstraintVertical)
    let imageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[imageView]-8-|", options: nil, metrics: nil, views: views)
    //pinning to default margins?
    rootView.addConstraints(imageViewConstraintHorizontal)
    
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVertical)
    self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint
  }
  
}

