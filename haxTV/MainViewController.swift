//
//  ViewController.swift
//  haxTV
//
//  Created by Davidson, Shay on 31/01/2016.
//  Copyright © 2016 CPC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var avatarField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let name: String? = defaults.stringForKey("name")
        if name != nil {
            nameField.text = name
        }
        
        let avatar: String? = defaults.stringForKey("avatar")
        if avatar != nil {
            avatarField.text = avatar
        }
    }
    
    @IBAction func onJoinGame(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nameField.text, forKey: "name")
        defaults.setObject(avatarField.text, forKey: "avatar")

        let vc = GamePadViewController()
        vc.playerName = nameField.text
        vc.playerAvatar = avatarField.text
        presentViewController(vc, animated: true, completion: nil)
    }
}

