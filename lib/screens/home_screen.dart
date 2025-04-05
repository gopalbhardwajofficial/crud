import 'package:flutter/material.dart';
import 'package:crud/models/user_model.dart';
import 'package:crud/services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];
  bool isLoading = true;

  final nameController = TextEditingController();
  final jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  void showUserDialog({User? user}) {
    nameController.text = user?.firstName ?? '';
    jobController.text = user?.job ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Update User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: jobController, decoration: InputDecoration(labelText: 'Job')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final job = jobController.text.trim();

              if (name.isEmpty || job.isEmpty) return;

              Navigator.pop(context);
              try {
                if (user == null) {
                  final newUser = await ApiService.createUser(name, job);
                  setState(() {
                    users.add(newUser);  // Add to the local list
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User added: ${newUser.firstName}'),
                  ));
                } else {
                  await ApiService.updateUser(user.id ?? 0, name, job);
                  setState(() {
                    users = users.map((u) => u.id == user.id ? user.copyWith(firstName: name, job: job) : u).toList();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User updated'),
                  ));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Operation failed: $e')),
                );
              }
            },
            child: Text(user == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deleteUser(id);
                setState(() {
                  users.removeWhere((user) => user.id == id);  // Remove from local list
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deletion failed: $e')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchUsers,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar ?? ''),
              ),
              title: Text('${user.firstName} ${user.lastName ?? ''}'),
              subtitle: Text(user.email ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showUserDialog(user: user),
                    icon: Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => confirmDelete(user.id ?? 0),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}