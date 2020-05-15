//
//  CreateAccountViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername    : String?
fileprivate var cachedDisplayName : String?
fileprivate var cachedEmail       : String?

class CreateAccountViewController : ModalViewController
{
  var loginVC : LoginViewController?
  
  //MARK:- Subviews
  
  var usernameTextField    : LoginTextField!
  var password1TextField   : LoginTextField!
  var password2TextField   : LoginTextField!
  var displayNameTextField : UITextField!
  var emailTextField       : UITextField!
  
  var usernameInfo         : UIButton!
  var passwordInfo         : UIButton!
  var displayNameInfo      : UIButton!
  var emailInfo            : UIButton!
  
  var usernameError        : UILabel!
  var passwordError        : UILabel!
  var displayNameError     : UILabel!
  var emailError           : UILabel!
  
  var createButton         : UIButton!
  var cancelButton         : UIButton!
  
  // MARK:- View State
  
  
  
  init(loginVC:LoginViewController? = nil)
  {
    self.loginVC = loginVC
    super.init(title: "Create New Account")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let loginDelegate = LoginTextFieldDelegate( { self.checkAll() } )
    
    let usernameLabel = addHeader("Username", below: topMargin)
    usernameTextField = addLoginEntry(below: usernameLabel, delegate: loginDelegate)
    usernameInfo = addInfoButton(to: usernameTextField, target: self)
    
    let passwordLabel = addHeader("Password", below: usernameTextField)
    password1TextField = addLoginEntry(below: passwordLabel, password: true, delegate: loginDelegate)
    password2TextField = addLoginEntry(below: password1TextField, placeholder: "retype to confirm", password: true, delegate: loginDelegate)
    passwordInfo = addInfoButton(to: password1TextField, target: self)
    
    let gap = addGap(below:password2TextField)
    
    let displayNameLabel = addHeader("Display Name", below:gap)
    displayNameTextField = addTextEntry(below: displayNameLabel)
    displayNameInfo = addInfoButton(to:displayNameTextField, target:self)
    
    let emailLabel = addHeader("Email", below:displayNameTextField)
    emailTextField = addTextEntry(below: emailLabel, email: true)
    emailInfo = addInfoButton(to: emailTextField, target: self)
    
    cancelButton = addCancelButton()
    createButton = addOkButton(title:"Connect")
    
    cancelButton.attachTop(to: emailTextField, offset: Style.contentGap)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    usernameTextField.text    = cachedUsername ?? ""
    password1TextField.text   = ""
    password2TextField.text   = ""
    displayNameTextField.text = cachedDisplayName ?? ""
    emailTextField.text       = cachedEmail ?? ""
    
    checkAll()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername    = self.usernameTextField.text
    cachedDisplayName = self.displayNameTextField.text
    cachedEmail       = self.emailTextField.text
  }
  
  // MARK:- IBActions
  
