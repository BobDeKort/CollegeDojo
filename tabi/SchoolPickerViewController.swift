//
//  SchoolPickerViewController.swift
//  Tabi
//
//  Created by Bob De Kort on 1/8/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

//enum School: Int {
//    case MakeSchool = 1
//    case Harvard
//    
//    static func getIdByName(name: String) -> Int {
//        if name == "Make School" {
//            return School.MakeSchool.rawValue
//        } else if name == "Harvard" {
//            return School.Harvard.rawValue
//        } else {
//            return 0
//        }
//    }
//}

import UIKit

class SchoolPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // IBOutlets
    
    @IBOutlet weak var schoolPickerView: UIPickerView!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.removeAnimate()
        
        let school = schoolArray[(schoolPickerView.selectedRow(inComponent: 0) - 1)]
        let parentVC = self.parent as! LoginViewController
        parentVC.school = school
    }
    
    // Variables
    var schoolArray: [School] = []{
        didSet{
            for i in schoolArray{
                pickerData.append(i.name)
            }
        }
    }
    
    var pickerData: [String] = ["-"] {
        didSet{
            schoolPickerView.reloadAllComponents()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.showAnimate()
        schoolPickerView.delegate = self
        schoolPickerView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupContinueButton()
        getSchools()
        continueButton.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getSchools(){
        ApiService.sharedInstance.getSchools(completion: { [unowned self] (schools) in
            self.schoolArray.append(contentsOf: schools)
        })
    }
    
    func setupContinueButton(){
        if let button = continueButton {
            button.backgroundColor = UIColor.rgb(2409, green: 127, blue: 19)
            button.layer.cornerRadius = button.layer.frame.height / 4
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.rgb(173, green: 172, blue: 173).cgColor
        }
    }
    
    // Picker View
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerData[row] != "-"{
           continueButton.isHidden = false
        } else {
            continueButton.isHidden = true
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Animation for popup
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{ [unowned self] (finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
}
