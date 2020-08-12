//
//  AddANeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class Need {
    var type: NeedType?
    
}

class AddANeedVC: UIViewController, NeedSelectionDelegate, CityStateSelectionDelegate {
    
    @IBOutlet weak var needTextField: UITextField!
    @IBOutlet weak var needsPopOver: UIView!
    @IBOutlet weak var whereTextField: UITextField!
    var currentNeed = Need()
    
    
    
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTapGesture.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissOnTap(_ sender: Any) {
        if needsPopOver.isHidden == false {
            needsPopOver.isHidden = true
            dismissTapGesture.isEnabled = false
        }
    }
    
    
    
    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        needsPopOver.isHidden = true
        needTextField.text = need.rawValue.capitalized
        currentNeed.type = need
        dismissTapGesture.isEnabled = false
    }
    
    // MARK: - CityStateSelectionDelegate
    func selected(state: String, city: String) {
        whereTextField.text = state.capitalized + ", " + city.capitalized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toSearchLocation":
            let locVC = segue.destination as! CityStateSearchVC
            locVC.delegate = self
        case "needsPO":
            let needsTVC = segue.destination as! NeedsTVC
            needsTVC.delegate = self
        default:
            print("Different segue")
        }
    }
}

extension AddANeedVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == needTextField {
            needsPopOver.isHidden = false
            textField.resignFirstResponder()
            dismissTapGesture.isEnabled = true
        }
    }
}

protocol NeedSelectionDelegate {
    func didSelect(_ need: NeedType)
}

class NeedsTVC: UITableViewController {
    var delegate: NeedSelectionDelegate?
    let needs = NeedType.allCases
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(needs[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = needs[indexPath.row].rawValue.capitalized
        return cell
    }
}