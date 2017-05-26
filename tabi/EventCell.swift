//
//  EventCell.swift
//  tabi
//
//  Created by Bob De Kort on 12/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit


class EventCell: BaseCell {
    
    var event: Event? {
        didSet{
            // Setup all views
            if let event = event {
                titleLabel.text = event.title
                setUpEventImage()
                
                var subtitleText: String = ""
                var day = ""
                var month = ""
                
                if let start = event.start_time {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE hh:mma"
                    subtitleText += "\(dateFormatter.string(from: start)) • "
                    
                    dateFormatter.dateFormat = "dd"
                    day = "\(dateFormatter.string(from: start))"
                    
                    dateFormatter.dateFormat = "MMM"
                    month = "\(dateFormatter.string(from: start))"
                }
                
                if let location = event.location{
                    subtitleText += "\(location)"
                }
                if event.price != nil {
                    if event.price as! Float == 0.0{
                        priceLabel.text = "Free!"
                    } else if event.price == nil {
                        priceLabel.text = ""
                    } else if event.price == 1{
                        priceLabel.text = "Paid"
                    } else {
                        priceLabel.text = "$\(event.price!)"
                    }
                } else {
                    priceLabel.text = "See description for price"
                }
                
                priceLabel.font = priceLabel.font.withSize(14)
                
                subtitleLabel.text = subtitleText
                
                if let dayLabel = dateView.dayLabel {
                    dayLabel.text = day
                    dayLabel.font = dayLabel.font.withSize(25)
                }
                
                if let monthLabel = dateView.monthLabel {
                    monthLabel.text = month
                    monthLabel.textColor = .red
                }
                
                if let title = event.title {
                    let size = CGSize(width: frame.width - 16 - 44 - 8 - 16, height: 1000)
                    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                    let estimatedRect = NSString(string: title).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
                    
                    if estimatedRect.size.height > 20 {
                        titleLabelHeightConstraint?.constant = 44
                    } else {
                        titleLabelHeightConstraint?.constant = 20
                    }
                }
                setupLikeButton()
            }
        }
    }
    
    func setUpEventImage(){
        if let eventImage = event?.image{
            eventImageView.loadImageUsingUrlString(eventImage)
        }
    }
    
    let eventImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
//        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(203, green: 210, blue: 215)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = UIFont(name: (label.font?.fontName)!, size: 13)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let dateView: DateView = {
        let dayLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let monthLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let view = DateView(frame: CGRect.zero, dayLabel: dayLabel, monthLabel: monthLabel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        return label
    }()
    
    var likeButton: LikeButton = {
//        let button = LikeButton(frame: CGRect(x: 330, y: 160, width: 30, height: 30))
        let button = LikeButton(frame: CGRect.zero)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.image = UIImage(named: "like")
        button.setImage(UIImage(named: "like"), for: .normal)
        button.setImage(UIImage(named: "liked"), for: .selected)
        button.isEnabled = true
        return button
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() {
        
        addSubview(eventImageView)
        addSubview(likeButton)
        addSubview(separatorView)
        addSubview(dateView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(priceLabel)
        
        addConstraintsWithFormat("H:|[v0]|", views: eventImageView)
        
        addConstraintsWithFormat("H:|[v0(44)]", views: dateView)
        addConstraintsWithFormat("H:|-8-[v0]|", views: dateView.dayLabel!)
        addConstraintsWithFormat("H:|-8-[v0]|", views: dateView.monthLabel!)
        
        
        //vertical constraints
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(44)]-40-[v2(8)]|", views: eventImageView, dateView, separatorView)
        
        addConstraintsWithFormat("H:|[v0]|", views: separatorView)
        
        // Like button
        
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: .right, relatedBy: .equal, toItem: eventImageView, attribute: .right, multiplier: 1, constant: -5))
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: .bottom, relatedBy: .equal, toItem: eventImageView, attribute: .bottom, multiplier: 1, constant: -5))
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 30))
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 30))
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: eventImageView, attribute: .bottom, multiplier: 1, constant: 8))
        //left constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: dateView, attribute: .right, multiplier: 1, constant: 16))
        //right constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: eventImageView, attribute: .right, multiplier: 1, constant: 0))
        
        //height constraint
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 44)
        addConstraint(titleLabelHeightConstraint!)
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 0))
        //left constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .left, relatedBy: .equal, toItem: dateView, attribute: .right, multiplier: 1, constant: 16))
        //right constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .right, relatedBy: .equal, toItem: eventImageView, attribute: .right, multiplier: 1, constant: 0))
        //height constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20))
        
        addConstraint(NSLayoutConstraint(item: priceLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: priceLabel, attribute: .left, relatedBy: .equal, toItem: subtitleLabel, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: priceLabel, attribute: .right, relatedBy: .equal, toItem: subtitleLabel, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: priceLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20))
        
        addConstraint(NSLayoutConstraint(item: priceLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -12))

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let task = self.eventImageView.currentRequest{
            task.cancel()
        }
        self.eventImageView.image = nil
        self.likeButton.isSelected = false
    }
    
    func setupLikeButton(){
        if let event = event {
            if let saved = event.liked {
                switch saved {
                case true:
                    likeButton.isSelected = true
                    likeButton.reloadInputViews()
                case false:
                    likeButton.isSelected = false
                    likeButton.reloadInputViews()
                default:
                    return
                }
            }
        }
    }
}

class DateView: UIView {
    var dayLabel: UILabel?
    var monthLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(frame: CGRect, dayLabel: UILabel, monthLabel: UILabel) {
        super.init(frame: frame)
        
        self.dayLabel = dayLabel
        self.dayLabel?.text = "17"
        self.monthLabel = monthLabel
        self.monthLabel?.text = "Dec"
        
        self.addSubview(dayLabel)
        self.addSubview(monthLabel)
        
        self.addConstraintsWithFormat("V:|[v0][v1]|", views: dayLabel, monthLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
