//
//  DetailViewController.swift
//  Tabi
//
//  Created by Bob De Kort on 12/13/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import EventKit
import MapKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {

    var event: Event?
    
    
    
    // Like button
    
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likeButtonPressed(_ sender: Any) {
        if let event = event {
            if event.liked == true {
                if let eventId = event.id {
                    ApiService.deleteFavoriteEvent(eventId: Int(eventId))
                }
                likeButton.setImage(UIImage(named: "like"), for: .normal)
                event.liked = false
                
            } else {
                
                if let eventId = event.id {
                    ApiService.favoriteEvent(eventId: (Int(eventId)))
                }
                event.liked = true
                likeButton.setImage(UIImage(named: "liked"), for: .normal)
            }
        }
    }
    
    // labels
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationlabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
//    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    // Stack views
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var urlStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    
    // Icons
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var timeImageView: UIImageView!
    
    @IBOutlet weak var urlImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupLikeButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // location gesture
        let locationGesture = UITapGestureRecognizer(target: self, action: #selector(self.handelLocationPressed(_:)))
        locationStackView.isUserInteractionEnabled = true
        locationGesture.delegate = self
        self.locationStackView.addGestureRecognizer(locationGesture)
        
        //urlgesture
        let urlGesture = UITapGestureRecognizer(target: self, action: #selector(self.handelUrlPressed(_:)))
        urlStackView.isUserInteractionEnabled = true
        urlGesture.delegate = self
        self.urlStackView.addGestureRecognizer(urlGesture)
        
        // calendar gesture
        let calendarGesture = UITapGestureRecognizer(target: self, action: #selector(self.handelDatePressed(_:)))
        dateStackView.isUserInteractionEnabled = true
        calendarGesture.delegate = self
        self.dateStackView.addGestureRecognizer(calendarGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData() {
        setupImageView()
        setupIcons()
        setupTitleLabels()
        setupDateLabels()
        setupLocationLabels()
        setupUrlLabel()
        setupDescriptionView()
        setupLikeButton()
    }
    
    func loadEvent(eventId: String) {
        ApiService.sharedInstance.fetchSingleEvent(eventId: eventId, completion: { (event) in
            self.event = event
        })
    }
    
    func setupNavBar(){
        self.navigationController?.navigationBar.tintColor = .white
        
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handelShare))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    func setupIcons(){
        locationImageView.image = UIImage(named: "location")
        timeImageView.image = UIImage(named: "time")
        urlImageView.image = UIImage(named: "url")
    }
    
    func setupTitleLabels(){
        if let event = event {
            titleLabel.text = event.title
            
            let subTitletext: String?
            if event.price == 0.0 {
                subTitletext = "Free"
            } else if event.price == nil {
                subTitletext = ""
            } else if event.price == 1{
                subTitletext = "Paid"
            } else {
                subTitletext = "$\(String(describing: event.price!))"
            }
            subTitleLabel.text = subTitletext
        } else {
            titleLabel.isHidden = true
            subTitleLabel.isHidden = true
        }
    }
    
    func setupImageView(){
        if let event = event{
            if let imageUrl = event.image{
                imageView.downloadedFrom(link: imageUrl)
            } else {
                imageView.isHidden = true
            }
        }
    }
    
    func setupDateLabels(){
        if let event = event {
            // First day and month view
            if let start = event.start_time {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd"
                let day = dateFormatter.string(from: start)
                dayLabel.text = day
                dateFormatter.dateFormat = "MMM"
                let month = dateFormatter.string(from: start)
                monthLabel.text = month
                
                if let end = event.end_time {
                    dateFormatter.dateFormat = "EEEE, MMM dd 'at' hh:mm a"
                    let dateStart = dateFormatter.string(from: start)
                    
                    dateFormatter.dateFormat = "hh:mma"
                    let endTime = dateFormatter.string(from: end)
                    
                    dateLabel.text = (dateStart + " - " + endTime)
                } else {
                    dateFormatter.dateFormat = "EEEE, MMM dd 'at' hh:mm a"
                    let dateStart = dateFormatter.string(from: start)
                    
                    dateLabel.text = dateStart
                }
            } else {
                dateLabel.isHidden = true
            }
        } else {
            dayLabel.isHidden = true
            monthLabel.isHidden = true
            dateLabel.isHidden = true
        }
    }
    
    func setupLocationLabels(){
        if let event = event {
            if let location = event.location {
                locationlabel.text = location
            } else {
                locationlabel.isHidden = true
            }
            if let address = event.location_address {
                locationAddressLabel.text = address
            } else {
                locationAddressLabel.isHidden = true
            }
        }
    }
    
    func setupUrlLabel(){
        if let event = event {
            if event.url != nil {
                urlLabel.text = "See more"
            } else {
                urlLabel.isHidden = true
            }
        }
    }
    
    
    func setupDescriptionView(){
        if let event = event {
            if let description = event.event_description{
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 5
                
                let attrString = NSMutableAttributedString(string: description)
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                
                descriptionLabel.attributedText = attrString
                
            } else {
                descriptionLabel.isHidden = true
            }
        }
    }
    
    
    func setupLikeButton(){
        if let event = event {
            if let saved = event.liked {
                switch saved {
                case true:
                    likeButton.setImage(UIImage(named: "liked"), for: .normal)
                case false:
                    likeButton.setImage(UIImage(named: "like"), for: .normal)
                default:
                    return
                }
            }
        }
    }
    
    func handelShare(sender: UIButton){
        print("share")
        
        
        
        if let event = self.event {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d"
            let date = dateFormatter.string(from: event.start_time!)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.amSymbol = "AM"
            timeFormatter.pmSymbol = "PM"
            let time = timeFormatter.string(from: event.start_time!)
            
            let text = "\(date) \(time)"
            
            let textToShare = "Check out this awesome event!\n\(event.title!)\n\(text)\nHosted at \(event.location!)\n"
            let eventId = event.id
            
            if let myWebsite = NSURL(string: "https://collegedojo.herokuapp.com/events/\(eventId!)") {
                let objectsToShare = [textToShare,myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender
                self.present(activityVC, animated: true, completion: nil)
                
            }
        }
    }
    
    func handelDatePressed(_ recognizer: UITapGestureRecognizer){
        
        let alertController = UIAlertController(title: "Add to calendar?", message: "Would you like to add this event to your calendar?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { action in
            return
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { action in
            
            if let event = self.event {
                if let title = event.title {
                    if let start = event.start_time{
                        if let end = event.end_time{
                            addEventToCalendar(title: title, description: event.description, startDate: start, endDate: end, completion: { [weak self] (succes, error) in
                                if succes == true{
                                    let alert = UIAlertController(title: "Succes", message: "Event added to calendar ", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                                    self?.present(alert, animated: true, completion: nil)
                                } else {
                                    let alert = UIAlertController(title: "Alert", message: "Did not add to calendar\nReason: \n\(error)", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                                    self?.present(alert, animated: true, completion: nil)
                                }
                                
                            })
                        }
                    }
                }
            }
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    func handelLocationPressed(_ recognizer: UITapGestureRecognizer){

        if let event = event {
            if let lat = event.latitude, let lon = event.longitude {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.openURL(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving")!)
                } else {
                    
                    let latitude:CLLocationDegrees =  CLLocationDegrees(lat)
                    let longitude:CLLocationDegrees =  CLLocationDegrees(lon)
                    
                    let regionDistance:CLLocationDistance = 10000
                    let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                    let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                    let options = [
                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                    ]
                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = event.location
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    func handelUrlPressed(_ recognizer: UITapGestureRecognizer){
        if let event = event{
            if let url = event.url{
                open(string: url)
            }
        }
        
    }
}
