//
//  AppDelegate.swift
//  ESPIDY
//
//  Created by FreddyA on 8/25/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import Fabric
import CoreData
import Firebase
import FBSDKCoreKit
import Crashlytics
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
import IQKeyboardManagerSwift

enum Storyboard: String {
    case Splash = "Splash"
    case Main = "Main"
    case Onboarding = "Onboarding"
    case FlowLoginRegister = "FlowLoginRegister"
}
 
var Global_UserSesion: User?
var Global_creditCards = [Credit_card]()
var messageId = ""
let googleMapsApiKey = "AIzaSyA3I4B5_qhFQPdcctf6R5VrIKxmmnIszIE" //"AIzaSyApqYh2tMeBzTBC_Nlx2BrbPosfo4swfzM" //old

var notificationPushLaunchingApp = false
var dataUserInfo: [String: AnyObject]?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var messageId = ""
    var player: AVAudioPlayer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupNavigationBar()
        //Fabric
//        Fabric.with([Crashlytics.self])
        
        //GoogleMaps
        GMSServices.provideAPIKey(googleMapsApiKey)
        GMSPlacesClient.provideAPIKey(googleMapsApiKey)
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //KeyboardManager
        IQKeyboardManager.shared.enable = true
        
        //Firebase
        registerForPushNotifications(application)
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        // Add payment method cash.
        Global_creditCards.append(Credit_card(payment_method_id: 2,
            imageCard: UIImage(named: "ic-cash-green")!,
            cardNumber: "CASH"))
        
        //Settings
        Settings.registerDefaults()
        if (!Settings.groupDefaults().bool(forKey: onboardingKey)) {
            print("---> Onboarding")
            launchStoryboard(Storyboard.Onboarding, animated: false)
        } else {
            Global_UserSesion = Settings.getUserAcount()
            if Global_UserSesion != nil {
                if Global_UserSesion?.personable_id == "Driver" {
                    if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
                        let dataPayload = notification 
                        if let shipment_id = dataPayload["shipment_id"] as? String,
                            let shipment_status = dataPayload["status"] as? String {
                            
                            if shipment_status == "PENDING" {
                                notificationPushLaunchingApp = true
                                dataUserInfo = ["shipment_id": shipment_id as AnyObject, "shipment_status": shipment_status as AnyObject]
                            }
                        }
                    }
                }
                print("---> Splash")
                launchStoryboard(Storyboard.Splash, animated: false)
                
            } else {
                print("---> FlowLoginRegister")
                launchStoryboard(Storyboard.FlowLoginRegister, animated: false)
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApp = (options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String) ?? ""
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                                                                     sourceApplication: sourceApp,
                                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func launchStoryboard(_ storyboardName: Storyboard, animated: Bool) {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        let controller = storyboard.instantiateInitialViewController()! as UIViewController
        
        if animated {
            UIView.transition(with: self.window!,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: { () -> Void in
                    self.window!.rootViewController = controller
                }, completion: nil)
        } else {
            window!.rootViewController = controller
        }
        
    }
    
    func setupNavigationBar() {
        window?.backgroundColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.ESPIDYColorRedL()
        UINavigationBar.appearance().tintColor = UIColor.white
        
//        navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        navigationController?.navigationBar.translucent = false

        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().isTranslucent = false
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
//        print("Disconnected from FCM.")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Firebase Push Notifications
    // [START register_for_notifications]
    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    // [END register_for_notifications]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        
        print("---> fetchCompletionHandler  application didReceiveRemoteNotification full message:\n", userInfo)
        
        let dataPayload = userInfo as! [String: AnyObject]
        //handlePushNotification(dataPayload)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print("---> application Single didReceiveRemoteNotification full message:", userInfo)
        /*
        let dataPayload = userInfo as! [String: AnyObject]
        handlePushNotification(dataPayload)
        */
    }
    // [END receive_message]
    
    func handlePushNotification(_ dataPayload: [String: AnyObject]) {
        if let shipment_id = dataPayload["shipment_id"] as? String, let shipment_status = dataPayload["status"] as? String {
            let gcmMessageId = "\(shipment_id) \(shipment_status)"
            if gcmMessageId != messageId {
                messageId = gcmMessageId
                
//                print("handlePushNotification dataPayload \(dataPayload)")
                
                playNotificationSound()
                guard let typeUser = Global_UserSesion!.personable_id else{
                    print("Error ---> Global_UserSesion!.personable_id on Appdelegate line 244")
                    return
                }
                switch typeUser {
                case "Driver":
                    switch shipment_status {
                    case "PENDING":
//                        print("handlePushNotification PENDING \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: MainViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    case "CANCELLED_BY_USER":
//                        print("handlePushNotification CANCELLED_BY_USER \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    default:
//                        print("handlePushNotification break \(shipment_status)")
                        print("default Driver handlePushNotification")
                        break
                    }
                case "Client":
                    switch shipment_status {
                    case "DRIVER_ACCEPTED":
                        print("handlePushNotification DRIVER_ACCEPTED \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: MainViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    case "SERVICE_IN_PROGRESS":
                        print("handlePushNotification SERVICE_IN_PROGRESS \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    case "COMPLETE_SERVICE", "PAYMENT_SUCCEEDED", "PAYMENT_CASH":
                       print("handlePushNotification COMPLETE_SERVICE, PAYMENT_SUCCEEDED, PAYMENT_CASH \(shipment_status)")
                       NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    case "CANCELLED_BY_DRIVER":
                       print("handlePushNotification CANCELLED_BY_DRIVER \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification), object: nil,
                                                                                  userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    case "SERVICE_IN_PAUSE":
                        print("handlePushNotification SERVICE_IN_PAUSE \(shipment_status)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification), object: nil,
                                                        userInfo: ["shipment_id": shipment_id, "shipment_status": shipment_status])
                    default:
                       print("handlePushNotification break \(shipment_status)")
                        break
                    }
                default:
                    print("default Client handlePushNotification")
                    break
                }
            }
        }else if let transmitter_id = dataPayload["transmitter"] as? String, let conversation_id = dataPayload["conversation_id"] as? String {// for chat
            print("---> ChatNotification Entry")//AQUI MUJICAM
            //NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification),object: nil,userInfo: ["transmitter_id": transmitter_id, "conversation_id": conversation_id])
            playNotificationSound()
            if let wd = UIApplication.shared.delegate?.window {
                var vc = wd?.rootViewController
                if(vc is UINavigationController){
                    vc = (vc as? UINavigationController)?.visibleViewController
                    
                }
                
                if(vc is ChatViewController){
                    isNewMessage = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ChatViewController.ChatRefreshNotification),object: nil,userInfo: ["transmitter_id": transmitter_id, "conversation_id": conversation_id])
                }else{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification),object: nil,userInfo: ["transmitter_id": transmitter_id, "conversation_id": conversation_id])
                    isNewMessage = true
                }
            }
        }else{
            guard let typeUser = Global_UserSesion!.personable_id else{
                print("Error ---> Global_UserSesion!.personable_id on Appdelegate line 244")
                return
            }
            switch typeUser {
            case "Driver":
                if let status = dataPayload["status"] as? String{ //cancel or accept INSTANT_PURCHASE for driver
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification),object: nil,userInfo: ["status": status])
                    
                }
                break
                
            case "Client":
                if let purchase_id = dataPayload["instant_purchase_id"] as? String, let amount = dataPayload["amount"] as? String{ // INSTANT_PURCHASE petition for client
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ShipmentProgressViewController.RefreshNotification),object: nil,userInfo: ["instant_purchase_id": purchase_id, "amount": amount])
                    
                }
                break
            default:
                print("default Client handlePushNotification")
                break
            }
        }
    }
    
    func playNotificationSound() {
        guard let url = Bundle.main.url(forResource: "smack-that-bitch", withExtension: "caf") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // [START refresh_token]
    @objc func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token")//: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        if Global_UserSesion != nil && Global_UserSesion!.isInvisible {
            // Won't connect since there is no token
            guard FIRInstanceID.instanceID().token() != nil else {
                return
            }
            
            // Disconnect previous FCM connection if it exists.
            FIRMessaging.messaging().disconnect()
            
            FIRMessaging.messaging().connect { (error) in
                if error != nil {
                    print("Unable to connect with FCM. \(error)")
                } else {
                    if let newTokenFCM = FIRInstanceID.instanceID().token() {
//                        print("User tokenFCM \(Global_UserSesion?.token_fcm)")
                        if newTokenFCM != Global_UserSesion?.token_fcm {
                            EspidyApiManager.sharedInstance.updateUserTokenFCM(newTokenFCM, completionHandler: { (result) in
                                guard result.error == nil else {
                                    // TODO: display error
                                    print("Error in Update tokenFCM \(result.error)")
                                    return
                                }
                                
                                if let userTokenFCM = result.value {
                                    if userTokenFCM.errors == nil || userTokenFCM.errors?.count == 0 {
                                        if let userSesion = Global_UserSesion {
                                            userSesion.token_fcm = newTokenFCM
                                            
                                            Settings.removeUserAcount()
                                            Settings.setUserAcount(userSesion)
                                            
//                                            print("Update tokenFCM \(newTokenFCM)")
                                        }
                                    }
                                }
                            })
                        }
                    } else {
                        print("Error, Unable to subscribe")
                    }
                    print("Connected to FCM.")
                }
            }
        }
    }
    // [END connect_to_fcm]

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.kretum.ESPIDY" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "ESPIDY", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

// MARK: - Firebase Push Notifications iOS 10
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        let dataPayload = userInfo as! [String: AnyObject]
        
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd?.rootViewController
            if(vc is UINavigationController){
                vc = (vc as? UINavigationController)?.visibleViewController
                
            }
            
            if(vc is ChatViewController){
                isNewMessage = false
            }else{
                if let chat = dataPayload["TAG"] as? String{
                    if chat  == "CHAT"{
                        isNewMessage = true
                    }
                }
                
            }
        }
        handlePushNotification(dataPayload)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        
        let dataPayload = userInfo as! [String: AnyObject]
        handlePushNotification(dataPayload)
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        let dataPayload = remoteMessage.appData as! [String: AnyObject]
        handlePushNotification(dataPayload)
    }
}
// [END ios_10_message_handling]

