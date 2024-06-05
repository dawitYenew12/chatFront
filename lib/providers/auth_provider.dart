import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final Box _authBox = Hive.box('authBox');

  bool get isAuthenticated => _authBox.get('token') != null;

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://chatapp-45vm.onrender.com/api/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authBox.put('token', data['token']);
      _authBox.put('userId', data['userId']);
      notifyListeners();
    } else {
      print('Failed to login: ${response.body}');
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://chatapp-45vm.onrender.com/api/users/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      await login(username, password);
    } else {
      print('Failed to register: ${response.body}');
      throw Exception('Failed to register');
    }
  }

  String get token => _authBox.get('token');
  String get userId => _authBox.get('userId');
}
