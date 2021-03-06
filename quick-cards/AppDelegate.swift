//
//  AppDelegate.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    // TODO: Edit deck no cards
    // Look over drag delegate stuff
    // Deck info reset deck
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupWindow()
        getDecks()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DeckSaver.saveAllDecks()
    }


}

extension AppDelegate {
    
    func setupWindow() {
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        let navController = UINavigationController(rootViewController: HomeTableViewController(style: .grouped))
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.tintColor = GenericSection.quickResume.color        
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    
    func getDecks() {
        guard let allSavedDecks = DeckSaver.getDecks(for: allDecksKey) else {
            allDecks = defaultDecks
            return
        }
        guard let savedProgressDecks = DeckSaver.getDecks(for: decksInProgressKey) else {
            decksInProgress = []
            return
        }
        guard let savedUserDecks = DeckSaver.getDecks(for: userDecksKey) else {
            userDecks = []
            return
        }
        allDecks = allSavedDecks
        decksInProgress = savedProgressDecks
        userDecks = savedUserDecks
    }
}
