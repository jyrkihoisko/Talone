//
//  AddNewPhoneNumberVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/25/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AddNewPhoneNumberVC: UIViewController {
    
    @IBOutlet weak var labelTextField: DesignableTextField!
    @IBOutlet weak var numberTextField: DesignableTextField!
    
    let adder = AddressAdder()
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            guard let phones =  AppDelegate.user.phoneNumbers else { fatalError() }
            var allPhones: [PhoneNumber] = []
            for p in phones {
                allPhones.append(p as! PhoneNumber)
            }
            return allPhones.sorted { return $0.title! < $1.title! }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addPhoneNumber() {
        let newPhone = PhoneNumber(context: adder.managedObjectContext)

        newPhone.title = labelTextField.text?.lowercased().pure()
        newPhone.number = numberTextField.text?.pure()
        AppDelegate.user.addToPhoneNumbers(newPhone) // Make sure this works and is necessary

        if adder.saveContext() {
            performSegue(withIdentifier: "unwindToYou", sender: nil)
        }
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        if checkValidity() {
            addPhoneNumber()
        }
    }
}

extension AddNewPhoneNumberVC {
    private func showReplaceAlert() {
        showOkayOrCancelAlert(title: "Uh Oh", message: "A phone number with this label already exists. Replace??", okayHandler: { (_) in
            self.addPhoneNumber()
        }, cancelHandler: nil)
    }
    
    private func checkValidity() -> Bool {
        for p in phoneNumbers {
            if p.title == labelTextField.text?.lowercased().pure() {
                showReplaceAlert()
                return false
            }
        }
        
        let outletCollection = [labelTextField, numberTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  You must be trying to pull something.", handler: nil)
                return false
            }
        }
        return true
    }
}