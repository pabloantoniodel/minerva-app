import 'dart:convert';
import 'package:http/http.dart' as http;

class MinervaApiClient {
  static const String baseUrl = 'http://localhost:5000/api'; // Change to your Flask API URL
  String? _authToken;
  
  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Get headers with authentication
  Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Process voice command through Minerva ERP API
  Future<Map<String, dynamic>> processVoiceCommand({
    required String transcription,
    required String userId,
    required String companyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/voice-commands'),
        headers: _headers,
        body: json.encode({
          'transcription': transcription,
          'user_id': userId,
          'company_id': companyId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process voice command: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error processing voice command: $e');
    }
  }
  
  /// Create a document from voice transcription
  Future<Map<String, dynamic>> createVoiceDocument({
    required String transcription,
    required String entityType,
    required int entityId,
    required String documentType,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/documents'),
        headers: _headers,
        body: json.encode({
          'entity_type': entityType,
          'entity_id': entityId,
          'document_type': documentType,
          'document_name': 'voice_note_${DateTime.now().millisecondsSinceEpoch}.txt',
          'relation_purpose': 'voice_note',
          'document_category': 'voice',
          'file_path': null, // No file, just content
          'content': transcription,
          'metadata': {
            'created_by_voice': true,
            'timestamp': DateTime.now().toIso8601String(),
            'user_id': userId,
          },
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create voice document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating voice document: $e');
    }
  }
  
  /// Search employees by voice command
  Future<List<Map<String, dynamic>>> searchEmployees(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees?search=$query'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to search employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching employees: $e');
    }
  }
  
  /// Get employee with documents
  Future<Map<String, dynamic>> getEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/$employeeId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting employee: $e');
    }
  }
  
  /// Create a new employee via voice command
  Future<Map<String, dynamic>> createEmployee({
    required String name,
    required String position,
    required int companyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: _headers,
        body: json.encode({
          'company_id': companyId,
          'name': name,
          'position': position,
          'contract': 'indefinido',
          'contribution_group': '1',
          'work_schedule': 'jornada completa',
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }
  
  /// Login to get authentication token
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
}

/// Voice command processor for Minerva ERP
class VoiceCommandProcessor {
  final MinervaApiClient _apiClient = MinervaApiClient();
  
  /// Process voice transcription and execute appropriate actions
  Future<Map<String, dynamic>> processCommand({
    required String transcription,
    required String userId,
    required String companyId,
  }) async {
    final lowerTranscription = transcription.toLowerCase();
    
    // Voice command patterns
    if (lowerTranscription.contains('crear empleado') || 
        lowerTranscription.contains('nuevo empleado')) {
      return await _processCreateEmployeeCommand(transcription, companyId);
    }
    
    if (lowerTranscription.contains('buscar empleado') || 
        lowerTranscription.contains('encontrar empleado')) {
      return await _processSearchEmployeeCommand(transcription);
    }
    
    if (lowerTranscription.contains('ver empleado') || 
        lowerTranscription.contains('mostrar empleado')) {
      return await _processShowEmployeeCommand(transcription);
    }
    
    if (lowerTranscription.contains('crear nota') || 
        lowerTranscription.contains('guardar nota')) {
      return await _processCreateNoteCommand(transcription, userId, companyId);
    }
    
    // Default: create a voice note
    return await _processCreateNoteCommand(transcription, userId, companyId);
  }
  
  Future<Map<String, dynamic>> _processCreateEmployeeCommand(
    String transcription, 
    String companyId,
  ) async {
    // Extract name and position from transcription
    // This is a simple example - you might want to use NLP for better extraction
    final name = _extractNameFromTranscription(transcription);
    final position = _extractPositionFromTranscription(transcription);
    
    if (name != null && position != null) {
      final result = await _apiClient.createEmployee(
        name: name,
        position: position,
        companyId: int.parse(companyId),
      );
      
      return {
        'action': 'employee_created',
        'message': 'Empleado $name creado como $position',
        'data': result,
      };
    }
    
    return {
      'action': 'error',
      'message': 'No se pudo extraer el nombre y posición del empleado',
    };
  }
  
  Future<Map<String, dynamic>> _processSearchEmployeeCommand(String transcription) async {
    final query = _extractSearchQueryFromTranscription(transcription);
    
    if (query != null) {
      final employees = await _apiClient.searchEmployees(query);
      
      return {
        'action': 'employees_found',
        'message': 'Se encontraron ${employees.length} empleados',
        'data': employees,
      };
    }
    
    return {
      'action': 'error',
      'message': 'No se pudo extraer la consulta de búsqueda',
    };
  }
  
  Future<Map<String, dynamic>> _processShowEmployeeCommand(String transcription) async {
    final employeeId = _extractEmployeeIdFromTranscription(transcription);
    
    if (employeeId != null) {
      final employee = await _apiClient.getEmployee(employeeId);
      
      return {
        'action': 'employee_shown',
        'message': 'Mostrando empleado ${employee['employee']['name']}',
        'data': employee,
      };
    }
    
    return {
      'action': 'error',
      'message': 'No se pudo extraer el ID del empleado',
    };
  }
  
  Future<Map<String, dynamic>> _processCreateNoteCommand(
    String transcription, 
    String userId, 
    String companyId,
  ) async {
    final result = await _apiClient.createVoiceDocument(
      transcription: transcription,
      entityType: 'company_id',
      entityId: int.parse(companyId),
      documentType: 'voice_note',
      userId: userId,
    );
    
    return {
      'action': 'note_created',
      'message': 'Nota de voz guardada exitosamente',
      'data': result,
    };
  }
  
  // Helper methods for extracting information from transcription
  String? _extractNameFromTranscription(String transcription) {
    // Simple extraction - you might want to use more sophisticated NLP
    final words = transcription.split(' ');
    final nameIndex = words.indexOf('llama') + 1;
    if (nameIndex > 0 && nameIndex < words.length) {
      return words[nameIndex];
    }
    return null;
  }
  
  String? _extractPositionFromTranscription(String transcription) {
    // Simple extraction
    final words = transcription.split(' ');
    final positionIndex = words.indexOf('como') + 1;
    if (positionIndex > 0 && positionIndex < words.length) {
      return words[positionIndex];
    }
    return null;
  }
  
  String? _extractSearchQueryFromTranscription(String transcription) {
    // Extract search query after "buscar" or "encontrar"
    final words = transcription.split(' ');
    final searchIndex = words.indexOf('empleado') + 1;
    if (searchIndex > 0 && searchIndex < words.length) {
      return words.sublist(searchIndex).join(' ');
    }
    return null;
  }
  
  int? _extractEmployeeIdFromTranscription(String transcription) {
    // Extract ID from transcription
    final regex = RegExp(r'\b(\d+)\b');
    final match = regex.firstMatch(transcription);
    return match?.group(1)?.toInt();
  }
}
