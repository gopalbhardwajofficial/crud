import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const baseUrl = 'https://reqres.in/api/users';

  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> data = jsonData['data'];
      return data.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<User> createUser(String name, String job) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {'name': name, 'job': job},
    );

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<void> updateUser(int id, String name, String job) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      body: {'name': name, 'job': job},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // Register User
  static Future<String> registerUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://reqres.in/api/register'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['token']; // return the token
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Registration failed: ${error['error']}');
    }
  }

  // Login User
  static Future<String> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://reqres.in/api/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['token']; // return the token
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Login failed: ${error['error']}');
    }
  }
}
