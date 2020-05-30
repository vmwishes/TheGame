//
//  AppDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GameKit

import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
  {
    // @@@ REMOVE AFTER TESTING
    if let uk = Bundle.main.object(forInfoDictionaryKey: "UserkeyOverride") as? String
    {
      track("UserKeyOverride: '\(uk)'")
      Defaults.userkey = uk
    }
    if let u = Bundle.main.object(forInfoDictionaryKey: "UsernameOverride") as? String
    {
      track("UserNameOverride: '\(u)'")
      Defaults.username = u
    }
    if let a = Bundle.main.object(forInfoDictionaryKey: "AliasOverride") as? String
    {
      track("AliasOverride: '\(a)'")
      Defaults.alias = a
    }
    Defaults.removeObject(forKey: "lastErrorEmail")
    
    // Facebook
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    // AdMobi
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)];
    
    track("NSHomeDirectory:",NSHomeDirectory())
    
    return true
  }
  
        
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool
  {
    // Facebook
    return ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
  }
  
  static var shared : AppDelegate
  {
    UIApplication.shared.delegate as! AppDelegate
  }
  
}