  @IBAction func handleButton(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo:
      infoPopup(title: "Username", message: [
        "Your username must contain at least 8 characters.",
        "It may contain any combination of letters and numbers"
      ] )
      
    case passwordInfo:
      infoPopup(title: "Password", message: [
        "Your password must contain at least 8 characters.",
        "It may contain any combination of letters, numbers, or the following punctuation marks: - ! : # $ @ ."
      ])
      
    case displayNameInfo:
      infoPopup(title: "Display Name", message: [
        "Specifying a display name is optional.",
        "If provided, this is the name that will be displayed to other players in the game.",
        "If you choose to specify a display name, it must be at least 6 characters long.",
        "If you choose to not provide a display name, your username will be displayed to other players."
      ])
      
    case emailInfo:
      infoPopup(title:"Email", message: [
        "Specifying your email is optional.",
        "If provided, your email will only  be used to recover a lost username or password. It will not be used for any other purpose.",
        "If you choose to not provide an email address, it won't be possible to recover your username or password if lost."
      ])
      
    default: break
    }
  }
  
  @IBAction func createAccount(_ sender:UIButton)
  {
    guard checkAll() else { return }
    
    let email = emailTextField.text ?? ""
    
    if email.isEmpty
    {
      confirmationPopup(
        title:"Proceed without Email",
        message: [
          "Creating an account without an email address is acceptable.",
          "But if you choose to proceed without one, it might not be possible to recover your username or password if lost"
        ],
        ok:"Proceed")
      {
        (proceed) in if proceed { self.requestNewAccount() }
      }
    }
    else
    {
      requestNewAccount()
    }
  }

  // MARK:- Input State

  @discardableResult
  func checkAll() -> Bool
  {
    var allOK = true
    if !checkUsername()    { allOK = false }
    if !checkPassword()    { allOK = false }
    if !checkDisplayName() { allOK = false }
    if !checkEmail()       { allOK = false }
    createButton.isEnabled = allOK
    return allOK
  }
  
  func checkUsername() -> Bool
  {
    let t = usernameTextField.text ?? ""
    
    var err : String?
    
    if      t.isEmpty   { err = "(required)" }
    else if t.count < 6 { err = "too short"  }
    
    let ok = ( err == nil )
//    usernameError.text = err
//    usernameError.isHidden = ok
    return ok
  }
  
  func checkPassword() -> Bool
  {
    let t1 = password1TextField.text ?? ""
    let t2 = password2TextField.text ?? ""
    
    var err : String?
    
    if      t1.isEmpty            { err = "(required)" }
    else if t1.count < 8          { err = "too short"  }
    else if t2.isEmpty            { err = "confirmation missing" }
    else if t2.count < t1.count,
      t2 == t1.prefix(t2.count)   { err = "confirmation incomplete" }
    else if t1 != t2              { err = "passwords don't match" }
    
    let ok = ( err == nil )
//    passwordError.text = err
//    passwordError.isHidden = ok
    return ok
  }
  
  func checkDisplayName() -> Bool
  {
    let t = (displayNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.count > 0, t.count<6 { err = "too short" }
    
    let ok = ( err == nil )
//    displayNameError.text = err
//    displayNameError.isHidden = ok
    return ok
  }
  
  func checkEmail() -> Bool
  {
    let t = (emailTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    // From http://emailregex.com
    let emailRegex = #"""
      (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
      """#
    
    var err : String?
    
    if !t.isEmpty,  t.range(of:emailRegex, options: .regularExpression) == nil
    {
      err = "invalid address"
    }
    
    let ok = ( err == nil )
//    emailError.text = err
//    emailError.isHidden = ok
    return ok
  }

  
  func requestNewAccount()
  {
    guard let username = usernameTextField.text  else { return }
    guard let password = password1TextField.text else { return }
    
    // if all checks are working correctly, should always get here
    
    let alias = displayNameTextField.text ?? ""
    let email = emailTextField.text ?? ""
    
    var args : GameQueryArgs = [.Username:username, .Password:password]
    
    if alias.count > 0 { args[.Alias] = alias }
    if email.count > 0 { args[.Email] = email }
    
    TheGame.server.query(.User, action: .Create, gameArgs: args) {
      (response) in
            
      switch ( response.status, response.returnCode )
      {
      case (.FailedToConnect,_):
        if let lvc = self.loginVC { lvc.cancel(self, updateRoot: true) }
        else                      { self.dismiss(animated: true) }
        
      case (.InvalidURI,_), (.MissingCode,_):
        self.internalError(response.status.rawValue, file: #file, function: #function)
        
      case (.Success,.Success):
        
        if let userkey = response.userkey
        {
          var message = ["Username: \(username)"]
          if alias.count > 0 { message.append("Alias: \(alias)") }
          if email.count > 0 { message.append("Check your email for instructions on validating your email address") }
          
          UserDefaults.standard.userkey = userkey
          UserDefaults.standard.username = username
          UserDefaults.standard.alias = alias
          
          let me = LocalPlayer(userkey, username: username, alias: alias, gameData: response.data)
          TheGame.shared.me = me
          
          self.infoPopup(title: "User Created", message: message)
          {
            if let lvc = self.loginVC { lvc.completed(self) }
            else                      { self.dismiss(animated: true) }
          }
        }

      case (.Success,.UserExists):
        
        self.confirmationPopup(
          title: "User Exists",
          message: "Would you like to log in as \(self.usernameTextField.text!)?",
          ok: "Yes", cancel: "No", animated: true
        ) { (swithToLogin) in
          if swithToLogin
          {
            UserDefaults.standard.username = self.usernameTextField.text!
            self.container?.present(ModalControllerID.AccountLogin.rawValue)
          }
          else
          {
            self.usernameTextField.selectAll(self)
          }
        }
        
      default:
        
        var message : String
        if let  rc = response.rc { message = "Unexpected Game Server Return Code: \(rc)" }
        else                     { message = "Missing Response Code"                     }
        self.internalError( message, file:#file, function:#function )
      }
    }
  }
}

extension CreateAccountViewController : InfoButtonDelegate
{
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo: debug("show username info")
    case passwordInfo: debug("show password info")
    case displayNameInfo: debug("show alias info")
    case emailInfo: debug("show email info")
    default: break
    }
  }
}
