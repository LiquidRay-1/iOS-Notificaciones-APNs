//
//  AppDelegate.swift
//  Notificaciones
//
//  Created by dam2 on 7/2/24.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Detectar si la app se abre a traves de una notificacion
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String:AnyObject],
           let aps = notification["aps"] as? [String: AnyObject]{
            print("Se ha abierto la app tocando la notificación")
        }
        
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    //Se ejecuta al recibir una notificación con la aplicación abierta
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func registerForPushNotifications(){
        //Pidiendo permiso para mostrar notificaciones en el dispositivo
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ granted, error in
            
            print("Permiso concedido: \(granted)")
            
            //Detectar si el usuario ha cambiado la coniguración
            guard granted else {return}
            getNotificationsSettings()
        }
        
        //Obtener la configuración de notificaciones push
        func getNotificationsSettings(){
            UNUserNotificationCenter.current().getNotificationSettings{
                settings in
                print("Configuración Push: \(settings)")
                
                //Comprobar que se han concedido permisos para recibir notificaciones
                guard settings.authorizationStatus == .authorized else {return}
                
                DispatchQueue.main.async {
                    //Hacemos la petición para que APNs nos registre s
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        }
    }
    
    //APNs responde, registra y envía el token
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        //% indica que va a especificar un formato
        //02 indica que como mínimo va a tener dos caracteres
        //.2 indica que como máximo tendrá 2 decimales
        //hh indica que es un puntero a un usigned char
        //x indica que debe estar formateado en hexadecimal
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        //Token del dispositivo (solo esta app)
        print("Device token: \(token)") // 80aa5f79c2d2c742eec8b401d9c5c80e5c3373fd9ab6da55c0090a7ef8c61c7cd581c2783bef353e8137faf1239e517647949cb0394e451aa1372f2ef55df672fb74d071990138544127de92b59e41a1 es el token del dispositivo en el que se instalo como prueba (simulador)
        
        //Enviar el token al backend
    }
    
    //Si se produce un error, se ejecuta esta función
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("Error al registrar el dispositivo en el APNs: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
