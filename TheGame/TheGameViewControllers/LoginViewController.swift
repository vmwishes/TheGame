//
//  LoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class LoginViewController: ChildViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var whyConnect : UIButton!
    
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
  
  @IBAction func whyFacebook(_ sender : UIButton)
  {
    self.infoPopup(title: "Connection", message:
      ["The Game is a social experience. A connection to the game server enables play with others.",
      "You can either create a Game account or use your Facebook login.",
      "Connecting with Facebook makes it easier to start matches with friends."]
    )
  }
  
  @IBAction func showCreateAccount(_ sender: UIButton)
  {
    showConnectionPopup(.CreateAccount)
  }
  
  @IBAction func showAccountLogin(_ sender: UIButton)
  {
    showConnectionPopup(.AccountLogin)
  }
  
  private func showConnectionPopup(_ id:ViewControllerID)
  {
    guard let mmvc = instantiate(.MultiModal) as? MultiModalViewController
      else { fatalError("Storyboard is missing MultiModalViewController") }
    
    mmvc.delegate = self
    mmvc.modalPresentationStyle = .overCurrentContext
    mmvc.modalTransitionStyle = .crossDissolve
    mmvc.present(id.rawValue)
    self.present(mmvc, animated: true) {
      debug("mmvc presented")
    }
  }
}

extension LoginViewController : MultiModalDelegate
{
  func viewController(_ identifier: String, for container: MultiModalViewController) -> ManagedViewController?
  {
    return nil // read all modal view controllers from storyboard
  }
  
  func configure(_ vc: ManagedViewController, for container: MultiModalViewController)
  {
    if let vc = vc as? CreateAccountViewController
    {
      vc.loginVC = self
    }
    else if let vc = vc as? AccountLoginViewController
    {
      vc.loginVC = self
    }
  }
  
  func cancel(_ vc:ManagedViewController, updateRoot:Bool = false)
  {
    dismiss(animated: true)
    {
      if updateRoot { self.rootViewController.update() }
    }
  }
  
}