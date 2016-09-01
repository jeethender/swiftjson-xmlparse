//
//  AppDelegate.swift
//  SwiftJSON&XMLParse
//
//  Created by maisapride8 on 13/07/16.
//  Copyright © 2016 maisapride8. All rights reserved.
//

import UIKit

//Account username of  Geonames.com
let kUsername = "jitu310"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
   
    
    
    class func downloadDataFromURL(url: NSURL, completion: (responseData: NSData?) -> Void) {
        
        // Instantiate a session configuration object.
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Instantiate a session object.
        let session = NSURLSession(configuration: configuration)
        
        // Create a data task object to perform the data downloading.
        let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                // If any error occurs then just display its description on the console.
                print("\(error!.localizedDescription)")
            } else {
                // If no error occurs, check the HTTP status code.
                if let HTTPResponse = response as? NSHTTPURLResponse {
                    
                    let HTTPStatusCode = HTTPResponse.statusCode
                    
                    // If it's other than 200, then show it on the console.
                    if HTTPStatusCode != 200 {
                        print("HTTP status code = \(HTTPStatusCode)")
                    }
                    // Call the completion handler with the returned data on the main thread.
                    NSOperationQueue.mainQueue().addOperationWithBlock({ completion(responseData: data)})
                }
            }
        })
        // Resume the task.
        task.resume()
    }

}

