import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
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

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }
}