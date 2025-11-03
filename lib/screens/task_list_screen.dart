import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final AuthService authService = AuthService();
  late TaskService taskService;

  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    taskService = TaskService(); // ✅ No arguments needed if your TaskService has default constructor
    loadTasks();
  }

  Future<void> loadTasks() async {
    List<Task> fetchedTasks = await taskService.fetchTasks();
    setState(() {
      tasks = fetchedTasks;
      isLoading = false;
    });
  }

  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await taskService.addTask(
                  titleController.text,
                  descController.text,
                );
                if (!mounted) return;
                Navigator.pop(context);
                loadTasks();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleCompletion(Task task) async {
    Task updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      completed: !task.completed,
    );

    await taskService.updateTask(updated);
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await taskService.deleteTask(id);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
        backgroundColor: Colors.blue,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks found"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => toggleCompletion(task),
                        ),
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTask(task.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
