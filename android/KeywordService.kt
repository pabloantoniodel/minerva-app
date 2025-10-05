package com.minerva.erp.service

import android.app.*
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import org.vosk.Model
import org.vosk.Recognizer
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class KeywordService : Service() {
    
    companion object {
        private const val NOTIF_ID = 1001
        private const val CHANNEL_ID = "keyword_service_channel"
        private const val KEYWORD = "minerva"
        private const val SAMPLE_RATE = 16000
        private const val BUFFER_SIZE = 4096
        private const val PERSISTENT_NOTIFICATION_ID = 1002
    }
    
    // Vosk components
    private lateinit var voskModel: Model
    private lateinit var voskRecognizer: Recognizer
    
    // Audio components
    private var audioRecord: AudioRecord? = null
    private val isListening = AtomicBoolean(false)
    private val isKeywordDetected = AtomicBoolean(false)
    
    // Coroutines
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    // Power management
    private lateinit var wakeLock: PowerManager.WakeLock
    
    // Binder for Flutter communication
    private val binder = KeywordServiceBinder()
    
    inner class KeywordServiceBinder : Binder() {
        fun getService(): KeywordService = this@KeywordService
    }
    
    // Callback interface for Flutter
    interface KeywordCallback {
        fun onKeywordDetected()
        fun onTranscriptionUpdate(text: String)
        fun onTranscriptionComplete(text: String)
        fun onError(error: String)
    }
    
    private var keywordCallback: KeywordCallback? = null
    
    fun setKeywordCallback(callback: KeywordCallback) {
        keywordCallback = callback
    }
    
    override fun onCreate() {
        super.onCreate()
        initializeVosk()
        initializePowerManagement()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Start as persistent foreground service
        startForeground(PERSISTENT_NOTIFICATION_ID, buildPersistentNotification())
        
        // Start keyword detection
        if (!isListening.get()) {
            startListening()
        }
        
        // Return START_STICKY to restart service if killed
        return START_STICKY
    }
    
    private fun initializeVosk() {
        try {
            // Initialize Vosk model (you need to add the model to assets)
            voskModel = Model("models/vosk-model-small-en-us-0.15")
            voskRecognizer = Recognizer(voskModel, SAMPLE_RATE.toFloat())
        } catch (e: Exception) {
            keywordCallback?.onError("Failed to initialize Vosk: ${e.message}")
        }
    }
    
    private fun initializePowerManagement() {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "MinervaERP::KeywordService"
        )
        wakeLock.acquire(10*60*1000L /*10 minutes*/)
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Keyword Recognition Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Continuous keyword detection for Minerva ERP"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun buildPersistentNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP - Always Listening")
            .setContentText("Say '$KEYWORD' to activate voice commands")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }
    
    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Minerva ERP")
            .setContentText("Listening for keyword: '$KEYWORD'")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun startListening() {
        if (isListening.get()) return
        
        serviceScope.launch {
            initializeAudioRecord()
            startKeywordDetection()
        }
    }
    
    private fun initializeAudioRecord() {
        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        
        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            maxOf(bufferSize, BUFFER_SIZE)
        )
    }
    
    private suspend fun startKeywordDetection() {
        isListening.set(true)
        isKeywordDetected.set(false)
        
        audioRecord?.startRecording()
        
        try {
            val buffer = ByteArray(BUFFER_SIZE)
            val audioBuffer = ByteArrayOutputStream()
            
            while (isListening.get()) {
                val readBytes = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                
                if (readBytes > 0) {
                    audioBuffer.write(buffer, 0, readBytes)
                    
                    // Process with Vosk
                    val result = voskRecognizer.acceptWaveForm(buffer, readBytes)
                    
                    if (result) {
                        val partialResult = voskRecognizer.getPartialResult()
                        val text = extractTextFromResult(partialResult)
                        
                        if (text.contains(KEYWORD, ignoreCase = true) && !isKeywordDetected.get()) {
                            isKeywordDetected.set(true)
                            onKeywordDetected()
                            continueTranscription(audioBuffer)
                            break
                        }
                    }
                }
                
                delay(10) // Small delay to prevent excessive CPU usage
            }
        } catch (e: Exception) {
            keywordCallback?.onError("Audio recording error: ${e.message}")
        }
    }
    
    private fun onKeywordDetected() {
        keywordCallback?.onKeywordDetected()
        
        // Update notification
        val notification = buildNotification().apply {
            extras.putString("content_text", "Keyword detected! Transcribing...")
        }
        startForeground(NOTIF_ID, notification)
        
        // Launch Flutter app if not running
        launchFlutterApp()
        
        // Send broadcast to wake up the app
        sendBroadcast(Intent("com.minerva.erp.KEYWORD_DETECTED"))
    }
    
    private fun launchFlutterApp() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("keyword_detected", true)
            }
            startActivity(intent)
        } catch (e: Exception) {
            // Log error but don't crash the service
            e.printStackTrace()
        }
    }
    
    private suspend fun continueTranscription(audioBuffer: ByteArrayOutputStream) {
        val buffer = ByteArray(BUFFER_SIZE)
        
        try {
            while (isListening.get()) {
                val readBytes = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                
                if (readBytes > 0) {
                    audioBuffer.write(buffer, 0, readBytes)
                    
                    val result = voskRecognizer.acceptWaveForm(buffer, readBytes)
                    
                    if (result) {
                        val partialResult = voskRecognizer.getPartialResult()
                        val text = extractTextFromResult(partialResult)
                        
                        // Send partial transcription to Flutter
                        keywordCallback?.onTranscriptionUpdate(text)
                    }
                }
                
                delay(50) // Longer delay for transcription
            }
        } catch (e: Exception) {
            keywordCallback?.onError("Transcription error: ${e.message}")
        }
    }
    
    private fun extractTextFromResult(result: String): String {
        return try {
            // Parse JSON result from Vosk
            val jsonObject = org.json.JSONObject(result)
            jsonObject.getString("text")
        } catch (e: Exception) {
            result
        }
    }
    
    fun stopListening() {
        isListening.set(false)
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
    
    fun resetKeywordDetection() {
        isKeywordDetected.set(false)
        voskRecognizer.reset()
    }
    
    override fun onBind(intent: Intent?): IBinder = binder
    
    override fun onDestroy() {
        isListening.set(false)
        stopListening()
        wakeLock.release()
        voskRecognizer.close()
        voskModel.close()
        serviceScope.cancel()
        super.onDestroy()
    }
}
