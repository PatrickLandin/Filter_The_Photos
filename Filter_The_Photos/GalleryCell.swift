//
//  GalleryCell.swift
//  Filter_The_Photos
//
//  Created by Patrick Landin on 1/12/15.
//  Copyright (c) 2015 Patrick Landin. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.imageView)
    self.backgroundColor = UIColor.blackColor()
    imageView.frame = self.bounds
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 10.0
    
    let views = ["imageView" : imageView]

    let imageViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintVertical)
    let imageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintHorizontal)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
}