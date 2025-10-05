package com.minerva.erp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.minerva.erp.service.KeywordService

class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_PACKAGE_REPLACED -> {
                Log.d(TAG, "Device booted or app updated, starting KeywordService")
                startKeywordService(context)
            }
        }
    }
    
    private fun startKeywordService(context: Context) {
        try {
            val serviceIntent = Intent(context, KeywordService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.d(TAG, "KeywordService started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start KeywordService", e)
        }
    }
}
