import 'package:flutter/material.dart';
import 'minerva_voice_plugin.dart';

class VoiceRecognitionPage extends StatefulWidget {
  @override
  _VoiceRecognitionPageState createState() => _VoiceRecognitionPageState();
}

class _VoiceRecognitionPageState extends State<VoiceRecognitionPage> {
  bool _isListening = false;
  bool _isInitialized = false;
  String _transcriptionText = '';
  String _status = 'Not initialized';
  
  @override
  void initState() {
    super.initState();
    _setupCallbacks();
    _initializeService();
  }
  
  void _setupCallbacks() {
    MinervaVoicePlugin.onKeywordDetected = () {
      setState(() {
        _status = 'Keyword "minerva" detected!';
      });
      
      // Show a dialog or navigate to main app
      _showKeywordDetectedDialog();
    };
    
    MinervaVoicePlugin.onTranscriptionUpdate = (text) {
      setState(() {
        _transcriptionText = text;
        _status = 'Transcribing...';
      });
    };
    
    MinervaVoicePlugin.onTranscriptionComplete = (text) {
      setState(() {
        _transcriptionText = text;
        _status = 'Transcription complete';
      });
      
      // Process the complete transcription
      _processTranscription(text);
    };
    
    MinervaVoicePlugin.onError = (error) {
      setState(() {
        _status = 'Error: $error';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };
  }
  
  Future<void> _initializeService() async {
    MinervaVoicePlugin.startListeningToEvents();
    
    final success = await MinervaVoicePlugin.initialize();
    setState(() {
      _isInitialized = success;
      _status = success ? 'Initialized and listening for "minerva"' : 'Failed to initialize';
    });
    
    if (success) {
      await MinervaVoicePlugin.startListening();
      setState(() {
        _isListening = true;
      });
    }
  }
  
  void _showKeywordDetectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Minerva Activated!'),
          content: Text('Keyword "minerva" detected. Starting transcription...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  void _processTranscription(String text) {
    // Here you can process the transcription text
    // For example, send it to your Flask API
    print('Complete transcription: $text');
    
    // Example: Send to your Minerva ERP API
    // _sendToAPI(text);
  }
  
  Future<void> _stopListening() async {
    await MinervaVoicePlugin.stopListening();
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
  }
  
  Future<void> _startListening() async {
    await MinervaVoicePlugin.startListening();
    setState(() {
      _isListening = true;
      _status = 'Listening for "minerva"';
    });
  }
  
  Future<void> _resetKeywordDetection() async {
    await MinervaVoicePlugin.resetKeywordDetection();
    setState(() {
      _transcriptionText = '';
      _status = 'Reset - Listening for "minerva" again';
    });
  }
  
  @override
  void dispose() {
    MinervaVoicePlugin.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minerva Voice Recognition'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _isInitialized ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Transcription Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        child: Text(
                          _transcriptionText.isEmpty 
                            ? 'No transcription yet...' 
                            : _transcriptionText,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Control Buttons
            if (_isInitialized) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isListening ? _stopListening : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetKeywordDetection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Say "Minerva" to activate voice recognition\n'
                      '2. After activation, speak your command\n'
                      '3. The app will transcribe your speech\n'
                      '4. Use "Reset" to listen for "Minerva" again',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
