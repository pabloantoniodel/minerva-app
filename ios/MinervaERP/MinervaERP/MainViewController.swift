import UIKit
import AVFoundation
import Speech

class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Minerva ERP"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Estado: Iniciando..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transcriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Transcripción aparecerá aquí..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar Servicio", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Detener Servicio", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let permissionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Configurar Permisos", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVoiceService()
        checkPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatus()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Minerva ERP"
        
        // Configurar scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Agregar elementos a content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(transcriptionLabel)
        contentView.addSubview(startButton)
        contentView.addSubview(stopButton)
        contentView.addSubview(permissionsButton)
        
        // Configurar constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Transcription label
            transcriptionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            transcriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            transcriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Start button
            startButton.topAnchor.constraint(equalTo: transcriptionLabel.bottomAnchor, constant: 40),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Stop button
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            stopButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stopButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stopButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Permissions button
            permissionsButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 40),
            permissionsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            permissionsButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Configurar acciones de botones
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        permissionsButton.addTarget(self, action: #selector(permissionsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Voice Service Setup
    
    private func setupVoiceService() {
        VoiceService.shared.onKeywordDetected = { [weak self] in
            DispatchQueue.main.async {
                self?.handleKeywordDetection()
            }
        }
        
        VoiceService.shared.onTranscriptionUpdate = { [weak self] text in
            DispatchQueue.main.async {
                self?.updateTranscription(text)
            }
        }
        
        VoiceService.shared.onTranscriptionComplete = { [weak self] text in
            DispatchQueue.main.async {
                self?.completeTranscription(text)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        requestPermissions { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    VoiceService.shared.startListening()
                    self?.updateStatus()
                    self?.showAlert(title: "Servicio Iniciado", message: "El servicio de reconocimiento de voz está activo")
                } else {
                    self?.showAlert(title: "Permisos Requeridos", message: "Se necesitan permisos de micrófono y reconocimiento de voz")
                }
            }
        }
    }
    
    @objc private func stopButtonTapped() {
        VoiceService.shared.stopListening()
        updateStatus()
        showAlert(title: "Servicio Detenido", message: "El servicio de reconocimiento de voz se ha detenido")
    }
    
    @objc private func permissionsButtonTapped() {
        openSettings()
    }
    
    // MARK: - Permission Handling
    
    private func checkPermissions() {
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        
        updateStatus()
        
        if microphoneStatus == .denied || speechStatus == .denied {
            showPermissionsAlert()
        }
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var microphoneGranted = false
        var speechGranted = false
        
        // Solicitar permiso de micrófono
        group.enter()
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            microphoneGranted = granted
            group.leave()
        }
        
        // Solicitar permiso de reconocimiento de voz
        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechGranted = (status == .authorized)
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(microphoneGranted && speechGranted)
        }
    }
    
    private func showPermissionsAlert() {
        let alert = UIAlertController(
            title: "Permisos Requeridos",
            message: "Minerva ERP necesita permisos de micrófono y reconocimiento de voz para funcionar correctamente.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Configurar", style: .default) { _ in
            self.openSettings()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Status Updates
    
    private func updateStatus() {
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        
        var statusText = "Estado del servicio:\n"
        
        statusText += "• Micrófono: \(microphoneStatusDescription(microphoneStatus))\n"
        statusText += "• Reconocimiento de voz: \(speechStatusDescription(speechStatus))\n"
        statusText += "• Servicio: \(VoiceService.shared.isListening ? "Activo" : "Inactivo")"
        
        statusLabel.text = statusText
    }
    
    private func microphoneStatusDescription(_ status: AVAudioSession.RecordPermission) -> String {
        switch status {
        case .granted: return "✅ Permitido"
        case .denied: return "❌ Denegado"
        case .undetermined: return "❓ No determinado"
        @unknown default: return "❓ Desconocido"
        }
    }
    
    private func speechStatusDescription(_ status: SFSpeechRecognizerAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "✅ Autorizado"
        case .denied: return "❌ Denegado"
        case .restricted: return "🚫 Restringido"
        case .notDetermined: return "❓ No determinado"
        @unknown default: return "❓ Desconocido"
        }
    }
    
    // MARK: - Voice Service Callbacks
    
    private func handleKeywordDetection() {
        showAlert(title: "¡Palabra Clave Detectada!", message: "Se detectó la palabra 'minerva'")
        transcriptionLabel.text = "Palabra clave detectada - Iniciando transcripción..."
    }
    
    private func updateTranscription(_ text: String) {
        transcriptionLabel.text = "Escuchando: \(text)"
        transcriptionLabel.textColor = .systemBlue
    }
    
    private func completeTranscription(_ text: String) {
        transcriptionLabel.text = "Transcripción completa: \(text)"
        transcriptionLabel.textColor = .systemGreen
        
        // Mostrar notificación
        showAlert(title: "Transcripción Completa", message: text)
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - VoiceService Extension

extension VoiceService {
    var isListening: Bool {
        return self.isListening
    }
}
