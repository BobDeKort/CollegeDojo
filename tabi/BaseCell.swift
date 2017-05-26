//
//  BaseCell.swift
//  Tabi
//
//  Created by Kojin on 12/12/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    var navigationController: UINavigationController?
    var parentView: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
