//
//  ViewController.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/12/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, imageSelectedProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let alertController = UIAlertController(title: NSLocalizedString("Filter the Photos", comment: "This is the title for our al;ert controller"), message: NSLocalizedString("Find a photo, take a photo, filter a photo.", comment: "This is the message for our alert controller"), preferredStyle: UIAlertControllerStyle.ActionSheet)
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
  
  var doneButton : UIBarButtonItem!
  var shareButton : UIBarButtonItem!
  
  var imageViewBottomConstraint : NSLayoutConstraint!
//  var imageViewLeftConstraint : NSLayoutConstraint!
//  var imageViewRightConstraint : NSLayoutConstraint!
  
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
    photoButton.setTitle(NSLocalizedString("Photo Options", comment: "Title for main photos button"), forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    rootView.addSubview(collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    
    let views = ["photoButton" : photoButton, "imageView" : self.imageView, "collectionView" : self.collectionView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = NSLocalizedString("Filet the Photos", comment: "Nav bar title")
    
//    self.imageView.contentMode
    
    var doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed")
    self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonPressed")
    self.navigationItem.rightBarButtonItem = self.shareButton
    //    navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
    
    let galleryOption = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Title for gallery button"), style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery Pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true )
    }
    self.alertController.addAction(galleryOption)
    
    let galleryCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title for cancel button"), style: UIAlertActionStyle.Cancel) { (action) -> Void in
    }
    self.alertController.addAction(galleryCancel)
    
    let galleryFilter = UIAlertAction(title: NSLocalizedString("Filters", comment : "Title for filters button"), style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectionViewYConstraint.constant = 10
      self.imageViewBottomConstraint.constant = self.imageView.frame.height * 0.2
      
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
              })
      let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button"), style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonPressed")
      self.navigationItem.rightBarButtonItem = doneButton
    }
    self.alertController.addAction(galleryFilter)
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraOption = UIAlertAction(title: NSLocalizedString("Camera", comment: "Title for camera button"), style: .Default, handler: { (action) -> Void in
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
      })
      self.alertController.addAction(cameraOption)
    }
    
    let photoOption = UIAlertAction(title: NSLocalizedString("Cloud", comment: "Title for cloud photos button"), style: .Default) { (action) -> Void in
      let photosVC = PhotosViewController()
      photosVC.destinationImageSize = self.imageView.frame.size
      photosVC.delegate = self
      self.navigationController?.pushViewController(photosVC, animated: true)
    }
    self.alertController.addAction(photoOption)
    
    let options = [kCIContextWorkingColorSpace : NSNull()] // helps keep things fast
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  //MARK: Setup Thumbnails
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIDotScreen", "CIHatchedScreen"]
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail)
    }
  }
  
  // MARK: ImageSelectedDelegate
  func controllerDidSelectImage(image: UIImage) {
    println("image selected (controllerDidSelect)")
    self.imageView.image = image
    self.generateThumbnail(image)
    
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
      thumbnail.filteredImage = nil
    }
    self.collectionView.reloadData()
  }
  
  // MARK: UIImagePickerController
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(image!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: Button Selectors
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func generateThumbnail(originalImage : UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    //endimagecontext
  }
  
  func doneButtonPressed() {
    println("done button pressed")
    self.collectionViewYConstraint.constant = (-120)
    self.imageViewBottomConstraint.constant = 20
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.navigationItem.rightBarButtonItem = self.shareButton
  }
  
  func shareButtonPressed() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      composeViewController.addImage(self.imageView.image)
      self.presentViewController(composeViewController, animated: true, completion: nil)
    } else {
      //tell user to sign into to twitter to use this feature
    }
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
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let selectedFilter = self.thumbnails[indexPath.row].filterName
    
    let startImage = CIImage(image: self.imageView.image)
    let filter = CIFilter(name: selectedFilter)
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    self.imageView.image = UIImage(CGImage: imageRef)
    
    println(selectedFilter)
    
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
    self.imageViewBottomConstraint = imageViewConstraintVertical[1] as NSLayoutConstraint
    //72 to get just below nav bar
    rootView.addConstraints(imageViewConstraintVertical)
    let imageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[imageView]-8-|", options: nil, metrics: nil, views: views)
    //pinning to default margins
    rootView.addConstraints(imageViewConstraintHorizontal)
//    self.imageViewLeftConstraint = imageViewConstraintHorizontal[0] as NSLayoutConstraint
//    self.imageViewRightConstraint = imageViewConstraintHorizontal[1] as NSLayoutConstraint
    
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVertical)
    self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint
  }
  
}

