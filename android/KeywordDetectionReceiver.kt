package com.minerva.erp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class KeywordDetectionReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "KeywordDetectionReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "com.minerva.erp.KEYWORD_DETECTED" -> {
                Log.d(TAG, "Keyword 'minerva' detected!")
                handleKeywordDetection(context)
            }
        }
    }
    
    private fun handleKeywordDetection(context: Context) {
        // Launch the main activity
        val mainIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                   Intent.FLAG_ACTIVITY_CLEAR_TOP or
                   Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("keyword_detected", true)
            putExtra("auto_launch", true)
        }
        
        try {
            context.startActivity(mainIntent)
            Log.d(TAG, "MainActivity launched successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch MainActivity", e)
        }
    }
}
