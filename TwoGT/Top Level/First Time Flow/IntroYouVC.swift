//
//  IntroYouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/6/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import AlamofireImage

class IntroYouVC: YouVC {
    
    var facebookUserId: String?
    
    var profile: Profile? {
        didSet {
            //facebookUserId = profile?.userID
            if isViewLoaded {
                setProfileData()
            }
            // https://developers.facebook.com/docs/swift/reference/structs/userprofile.html/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileData()
        showOkayAlert(title: "this is you".taloneCased(), message: String(format: "the data you input here is not shared with anyone, unless you send it to them in a card.  you can access this section in the future from the dashboard.").taloneCased(), handler: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if animated {
            UserDefaults.standard.setValue(nil, forKey: State.stateDefaultsKey.rawValue)
        }
    }
    
    override func setInitialUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 62
        handleLabel.text = CoreDataGod.user.handle
    }
    
    func setProfileData() {
        if let p = profile {
            if let imageURL = p.imageURL(forMode: .normal, size: CGSize(width: 150.0, height: 150.0)) {
                let url = imageURL.absoluteURL
                
                imageButton.imageView?.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "avatar.png"), completion:  { response in
                    print(url)
                    do {
                        if let d = response.data, let dataAsImage = UIImage(data: d) {
                            //CoreDataImageHelper.shared.deleteAllImages()
                            CoreDataImageHelper.shared.saveImage(dataAsImage, fileName: "", url: imageURL.absoluteString)
                            self.setState()
                            self.showOkayAlert(title: "", message: "Image successfully saved", handler: nil)
                            
                            if let im = CoreDataImageHelper.shared.fetchAllImages() {
                                if let imageFromStorage = im.last?.image {
                                    let i = imageFromStorage.af.imageAspectScaled(toFit: self.imageButton.bounds.size)
                                    self.imageButton.imageView?.contentMode = .scaleAspectFill
                                    self.imageButton.setImage(i, for: .normal)
                                } //
                                
                            } else {
                                self.view.makeToast("Image saving and rerendering failed")
                                self.imageButton.setImage(#imageLiteral(resourceName: "avatar.png"), for: .normal)
                            }
                        } else {
                            print("-------------image data is fucked up after profile image retrieval for url: " + imageURL.absoluteString)
                        }
                    }
                })
            } else {
                print("-------------fucked up on profile image retrieval.")
            }
            // create profile object
            
        } else {
            if let im = CoreDataImageHelper().fetchAllImages() {
                if let imageFromStorage = im.last?.image {
                    let i = imageFromStorage.af.imageAspectScaled(toFit: self.imageButton.bounds.size)
                    self.imageButton.imageView?.contentMode = .scaleAspectFill
                    self.imageButton.setImage(i, for: .normal)
                }
            }
        }
    }
    
    func setState() {
        let u = UserDefaults.standard
        if u.string(forKey: State.stateDefaultsKey.rawValue) != State.youIntro.rawValue {
            u.setValue(State.youIntro.rawValue, forKey: State.stateDefaultsKey.rawValue)
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        let u = UserDefaults.standard
        u.setValue(nil, forKey: State.stateDefaultsKey.rawValue)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        appDelegate.setToFlow(storyboardName: "NoHome", identifier: "Main App VC")
    }
    
    // only save this state if something has been added
    override func unwindToYouVC(_ segue: UIStoryboardSegue) {
        setState()
        tableView.reloadData()
    }
}
