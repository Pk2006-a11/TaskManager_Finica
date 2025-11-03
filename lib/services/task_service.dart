import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  final String baseUrl = "http://10.0.2.2:8080/api/tasks";
  final AuthService authService;

  TaskService(this.authService);

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Cookie": authService.sessionCookie ?? ""
      };

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((task) => Task.fromJson(task)).toList();
    }
    return [];
  }

  Future<bool> addTask(String title, String description) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({
        "title": title,
        "description": description,
        "completed": false,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse("$baseUrl/${task.id}"),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTask(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
    return response.statusCode == 204;
  }
}
