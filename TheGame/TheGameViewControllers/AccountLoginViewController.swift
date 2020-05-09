//
//  AccountLoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername : String?

class AccountLoginViewController: UIViewController, ManagedViewController
{
  @IBOutlet weak var managedView: UIView!
  
  var loginVC   : LoginViewController?
  var container : MultiModalViewController?
    
  @IBOutlet weak var username  : LoginTextField!
  @IBOutlet weak var password  : LoginTextField!
  
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var cancelButton : UIButton!
  
  private var updateTimer : Timer?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    managedView.layer.cornerRadius = 10
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.gray.cgColor
    managedView.layer.borderWidth = 1.0
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    username.text = cachedUsername ?? ""
    password.text = ""
    
    update()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername = username.text
  }
  
  // MARK:- IBActions
  
  @IBAction func cancel(_ sender:UIButton)
  {
    loginVC?.cancel(self)
  }
  
  func update()
  {
    loginButton.isEnabled =
      (username.text ?? "").count > 0 &&
      (password.text ?? "").count > 0
  }
}

// MARK:- Text Field Delegate

extension AccountLoginViewController : LoginTextFieldDelegate, UITextFieldDelegate
{
  func loginTextFieldUpdated(_ sender:LoginTextField)
  {
    startUpdateTimer()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    startUpdateTimer()
    return true
  }
  
  func startUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in self.update() }
  }
}