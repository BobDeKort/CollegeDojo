//
//  DetailView.swift
//  Tabi
//
//  Created by Bob De Kort on 12/11/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
}


class DetailView2: UIView {
    
    var event: Event? {
        didSet{
            setupImageView()
            
            titleLabel.text = event?.title
            
        }
    }
    
    var shouldSetupConstraints = true
    
    var imageView: CustomImageView = {
        let imageView = CustomImageView(frame: CGRect.zero)
        imageView.backgroundColor = UIColor.gray
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor(red: 0.0/255.0, green: 113.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        return titleLabel
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red: 0.0/255.0, green: 113.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red: 0.0/255.0, green: 113.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red: 0.0/255.0, green: 113.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        return label
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(dateLabel)
        self.addSubview(locationLabel)
        self.addSubview(descriptionLabel)
        
        // Horizontal constraints
//        addConstraintsWithFormat("H:|[v0,v1,v2,v3,v4]|", views: imageView, titleLabel, dateLabel, locationLabel, descriptionLabel)
        addConstraintsWithFormat("H:|[v0]|", views: imageView)
        addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dateLabel)
        addConstraintsWithFormat("H:|[v0]|", views: locationLabel)
        addConstraintsWithFormat("H:|[v0]|", views: descriptionLabel)
        
        // Vertical constraints
        addConstraintsWithFormat("V:|[v0]-8-[v1]-8-[v2][v3]-8-[v]|", views: imageView, titleLabel, dateLabel, locationLabel, descriptionLabel)
    }
    
    func setupImageView(){
        if let event = event{
            imageView.loadImageUsingUrlString(event.image!)
        }
    }
    
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
