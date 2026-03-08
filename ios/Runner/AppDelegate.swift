import Flutter
import UIKit
import CoreTelephony

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configura canal para eSIM (Fase 1)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let esimChannel = FlutterMethodChannel(name: "com.scconecta/esim",
                                          binaryMessenger: controller.binaryMessenger)
    
    esimChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      switch call.method {
      case "isDeviceSupported":
        // iOS sempre suporta eSIM a partir do iPhone XS/XR
        if #available(iOS 12.0, *) {
          result(true)
        } else {
          result(false)
        }
        
      case "installESim":
        guard let args = call.arguments as? [String: Any],
              let lpaString = args["lpaString"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT",
                            message: "LPA String é obrigatório",
                            details: nil))
          return
        }
        
        // TODO: Implementar instalação real via CoreTelephony
        // Por enquanto, simula sucesso para testes
        result([
          "success": true,
          "iccid": "8901234567890123456",
          "errorMessage": nil,
          "errorType": nil
        ])
        
      case "openRoamingSettings":
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
        
      case "openLineSettings":
        if let url = URL(string: "App-Prefs:root=MOBILE_DATA_SETTINGS_ID") {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
        
      case "openGeneralSettings":
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
        
      case "getESimStatus":
        guard let args = call.arguments as? [String: Any],
              let iccid = args["iccid"] as? String else {
          result(nil)
          return
        }
        
        // TODO: Implementar verificação real de status
        result([
          "iccid": iccid,
          "isActive": true,
          "isRoamingEnabled": nil,
          "carrierName": "SCCONECTA"
        ])
        
      case "getInstalledProfiles":
        // TODO: Implementar listagem real de perfis
        result([])
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

