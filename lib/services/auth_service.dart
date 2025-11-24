import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';

class AuthService with ChangeNotifier {
  // Usa a baseUrl centralizada para consistência entre plataformas
  static String get baseUrl => AppConfig.baseUrl;
  User? _currentUser;
  String? _csrfToken;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<String?> getCsrfToken() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('$baseUrl/csrf-token'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _csrfToken = data['token'];
        return _csrfToken;
      } else {
        print('Erro ao obter token CSRF: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exceção ao obter token CSRF: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_csrfToken == null) {
        final token = await getCsrfToken();
        if (token == null) {
          return false;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        
        await _saveUserData(data['user']);
        
        notifyListeners();
        return true;
      } else {
        print('Erro ao fazer login: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção ao fazer login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required DateTime birthDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_csrfToken == null) {
        final token = await getCsrfToken();
        if (token == null) {
          return false;
        }
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(birthDate);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          '_csrfToken': _csrfToken!,
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'cpf': cpf,
          'password': password,
          'birth_date': formattedDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('Registro realizado com sucesso: ${data['message']}');
          
          if (data.containsKey('user')) {
            _currentUser = User.fromJson(data['user']);
            await _saveUserData(data['user']);
          }
          
          notifyListeners();
          return true;
        } else {
          print('Erro no registro: ${data['message'] ?? 'Erro desconhecido'}');
          return false;
        }
      } else {
        print('Erro ao fazer registro: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção ao fazer registro: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String cpf,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_csrfToken == null) {
        final token = await getCsrfToken();
        if (token == null) {
          return false;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          '_csrfToken': _csrfToken!,
        },
        body: jsonEncode({
          'cpf': cpf,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('Reset de senha realizado com sucesso: ${data['message']}');
          return true;
        } else {
          print('Erro no reset de senha: ${data['message'] ?? 'Erro desconhecido'}');
          return false;
        }
      } else {
        print('Erro ao fazer reset de senha: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção ao fazer reset de senha: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _csrfToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    
    notifyListeners();
  }

  Future<bool> checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      final data = jsonDecode(userData);
      _currentUser = User.fromJson(data);
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String documentNumber,
    required DateTime birthDate,
    String? password,
    String? passwordConfirmation,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'Usuário não está logado',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_csrfToken == null) {
        final token = await getCsrfToken();
        if (token == null) {
          return {
            'success': false,
            'message': 'Erro ao obter token de segurança',
          };
        }
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(birthDate);
      
      Map<String, dynamic> requestBody = {
        'id': _currentUser!.id,
        'name': name,
        'email': email,
        'document_number': documentNumber,
        'birth_date': formattedDate,
      };

      // Adicionar senha apenas se foi fornecida
      if (password != null && password.isNotEmpty) {

        requestBody['password'] = password;
        requestBody['password_confirmation'] = passwordConfirmation ?? password;
        print('senha: '+ requestBody['password']);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          '_csrfToken': _csrfToken!,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Atualizar dados do usuário local com os dados do formulário
          if (_currentUser != null) {
            _currentUser = User(
              id: _currentUser!.id,
              idClinic: _currentUser!.idClinic,
              name: name,
              email: email,
              documentType: _currentUser!.documentType,
              documentNumber: documentNumber,
              birthDate: '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
              appointmentPrice: _currentUser!.appointmentPrice,
              type: _currentUser!.type,
              situation: _currentUser!.situation,
              status: _currentUser!.status,
              createdAt: _currentUser!.createdAt,
              updatedAt: _currentUser!.updatedAt,
              deletedAt: _currentUser!.deletedAt,
            );
            await _saveUserData(_currentUser!.toJson());
            notifyListeners();
          }
          return {
            'success': true,
            'message': 'Perfil atualizado com sucesso!',
          };
        }
        
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Atualizar dados do usuário local
          if (data.containsKey('user')) {
            _currentUser = User.fromJson(data['user']);
            await _saveUserData(data['user']);
          } else if (_currentUser != null) {
            // Se a API não retornar os dados do usuário, atualizar com os dados do formulário
            _currentUser = User(
              id: _currentUser!.id,
              idClinic: _currentUser!.idClinic,
              name: name,
              email: email,
              documentType: _currentUser!.documentType,
              documentNumber: documentNumber,
              birthDate: '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',

              appointmentPrice: _currentUser!.appointmentPrice,
              type: _currentUser!.type,
              situation: _currentUser!.situation,
              status: _currentUser!.status,
              createdAt: _currentUser!.createdAt,
              updatedAt: _currentUser!.updatedAt,
              deletedAt: _currentUser!.deletedAt,
            );
            await _saveUserData(_currentUser!.toJson());
          }
          
          notifyListeners();
          return {
            'success': true,
            'message': data['message'] ?? 'Perfil atualizado com sucesso!',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erro ao atualizar perfil',
          };
        }
      } else {
        if (response.body.isEmpty) {
          return {
            'success': false,
            'message': 'Resposta vazia. Erro ao atualizar perfil: ${response.statusCode}',
          };
        }
        
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Erro ao atualizar perfil: \${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Erro ao atualizar perfil: \${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Exceção ao atualizar perfil: $e');
      return {
        'success': false,
        'message': 'Erro de conexão. Tente novamente.',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }
}