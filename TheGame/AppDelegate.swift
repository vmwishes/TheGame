//
//  AppDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds
import UserNotifications

import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?
    
  static var shared : AppDelegate
  {
    UIApplication.shared.delegate as! AppDelegate
  }

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
  {
    // @@@ REMOVE AFTER TESTING
    if Bundle.main.object(forInfoDictionaryKey: "DevFreshStart") as? Bool ?? false
    {
      Defaults.clear()
    }
    else if Bundle.main.object(forInfoDictionaryKey: "DevUser") as? Bool ?? false
    {
      Defaults.username = "mikemayer67"
      Defaults.alias   = "Mikey M"
      Defaults.removeObject(forKey: "lastErrorEmail")
      Defaults.userkey = nil
    }
        
    // Facebook
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // AdMobi
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)];
    
    // Remote Notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_,_) in }
        
    return true
  }
}

extension AppDelegate // Facebook
{
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool
  {
    debug("AppDelegate:: application(app, open:\(url) options:\(options)")
    return ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
  }
  
  func application(application: UIApplication,
                   openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool
  {
    debug("AppDelegate:: application(app, open:\(url) soure:\(sourceApplication) annotation:\(annotation)")

    return ApplicationDelegate.shared.application(
      application,
      open: url,
      sourceApplication: sourceApplication,
      annotation: annotation)
  }
}

extension AppDelegate // Register with APN server
{
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
  {
    RemoteNotificationManager.shared.device =
      deviceToken.map( {data in String(format: "%02.2hhx", data) } ).joined()
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
  {
    RemoteNotificationManager.shared.device = nil
  }
}
