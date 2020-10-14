//
//  ViewMyHaveVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/19/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Toast_Swift

class ViewMyHaveVC: UIViewController {

    var have: Have? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var haveDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!
    @IBOutlet weak var pageHeaderView: SecondaryPageHeader!

    // MARK: - IBActions
    @IBAction func deleteHave(_ sender: Any) {
        deleteCurrentHave()
    }

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }

    func populateUI() {
        if let c = have?.category {
            if let cityState = have?.location {
                locationLabel.text = String(format: "%@ in %@", c, cityState.displayName())
            } else {
                locationLabel.text = String(format: "%@", c)
            }
        }
        
        var hl: String = ""
        if let h = have?.headline {
            hl = h
        }
        pageHeaderView.setTitleText(!hl.isEmpty ? hl : "No Headline!".taloneCased())
        var str: String = ""
        if let n = have?.desc {
            str = n
        }
        haveDescriptionTextView.text = !str.isEmpty ? str : "No Description!".taloneCased()
        personalNotesTextView.text = have?.personalNotes
        view.layoutIfNeeded()
    }

    private func deleteCurrentHave() {
        guard let have = self.have else { return }
        have.deleteHave()

        HavesDbWriter().deleteHave(id: have.id!, creator: have.createdBy ?? "") { error in
            if error == nil {
                self.view.makeToast("You have Deleted the Have", duration: 1.0, position: .center) {_ in
                    self.performSegue(withIdentifier: "dismissToMyHaves", sender: self)
                }
            } else {
                self.showOkayAlert(title: "Error", message: "Error while deleting have. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toTextViewHelper" {
//            guard let vc = segue.destination as? TextViewHelperVC else { fatalError() }
//            vc.configure(textView: personalNotesTextView, displayName: "personal notes", initialText: personalNotesTextView.text)
//        }
//    }
}

extension ViewMyHaveVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes", initialText: personalNotesTextView.text)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}