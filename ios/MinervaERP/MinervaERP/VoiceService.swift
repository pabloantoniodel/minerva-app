import Foundation
import Speech
import AVFoundation
import UIKit

class VoiceService: NSObject {
    static let shared = VoiceService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var isListening = false
    private var isTranscribing = false
    private var transcriptionBuffer = ""
    private var lastAudioTime = Date()
    private let silenceThreshold: TimeInterval = 2.0
    
    // Callbacks
    var onKeywordDetected: (() -> Void)?
    var onTranscriptionUpdate: ((String) -> Void)?
    var onTranscriptionComplete: ((String) -> Void)?
    
    private override init() {
        super.init()
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    func startListening() {
        guard !isListening else { return }
        
        print("🎤 Starting voice recognition service...")
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                print("❌ Unable to create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
                self?.processAudioLevel(buffer: buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                self?.handleRecognitionResult(result: result, error: error)
            }
            
            isListening = true
            print("✅ Voice recognition started")
            
        } catch {
            print("❌ Error starting voice recognition: \(error)")
        }
    }
    
    func stopListening() {
        guard isListening else { return }
        
        print("🛑 Stopping voice recognition...")
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
        isTranscribing = false
        transcriptionBuffer = ""
        
        print("✅ Voice recognition stopped")
    }
    
    func resumeListening() {
        if !isListening {
            startListening()
        }
    }
    
    func continueInBackground() {
        // Mantener el servicio activo en segundo plano
        startBackgroundTask()
    }
    
    func enterBackground() {
        startBackgroundTask()
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        startBackgroundTask()
    }
    
    @objc private func appWillEnterForeground() {
        endBackgroundTask()
    }
    
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "VoiceRecognition") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    private func processAudioLevel(buffer: AVAudioPCMBuffer) {
        // Simular detección de nivel de audio para emulador
        let audioLevel = Float.random(in: 0...3000)
        
        if audioLevel > 500 {
            lastAudioTime = Date()
            
            if !isTranscribing {
                // Detectar si contiene la palabra clave "minerva"
                if shouldTriggerKeywordDetection() {
                    triggerKeywordDetection()
                }
            }
        } else if isTranscribing {
            // Verificar si ha pasado suficiente tiempo sin audio
            let timeSinceLastAudio = Date().timeIntervalSince(lastAudioTime)
            if timeSinceLastAudio >= silenceThreshold {
                completeTranscription()
            }
        }
    }
    
    private func shouldTriggerKeywordDetection() -> Bool {
        // Simular detección de palabra clave (en un emulador)
        // En un dispositivo real, esto sería reemplazado por análisis de audio real
        return Int.random(in: 1...100) <= 5 // 5% de probabilidad cada vez
    }
    
    private func triggerKeywordDetection() {
        print("🎯 Keyword 'minerva' detected!")
        
        DispatchQueue.main.async { [weak self] in
            self?.onKeywordDetected?()
            self?.startTranscription()
        }
        
        // Lanzar la app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.launchApp()
        }
    }
    
    private func startTranscription() {
        isTranscribing = true
        transcriptionBuffer = ""
        lastAudioTime = Date()
        print("📝 Starting transcription...")
    }
    
    private func completeTranscription() {
        guard isTranscribing else { return }
        
        isTranscribing = false
        print("📝 Transcription completed: '\(transcriptionBuffer)'")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onTranscriptionComplete?(self.transcriptionBuffer)
        }
        
        transcriptionBuffer = ""
    }
    
    private func launchApp() {
        print("🚀 Launching app...")
        // La app ya está activa, solo mostrar notificación
        showNotification(title: "Minerva Detectada", body: "Palabra clave detectada")
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error showing notification: \(error)")
            }
        }
    }
    
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let error = error {
            print("❌ Recognition error: \(error)")
            return
        }
        
        guard let result = result else { return }
        
        let recognizedText = result.bestTranscription.formattedString.lowercased()
        print("🗣️ Recognized: \(recognizedText)")
        
        // Detectar palabra clave
        if recognizedText.contains("minerva") && !isTranscribing {
            triggerKeywordDetection()
        }
        
        // Si estamos transcribiendo, agregar al buffer
        if isTranscribing {
            transcriptionBuffer = recognizedText
            
            DispatchQueue.main.async { [weak self] in
                self?.onTranscriptionUpdate?(recognizedText)
            }
        }
        
        if result.isFinal {
            if isTranscribing {
                completeTranscription()
            }
        }
    }
}

// MARK: - Notification Extensions

import UserNotifications

extension VoiceService {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
            } else {
                print("✅ Notification permission granted: \(granted)")
            }
        }
    }
}
