//
//  AppDelegate.swift
//  SwiftWebView


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , WeiboSDKDelegate {
  
    var window: UIWindow?
    let appKey = "2640361144"
    let appSecret = "dd99b8168ff4a2cc5350581522a80d6b"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(appKey)
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 1.0)
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WeiboSDK .handleOpen(url, delegate: self)
    }
    
    
    ///WeiboSDKDelegate
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        
        if response.isKind(of: WBAuthorizeResponse.self) {
            /// 发送通知进入web页面
            
            let notify = Notification.init(name: Notification.Name(rawValue: "weiboSuccess"), object:nil, userInfo: ["info": response])
            
            NotificationCenter.default.post(notify)
            
        }
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
        
    }
    
}

