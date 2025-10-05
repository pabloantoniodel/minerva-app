package com.minerva.erp.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import java.util.*

class KeywordService : Service() {
    
    companion object {
        private const val TAG = "KeywordService"
        private const val NOTIF_ID = 1
        private const val CHANNEL_ID = "keyword_service_channel"
        private const val KEYWORD = "minerva"
        private const val SAMPLE_RATE = 16000
        private const val BUFFER_SIZE = 1024
        private const val PERSISTENT_NOTIFICATION_ID = 1001
    }
    
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioRecord: AudioRecord? = null
    private var isListening = false
    private var serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var keywordCallback: KeywordCallback? = null
    
    // Para emulador, simular detección
    private var isEmulator = false
    private var simulationTimer: Timer? = null
    
    // Para transcripción después de detectar keyword
    private var isTranscribing = false
    private var transcriptionBuffer = StringBuilder()
    private var lastAudioTime = 0L
    private var silenceThreshold = 2000L // 2 segundos de silencio
    private var lastTranscribedWord = ""
    private var transcriptionCount = 0
    
    // Para robustez del servicio
    private var watchdogTimer: Timer? = null
    private var lastActivityTime = 0L
    private var serviceRestartCount = 0
    
    interface KeywordCallback {
        fun onKeywordDetected()
        fun onTranscriptionUpdate(text: String)
        fun onTranscriptionComplete(text: String)
        fun onError(message: String)
    }
    
    fun setKeywordCallback(callback: KeywordCallback?) {
        keywordCallback = callback
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "KeywordService created - Independent mode")
        
        // Detectar si estamos en emulador
        isEmulator = detectEmulator()
        
        if (isEmulator) {
            Log.d(TAG, "Running on emulator - using simulation mode")
            initializeSimulation()
        } else {
            initializePowerManagement()
        }
        
        createNotificationChannel()
        
        // Asegurar que el servicio esté en primer plano inmediatamente
        startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
        
        // Programar reinicio automático cada 5 minutos para evitar que se cierre
        scheduleAutoRestart()
        
