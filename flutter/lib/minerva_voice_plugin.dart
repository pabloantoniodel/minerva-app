import 'dart:async';
import 'package:flutter/services.dart';

class MinervaVoicePlugin {
  static const MethodChannel _channel = MethodChannel('minerva_voice');
  static const EventChannel _eventChannel = EventChannel('minerva_voice_events');
  
  static StreamSubscription<dynamic>? _eventSubscription;
  
  // Callbacks
  static Function()? onKeywordDetected;
  static Function(String)? onTranscriptionUpdate;
  static Function(String)? onTranscriptionComplete;
  static Function(String)? onError;
  
  /// Initialize the voice recognition service
  static Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      return result == true;
    } catch (e) {
      onError?.call('Failed to initialize: $e');
      return false;
    }
  }
  
  /// Start listening for the keyword "minerva"
  static Future<bool> startListening() async {
    try {
      final result = await _channel.invokeMethod('startListening');
      return result == true;
    } catch (e) {
      onError?.call('Failed to start listening: $e');
      return false;
    }
  }
  
  /// Stop listening and transcription
  static Future<bool> stopListening() async {
    try {
      final result = await _channel.invokeMethod('stopListening');
      return result == true;
    } catch (e) {
      onError?.call('Failed to stop listening: $e');
      return false;
    }
  }
  
  /// Reset keyword detection (allow detecting "minerva" again)
  static Future<bool> resetKeywordDetection() async {
    try {
      final result = await _channel.invokeMethod('resetKeywordDetection');
      return result == true;
    } catch (e) {
      onError?.call('Failed to reset keyword detection: $e');
      return false;
    }
  }
  
  /// Check if the service is currently listening
  static Future<bool> isListening() async {
    try {
      final result = await _channel.invokeMethod('isListening');
      return result == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Start listening to events from the service
  static void startListeningToEvents() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _handleEvent(event);
      },
      onError: (dynamic error) {
        onError?.call('Event channel error: $error');
      },
    );
  }
  
  /// Stop listening to events
  static void stopListeningToEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
  
  /// Handle events from the service
  static void _handleEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      final type = event['type'] as String?;
      
      switch (type) {
        case 'keyword_detected':
          onKeywordDetected?.call();
          break;
        case 'transcription_update':
          final text = event['text'] as String? ?? '';
          onTranscriptionUpdate?.call(text);
          break;
        case 'transcription_complete':
          final text = event['text'] as String? ?? '';
          onTranscriptionComplete?.call(text);
          break;
        case 'error':
          final error = event['message'] as String? ?? 'Unknown error';
          onError?.call(error);
          break;
        default:
          print('Unknown event type: $type');
      }
    }
  }
  
  /// Clean up resources
  static void dispose() {
    stopListeningToEvents();
    onKeywordDetected = null;
    onTranscriptionUpdate = null;
    onTranscriptionComplete = null;
    onError = null;
  }
}
