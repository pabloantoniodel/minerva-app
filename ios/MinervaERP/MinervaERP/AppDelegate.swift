import UIKit
import AVFoundation
import Speech

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configurar sesión de audio para grabación en segundo plano
        configureAudioSession()
        
        // Solicitar permisos necesarios
        requestPermissions()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Audio Configuration
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, 
                                       mode: .default, 
                                       options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try audioSession.setActive(true)
            
            print("🎤 Audio session configured for background recording")
        } catch {
            print("❌ Error configuring audio session: \(error)")
        }
    }
    
    // MARK: - Permissions
    
    private func requestPermissions() {
        // Solicitar permiso de micrófono
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Microphone permission granted")
                    self.requestSpeechRecognitionPermission()
                } else {
                    print("❌ Microphone permission denied")
                }
            }
        }
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition permission granted")
                    // Iniciar el servicio de voz
                    VoiceService.shared.startListening()
                case .denied:
                    print("❌ Speech recognition permission denied")
                case .restricted:
                    print("❌ Speech recognition permission restricted")
                case .notDetermined:
                    print("❓ Speech recognition permission not determined")
                @unknown default:
                    print("❓ Unknown speech recognition permission status")
                }
            }
        }
    }
}
