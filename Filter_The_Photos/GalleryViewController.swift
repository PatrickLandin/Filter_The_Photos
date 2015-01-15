//
//  GalleryViewController.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/12/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit

protocol imageSelectedProtocol {
  func controllerDidSelectImage(UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var delegate : imageSelectedProtocol?
  var collectionViewFlowLayout : UICollectionViewFlowLayout!

  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    let views = ["collectionView" : self.collectionView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    title = "Image Gallery"
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = UIColor.whiteColor()
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
      let image1 = UIImage(named: "RoadBackground.jpg")
      let image2 = UIImage(named: "SeattleFromSky.jpg")
      let image3 = UIImage(named: "RoadNowhere.jpg")
      let image4 = UIImage(named: "TigerPlayers.jpg")
      let image5 = UIImage(named: "BaseballGrass.jpg")
      let image6 = UIImage(named: "FireImpreza.jpg")
      let image7 = UIImage(named: "MericaVette.jpg")
      let image8 = UIImage(named: "AustinJackson")
      self.images.append(image1!)
      self.images.append(image2!)
      self.images.append(image3!)
      self.images.append(image4!)
      self.images.append(image5!)
      self.images.append(image6!)
      self.images.append(image7!)
      self.images.append(image8!)
    
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "collectionViewPinched:")
    self.collectionView.addGestureRecognizer(pinchRecognizer)
    
        // Do any additional setup after loading the view.
    }
  
  // MARK: Gesture Recognizer
  func collectionViewPinched(sender: UIPinchGestureRecognizer) {
    
    switch sender.state {
    case .Began:
      println("Began")
    case .Changed:
      println("Changed with velocity \(sender.velocity)")
      self.collectionView.performBatchUpdates({ () -> Void in
        if sender.velocity > 0 {
          //increase item size
          let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width * 1.03, height: self.collectionViewFlowLayout.itemSize.height * 1.03)
          self.collectionViewFlowLayout.itemSize = newSize
        } else if sender.velocity < 0 {
          let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width / 1.03, height: self.collectionViewFlowLayout.itemSize.height / 1.03)
          self.collectionViewFlowLayout.itemSize = newSize
          //decrease item size
        }
        }, completion: {(finished) -> Void in
      })
    case .Ended:
      println("Ended")
      
    default:
      println("default")
    }
    println("collectionViewPinched")
  }
  
  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    let image = self.images[indexPath.row]
    cell.imageView.image = image
    
    cell.layer.cornerRadius = 15.0
    cell.layer.masksToBounds = true
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.delegate?.controllerDidSelectImage(self.images[indexPath.row])
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func setupConstraintsOnRootView(rootView : UIView, forViews views: [String : AnyObject]) {
    
//    let collectionView = views["collectionView"] as UIView!
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVertical)
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintHorizontal)
    
  }
  
}
