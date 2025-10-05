package com.minerva.erp

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.widget.Toast
import android.app.Activity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.minerva.erp.service.KeywordService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.util.Log
import androidx.core.content.PermissionChecker

class MainActivity : Activity() {
    
    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
        private const val BATTERY_OPTIMIZATION_REQUEST_CODE = 1002
        private const val TAG = "MainActivity"
    }
    
    private var transcriptionReceiver: BroadcastReceiver? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Register transcription receiver
        registerTranscriptionReceiver()
        
        // Check if launched by keyword detection
        if (intent.getBooleanExtra("keyword_detected", false)) {
            handleKeywordDetectionLaunch()
        }
        
        // Request battery optimization exemption
        requestBatteryOptimizationExemption()
        
        // Initialize the keyword service
        if (checkPermissions()) {
            startKeywordService()
        } else {
            Toast.makeText(this, "Permisos de micrófono requeridos para el reconocimiento de voz", Toast.LENGTH_LONG).show()
            requestPermissions()
        }
    }
    
    private fun handleKeywordDetectionLaunch() {
        // Show a toast that keyword was detected
        Toast.makeText(this, "¡Palabra clave 'minerva' detectada!", Toast.LENGTH_LONG).show()
    }
    
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                Log.d(TAG, "Requesting battery optimization exemption")
                Toast.makeText(this, "Configurando optimización de batería...", Toast.LENGTH_SHORT).show()
                
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivityForResult(intent, BATTERY_OPTIMIZATION_REQUEST_CODE)
                } catch (e: Exception) {
                    Log.e(TAG, "Error opening battery optimization settings", e)
                    Toast.makeText(this, "Abriendo configuración general de batería...", Toast.LENGTH_SHORT).show()
                    // Fallback: intentar abrir configuración general de batería
                    val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(fallbackIntent)
                    } catch (e2: Exception) {
                        Log.e(TAG, "Error opening general battery settings", e2)
                        Toast.makeText(this, "Error al abrir configuración de batería", Toast.LENGTH_SHORT).show()
                        startKeywordService()
                    }
                }
            } else {
                Log.d(TAG, "Battery optimization already disabled")
                Toast.makeText(this, "Optimización de batería ya configurada", Toast.LENGTH_SHORT).show()
                startKeywordService()
            }
        } else {
            Log.d(TAG, "Battery optimization not needed for this Android version")
            startKeywordService()
        }
    }
    
    private fun checkPermissions(): Boolean {
        val hasRecordAudio = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        
        val hasNotification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true // No se requiere en versiones anteriores
        }
        
        Log.d(TAG, "Permissions check - RECORD_AUDIO: $hasRecordAudio, POST_NOTIFICATIONS: $hasNotification")
        return hasRecordAudio && hasNotification
    }
    
    private fun requestPermissions() {
        val permissionsToRequest = mutableListOf<String>()
        
        // Verificar permiso de micrófono
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.RECORD_AUDIO)
        }
        
        // Verificar permiso de notificaciones (Android 13+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
        
        if (permissionsToRequest.isNotEmpty()) {
            Log.d(TAG, "Requesting permissions: ${permissionsToRequest.joinToString()}")
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray(),
                PERMISSION_REQUEST_CODE
            )
        } else {
            Log.d(TAG, "All permissions already granted")
            startKeywordService()
        }
    }
    
    private fun startKeywordService() {
        val intent = Intent(this, KeywordService::class.java).apply {
            putExtra("independent_mode", true)
            putExtra("auto_restart", true)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        Toast.makeText(this, "Servicio de escucha iniciado - Funciona independientemente", Toast.LENGTH_LONG).show()
        
        // Opcional: cerrar la app después de iniciar el servicio
        // finish()
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            PERMISSION_REQUEST_CODE -> {
                val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                
                if (allGranted) {
                    Toast.makeText(this, "Permisos concedidos. Configurando optimización de batería...", Toast.LENGTH_SHORT).show()
                    requestBatteryOptimizationExemption()
                } else {
                    Toast.makeText(this, "Se requieren permisos para el funcionamiento", Toast.LENGTH_LONG).show()
                    // Mostrar configuración de permisos
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", packageName, null)
                    }
                    startActivity(intent)
                }
            }
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            BATTERY_OPTIMIZATION_REQUEST_CODE -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                    val isOptimizationDisabled = powerManager.isIgnoringBatteryOptimizations(packageName)
                    
                    if (isOptimizationDisabled) {
                        Log.d(TAG, "Battery optimization successfully disabled")
                        Toast.makeText(this, "Optimización de batería deshabilitada. Iniciando servicio...", Toast.LENGTH_SHORT).show()
                        startKeywordService()
                    } else {
                        Log.d(TAG, "Battery optimization not disabled")
                        Toast.makeText(this, "Optimización de batería no deshabilitada. El servicio puede no funcionar correctamente.", Toast.LENGTH_LONG).show()
                        startKeywordService() // Iniciar servicio de todas formas
                    }
                }
            }
        }
    }
    
    private fun registerTranscriptionReceiver() {
        transcriptionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    "com.minerva.erp.TRANSCRIPTION_UPDATE" -> {
                        val text = intent.getStringExtra("text") ?: ""
                        Log.d(TAG, "Transcription update: $text")
                        Toast.makeText(this@MainActivity, "Escuchando: $text", Toast.LENGTH_SHORT).show()
                    }
                    "com.minerva.erp.TRANSCRIPTION_COMPLETE" -> {
                        val text = intent.getStringExtra("text") ?: ""
                        Log.d(TAG, "Transcription complete: $text")
                        Toast.makeText(this@MainActivity, "Texto completo: $text", Toast.LENGTH_LONG).show()
                    }
                }
            }
        }
        
        val filter = IntentFilter().apply {
            addAction("com.minerva.erp.TRANSCRIPTION_UPDATE")
            addAction("com.minerva.erp.TRANSCRIPTION_COMPLETE")
        }
        
        registerReceiver(transcriptionReceiver, filter)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        transcriptionReceiver?.let {
            unregisterReceiver(it)
        }
    }
}