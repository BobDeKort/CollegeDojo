//
//  LoginCollectionViewCell.swift
//  onBoarding
//
//  Created by Bob De Kort on 12/18/16.
//  Copyright © 2016 Bob De Kort. All rights reserved.
//

import UIKit

class LoginCollectionViewCell: UICollectionViewCell {
    var pageImage: String? {
        didSet {
            
            guard let page = pageImage else {
                return
            }
            
            imageView.image = UIImage(named: page)
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        
        imageView.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
