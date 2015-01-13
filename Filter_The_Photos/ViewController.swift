//
//  ViewController.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/12/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let alertController = UIAlertController(title: "Stuff", message: "More Stuff", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(photoButton)
    photoButton.setTitle("Photo Button", forState: .Normal)
    photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    let imageViewPic = UIImage(named: "AustinJackson")
    let imageView = UIImageView(image: imageViewPic)
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(imageView)
    
    let views = ["photoButton" : photoButton, "imageView" : imageView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery Pressed")
      let galleryVC = GalleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true )
    }
    self.alertController.addAction(galleryOption)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
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
    let imageViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[imageView]-20-[photoButton]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(imageViewConstraintVertical)
    let imageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[imageView]-20-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(imageViewConstraintHorizontal)
//    imageView.contentMode.
  }
  
}
