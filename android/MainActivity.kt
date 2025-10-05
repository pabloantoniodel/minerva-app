package com.minerva.erp

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.minerva.erp.service.KeywordService

class MainActivity : FlutterActivity() {
    
    companion object {
        private const val CHANNEL = "minerva_voice"
        private const val EVENT_CHANNEL = "minerva_voice_events"
        private const val PERMISSION_REQUEST_CODE = 1001
        private const val BATTERY_OPTIMIZATION_REQUEST_CODE = 1002
    }
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var keywordService: KeywordService? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if launched by keyword detection
        if (intent.getBooleanExtra("keyword_detected", false)) {
            // Handle keyword detection launch
            handleKeywordDetectionLaunch()
        }
        
        // Request battery optimization exemption
        requestBatteryOptimizationExemption()
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup method channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
        
        // Setup event channel
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(MinervaEventStreamHandler())
    }
    
    private fun handleKeywordDetectionLaunch() {
        // Show a toast or notification that keyword was detected
        // You can also navigate to a specific page in Flutter
        methodChannel.invokeMethod("onKeywordDetected", null)
    }
    
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
                try {
                    startActivityForResult(intent, BATTERY_OPTIMIZATION_REQUEST_CODE)
                } catch (e: Exception) {
                    // Fallback to general battery optimization settings
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    startActivity(fallbackIntent)
                }
            }
        }
    }
    
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                if (checkPermissions()) {
                    initializeService()
                    result.success(true)
                } else {
                    requestPermissions()
                    result.success(false)
                }
            }
            "startListening" -> {
                startListening(result)
            }
            "stopListening" -> {
                stopListening(result)
            }
            "resetKeywordDetection" -> {
                resetKeywordDetection(result)
            }
            "isListening" -> {
                result.success(keywordService?.let { 
                    // You might want to add a method to check if listening
                    true 
                } ?: false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun initializeService() {
        val intent = Intent(this, KeywordService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        // Bind to service to get reference
        bindService(intent, object : android.content.ServiceConnection {
            override fun onServiceConnected(name: android.content.ComponentName?, service: android.os.IBinder?) {
                val binder = service as KeywordService.KeywordServiceBinder
                keywordService = binder.getService()
                
                // Set up callbacks
                keywordService?.setKeywordCallback(object : KeywordService.KeywordCallback {
                    override fun onKeywordDetected() {
                        sendEvent("keyword_detected", null)
                    }
                    
                    override fun onTranscriptionUpdate(text: String) {
                        sendEvent("transcription_update", mapOf("text" to text))
                    }
                    
                    override fun onTranscriptionComplete(text: String) {
                        sendEvent("transcription_complete", mapOf("text" to text))
                    }
                    
                    override fun onError(error: String) {
                        sendEvent("error", mapOf("message" to error))
                    }
                })
            }
            
            override fun onServiceDisconnected(name: android.content.ComponentName?) {
                keywordService = null
            }
        }, BIND_AUTO_CREATE)
    }
    
    private fun startListening(result: MethodChannel.Result) {
        if (keywordService != null) {
            // Service is already running and listening
            result.success(true)
        } else {
            result.success(false)
        }
    }
    
    private fun stopListening(result: MethodChannel.Result) {
        keywordService?.stopListening()
        result.success(true)
    }
    
    private fun resetKeywordDetection(result: MethodChannel.Result) {
        keywordService?.resetKeywordDetection()
        result.success(true)
    }
    
    private fun checkPermissions(): Boolean {
        val permissions = mutableListOf<String>()
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.RECORD_AUDIO)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.FOREGROUND_SERVICE) 
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.FOREGROUND_SERVICE)
            }
        }
        
        return permissions.isEmpty()
    }
    
    private fun requestPermissions() {
        val permissions = mutableListOf<String>()
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.RECORD_AUDIO)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.FOREGROUND_SERVICE) 
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.FOREGROUND_SERVICE)
            }
        }
        
        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissions.toTypedArray(),
                PERMISSION_REQUEST_CODE
            )
        }
    }
    
    private fun sendEvent(type: String, data: Map<String, Any>?) {
        val eventData = mutableMapOf<String, Any>("type" to type)
        data?.let { eventData.putAll(it) }
        MinervaEventStreamHandler.sendEvent(eventData)
    }
}

class MinervaEventStreamHandler : EventChannel.StreamHandler {
    
    companion object {
        private var eventSink: EventChannel.EventSink? = null
        
        fun sendEvent(data: Map<String, Any>) {
            eventSink?.success(data)
        }
    }
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
