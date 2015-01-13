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
    self.backgroundColor = UIColor.whiteColor()
    imageView.frame = self.bounds
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 8.0
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
}