        Log.d(TAG, "KeywordService is now running independently")
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "KeywordService started")
        
        // Asegurar que el servicio esté en primer plano
        startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
        
        if (isEmulator) {
            startSimulation()
        } else {
            startListening()
        }
        
        // Iniciar watchdog para monitorear el servicio
        startWatchdog()
        
        // Return START_STICKY to restart service if killed
        // START_REDELIVER_INTENT para asegurar que se reinicie con el intent
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return KeywordServiceBinder()
    }
    
    inner class KeywordServiceBinder : android.os.Binder() {
        fun getService(): KeywordService = this@KeywordService
    }
    
    private fun detectEmulator(): Boolean {
        val isEmulator = Build.FINGERPRINT.startsWith("generic") ||
               Build.FINGERPRINT.startsWith("unknown") ||
               Build.MODEL.contains("google_sdk") ||
               Build.MODEL.contains("Emulator") ||
               Build.MODEL.contains("Android SDK built for x86") ||
               Build.MANUFACTURER.contains("Genymotion") ||
               (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
               "google_sdk" == Build.PRODUCT
               
        Log.d(TAG, "Emulator detection: $isEmulator")
        Log.d(TAG, "Build info - MODEL: ${Build.MODEL}, MANUFACTURER: ${Build.MANUFACTURER}, PRODUCT: ${Build.PRODUCT}")
        
        return isEmulator
    }
    
    private fun initializeSimulation() {
        Log.d(TAG, "Initializing simulation mode for emulator")
    }
    
    private fun startSimulation() {
        Log.d(TAG, "Starting keyword detection simulation")
        
        // Simular detección cada 10 segundos para testing más rápido
        simulationTimer = Timer()
        simulationTimer?.schedule(object : TimerTask() {
            override fun run() {
                Log.d(TAG, "Simulated keyword detection: '$KEYWORD'")
                onKeywordDetected()
            }
        }, 10000, 10000) // Cada 10 segundos para testing
    }
    
    private fun initializePowerManagement() {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "MinervaERP::KeywordService"
        )
        wakeLock?.acquire(10*60*1000L /*10 minutes*/)
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Keyword Recognition Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Service for continuous keyword detection"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun buildPersistentNotification(): Notification {
        val intent = Intent(this, com.minerva.erp.MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Always Listening")
            .setContentText("Say 'minerva' to activate voice commands")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
    
    private fun startListening() {
        if (isListening) return
        
        Log.d(TAG, "Starting audio listening...")
        
        // Verificar permisos de micrófono
        if (androidx.core.content.ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.RECORD_AUDIO
            ) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "Microphone permission not granted")
            keywordCallback?.onError("Microphone permission required")
            return
        }
        
        isListening = true
        
        try {
            val bufferSize = AudioRecord.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            
            Log.d(TAG, "AudioRecord buffer size: $bufferSize")
            
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize * 2 // Usar buffer más grande
            )
            
            val state = audioRecord?.state
            Log.d(TAG, "AudioRecord state: $state")
            
            if (state == AudioRecord.STATE_INITIALIZED) {
                audioRecord?.startRecording()
                val recordingState = audioRecord?.recordingState
                Log.d(TAG, "AudioRecord recording state: $recordingState")
                
                if (recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                    serviceScope.launch {
                        processAudio()
                    }
                } else {
                    Log.e(TAG, "Failed to start recording")
                    isListening = false
                }
            } else {
                Log.e(TAG, "AudioRecord not initialized properly")
                isListening = false
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting audio recording", e)
            keywordCallback?.onError("Failed to start audio recording: ${e.message}")
            isListening = false
        }
    }
    
    private suspend fun processAudio() {
        val buffer = ShortArray(BUFFER_SIZE)
        var audioLevel = 0f
        var silenceCount = 0
        var speechCount = 0
        var loopCount = 0
        
        Log.d(TAG, "Starting audio processing loop")
        
        while (isListening) {
            try {
                val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                loopCount++
                
                // Limpiar memoria cada 1000 loops para evitar acumulación
                if (loopCount % 1000 == 0) {
                    System.gc()
                    Log.d(TAG, "Memory cleanup performed at loop $loopCount")
                }
                
                if (bytesRead > 0) {
                    // Calcular nivel de audio
                    var sum = 0.0
                    for (i in 0 until bytesRead) {
                        sum += Math.abs(buffer[i].toDouble())
                    }
                    audioLevel = (sum / bytesRead).toFloat()
                    
                    // Detectar si hay voz (nivel de audio alto)
                    if (audioLevel > 500) { // Umbral de voz más sensible
                        speechCount++
                        silenceCount = 0
                        
                        // Si estamos transcribiendo, actualizar tiempo de último audio
                        if (isTranscribing) {
                            lastAudioTime = System.currentTimeMillis()
                            
                            // Simular transcripción de audio (en producción usarías Vosk o similar)
                            val simulatedText = simulateTranscription(audioLevel)
                            if (simulatedText.isNotEmpty() && simulatedText != lastTranscribedWord) {
                                transcriptionBuffer.append(simulatedText).append(" ")
                                lastTranscribedWord = simulatedText
                                transcriptionCount++
                                
                                Log.d(TAG, "Transcribing word: '$simulatedText' (count: $transcriptionCount)")
                                
                                // Enviar actualización de transcripción
                                keywordCallback?.onTranscriptionUpdate(transcriptionBuffer.toString())
                                
                                // Enviar broadcast de transcripción
                                val transcriptionIntent = Intent("com.minerva.erp.TRANSCRIPTION_UPDATE").apply {
                                    putExtra("text", transcriptionBuffer.toString())
                                    putExtra("timestamp", System.currentTimeMillis())
                                }
                                sendBroadcast(transcriptionIntent)
                                
                                // Actualizar notificación con transcripción parcial
                                updateNotificationWithTranscription(transcriptionBuffer.toString())
                            }
                        }
                        
                        Log.d(TAG, "Speech detected - Level: $audioLevel, Count: $speechCount, Transcribing: $isTranscribing")
                        
                        // Actualizar tiempo de actividad para el watchdog
                        updateActivityTime()
                        
                        // Simular detección de "minerva" cuando hay voz (solo si no estamos transcribiendo)
                        if (!isTranscribing && speechCount > 5) { // Después de 5 frames de voz
                            Log.d(TAG, "Triggering keyword detection from audio")
                            onKeywordDetected()
                            speechCount = 0
                            delay(3000) // Esperar 3 segundos antes de otra detección
                        }
                    } else {
                        silenceCount++
                        if (silenceCount > 50) { // Reset contador después de silencio
                            speechCount = 0
                        }
                        
                        // Si estamos transcribiendo y hay silencio, verificar si es tiempo de finalizar
                        if (isTranscribing) {
                            val currentTime = System.currentTimeMillis()
                            if (currentTime - lastAudioTime >= silenceThreshold) {
                                Log.d(TAG, "Silence detected, completing transcription")
                                completeTranscription()
                            }
                        }
                    }
                }
                
                delay(50) // Procesar más frecuentemente
            } catch (e: Exception) {
                Log.e(TAG, "Error processing audio", e)
                break
            }
        }
        
        Log.d(TAG, "Audio processing loop ended")
    }
    
    private fun simulateTranscription(audioLevel: Float): String {
        // Simulación más realista de transcripción basada en nivel de audio y timing
        // En producción usarías Vosk o Google Speech API
        val currentTime = System.currentTimeMillis()
        
        // Simular palabras basadas en patrones de audio
        return when {
            // Palabras más comunes con diferentes niveles
            audioLevel > 1800 -> when ((currentTime / 1000) % 8) {
                0L -> "hola"
                1L -> "minerva"
                2L -> "cómo"
                3L -> "estás"
                4L -> "bien"
                5L -> "gracias"
                6L -> "adiós"
                7L -> "hasta"
                else -> "luego"
            }
            audioLevel > 1200 -> when ((currentTime / 1000) % 6) {
                0L -> "por"
                1L -> "favor"
                2L -> "sí"
                3L -> "no"
                4L -> "tal"
                5L -> "vez"
                else -> "vez"
            }
            audioLevel > 800 -> when ((currentTime / 1000) % 4) {
                0L -> "el"
                1L -> "la"
                2L -> "de"
                3L -> "que"
                else -> "y"
            }
            audioLevel > 600 -> when ((currentTime / 1000) % 3) {
                0L -> "un"
                1L -> "una"
                2L -> "con"
                else -> "para"
            }
            else -> ""
        }
    }
    
    private fun startTranscription() {
        Log.d(TAG, "Starting transcription after keyword detection")
        isTranscribing = true
        transcriptionBuffer.clear()
        lastAudioTime = System.currentTimeMillis()
        lastTranscribedWord = ""
        transcriptionCount = 0
    }
    
    private fun completeTranscription() {
        val finalText = transcriptionBuffer.toString().trim()
        Log.d(TAG, "Transcription completed: '$finalText'")
        
        // Enviar transcripción completa
        keywordCallback?.onTranscriptionComplete(finalText)
        
        // Enviar broadcast de transcripción completa
        val completeIntent = Intent("com.minerva.erp.TRANSCRIPTION_COMPLETE").apply {
            putExtra("text", finalText)
            putExtra("timestamp", System.currentTimeMillis())
        }
        sendBroadcast(completeIntent)
        
        // Actualizar notificación con transcripción final
        updateNotificationWithFinalTranscription(finalText)
        
        // Resetear estado de transcripción
        isTranscribing = false
        transcriptionBuffer.clear()
        lastAudioTime = 0L
        lastTranscribedWord = ""
        transcriptionCount = 0
    }
    
    private fun stopListening() {
        Log.d(TAG, "Stopping audio listening...")
        isListening = false
        
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        
        simulationTimer?.cancel()
        simulationTimer = null
    }
    
    private fun onKeywordDetected() {
        Log.d(TAG, "Keyword '$KEYWORD' detected!")
        
        // Actualizar tiempo de actividad para el watchdog
        updateActivityTime()
        
        // Iniciar transcripción
        startTranscription()
        
        // Actualizar notificación para mostrar que se detectó la palabra
        updateNotificationWithDetection()
        
        // Llamar callback si está disponible
        keywordCallback?.onKeywordDetected()
        
        // Enviar broadcast para abrir la app
        val broadcastIntent = Intent("com.minerva.erp.KEYWORD_DETECTED").apply {
            putExtra("keyword", KEYWORD)
            putExtra("timestamp", System.currentTimeMillis())
        }
        sendBroadcast(broadcastIntent)
        
        // Método 1: Intentar abrir la app usando package manager (más confiable)
        try {
            val packageManager = packageManager
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                launchIntent.putExtra("keyword_detected", true)
                launchIntent.putExtra("auto_launch", true)
                launchIntent.putExtra("keyword", KEYWORD)
                launchIntent.putExtra("timestamp", System.currentTimeMillis())
                
                Log.d(TAG, "Attempting to launch app with intent: $launchIntent")
                startActivity(launchIntent)
                Log.d(TAG, "App launched via package manager successfully")
                return
            } else {
                Log.w(TAG, "No launch intent found for package: $packageName")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch app via package manager", e)
        }
        
        // Método 2: Fallback - Intentar abrir MainActivity directamente
        try {
            val mainIntent = Intent(this, com.minerva.erp.MainActivity::class.java).apply {
             val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    putExtra("keyword_detected", true)
    putExtra("auto_launch", true)
}
if (intent != null) {
    Log.d(TAG, "Launching app from keyword detection")
    startActivity(intent)
} else {
    Log.e(TAG, "No launch intent found")
}
            }
            startActivity(mainIntent)
            Log.d(TAG, "MainActivity launched directly from service")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch MainActivity directly", e)
            
        // Método 3: Último recurso - Intent genérico
        try {
            val genericIntent = Intent().apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                setPackage(packageName)
            }
            startActivity(genericIntent)
            Log.d(TAG, "App launched via generic intent")
        } catch (e2: Exception) {
            Log.e(TAG, "All launch methods failed", e2)
            
            // Método 4: Usar Runtime para ejecutar comando ADB
            try {
                Log.d(TAG, "Trying to launch via Runtime.exec")
                val process = Runtime.getRuntime().exec("am start -n $packageName/.MainActivity")
                val exitCode = process.waitFor()
                if (exitCode == 0) {
                    Log.d(TAG, "App launched via Runtime.exec successfully")
                } else {
                    Log.e(TAG, "Runtime.exec failed with exit code: $exitCode")
                }
            } catch (e3: Exception) {
                Log.e(TAG, "Runtime.exec method also failed", e3)
            }
        }
        }
    }
    
    private fun updateNotificationWithDetection() {
        val intent = Intent(this, com.minerva.erp.MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Keyword Detected!")
            .setContentText("'$KEYWORD' detected - App launched")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setAutoCancel(false)
            .build()
            
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(PERSISTENT_NOTIFICATION_ID, notification)
        
        // Restaurar notificación normal después de 5 segundos
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
        }, 5000)
    }
    
    private fun updateNotificationWithTranscription(text: String) {
        val intent = Intent(this, com.minerva.erp.MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Transcribing...")
            .setContentText("Escuchando: $text")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setAutoCancel(false)
            .build()
            
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(PERSISTENT_NOTIFICATION_ID, notification)
    }
    
    private fun updateNotificationWithFinalTranscription(text: String) {
        val intent = Intent(this, com.minerva.erp.MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Transcription Complete")
            .setContentText("Texto transcrito: $text")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setAutoCancel(false)
            .build()
            
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(PERSISTENT_NOTIFICATION_ID, notification)
        
        // Restaurar notificación normal después de 10 segundos
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
        }, 10000)
    }
    
    private fun startWatchdog() {
        Log.d(TAG, "Starting watchdog timer")
        lastActivityTime = System.currentTimeMillis()
        
        watchdogTimer?.cancel()
        watchdogTimer = Timer()
        
        watchdogTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                val currentTime = System.currentTimeMillis()
                val timeSinceLastActivity = currentTime - lastActivityTime
                
                Log.d(TAG, "Watchdog check - Time since last activity: ${timeSinceLastActivity}ms")
                
        // Si no hay actividad por más de 60 segundos, reiniciar el servicio
        if (timeSinceLastActivity > 60000) {
            Log.w(TAG, "No activity detected for 60 seconds, restarting service")
            restartService()
        }
                
                // Actualizar notificación con información de estado
                updateWatchdogNotification()
            }
        }, 10000, 10000) // Verificar cada 10 segundos
    }
    
    private fun restartService() {
        serviceRestartCount++
        Log.d(TAG, "Restarting service (attempt $serviceRestartCount)")
        
        try {
            // Programar reinicio usando AlarmManager para mayor robustez
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val intent = Intent(this, KeywordService::class.java).apply {
                putExtra("independent_mode", true)
                putExtra("auto_restart", true)
                putExtra("restart_count", serviceRestartCount)
            }
            
            val pendingIntent = PendingIntent.getService(
                this, 
                serviceRestartCount, 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Programar reinicio en 2 segundos
            val triggerTime = System.currentTimeMillis() + 2000
            alarmManager.setExact(
                android.app.AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
            
            Log.d(TAG, "Service restart scheduled via AlarmManager")
            
            // Detener el servicio actual después de programar el reinicio
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                stopSelf()
            }, 1000)
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to restart service via AlarmManager", e)
            
            // Fallback: reinicio directo
            try {
                val intent = Intent(this, KeywordService::class.java).apply {
                    putExtra("independent_mode", true)
                    putExtra("auto_restart", true)
                    putExtra("restart_count", serviceRestartCount)
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent)
                } else {
                    startService(intent)
                }
                
                stopSelf()
                
            } catch (e2: Exception) {
                Log.e(TAG, "Failed to restart service directly", e2)
            }
        }
    }
    
    private fun updateWatchdogNotification() {
        val intent = Intent(this, com.minerva.erp.MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Voice Service")
            .setContentText("Escuchando activamente - Reinicios: $serviceRestartCount")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setAutoCancel(false)
            .build()
            
        startForeground(PERSISTENT_NOTIFICATION_ID, notification)
    }
    
    private fun updateActivityTime() {
        lastActivityTime = System.currentTimeMillis()
    }
    
    private fun scheduleAutoRestart() {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val intent = Intent(this, KeywordService::class.java).apply {
                putExtra("independent_mode", true)
                putExtra("auto_restart", true)
                putExtra("scheduled_restart", true)
            }
            
            val pendingIntent = PendingIntent.getService(
                this, 
                99999, 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Programar reinicio automático cada 5 minutos
            val triggerTime = System.currentTimeMillis() + (5 * 60 * 1000) // 5 minutos
            alarmManager.setRepeating(
                android.app.AlarmManager.RTC_WAKEUP,
                triggerTime,
                5 * 60 * 1000, // Repetir cada 5 minutos
                pendingIntent
            )
            
            Log.d(TAG, "Auto-restart scheduled every 5 minutes")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule auto-restart", e)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "KeywordService destroyed")
        
        stopListening()
        
        watchdogTimer?.cancel()
        watchdogTimer = null
        
        wakeLock?.release()
        serviceScope.cancel()
    }
}