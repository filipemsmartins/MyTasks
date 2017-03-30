//
//  AppDelegate.swift
//  MyTasks
//
//  Created by Filipe Martins on 21/03/2017.
//  Copyright © 2017 Runtime Revolution. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // The reference to our to view controller that we know it is the ViewController.swift.
        let controller = self.window!.rootViewController as! ViewController
        
        // Setting the managed object context to the View Controller before it gets his view loaded.
        // For this we use the persistent container definied on the AppDelegate.swift class,
        // and from it get the reference to the Managed Object Context
        controller.managedObjectContext = self.persistentContainer.viewContext
        return true
    }


    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it.
         */
        let container = NSPersistentContainer(name: "MyTasks")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

