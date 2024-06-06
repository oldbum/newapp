import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reorderables/reorderables.dart';

class LoginData {
  String website;
  String username;
  String password;
  String email;

  LoginData({
    required this.website,
    required this.username,
    required this.password,
    this.email = '',
  });

  // Convert a LoginData into a Map.
  Map<String, dynamic> toJson() => {
        'website': website,
        'username': username,
        'password': password,
        'email': email,
      };

  // Convert a Map into a LoginData.
  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        website: json['website'],
        username: json['username'],
        password: json['password'],
        email: json['email'] ?? '',
      );
}

class LoginSupercenterPage extends StatefulWidget {
  const LoginSupercenterPage({super.key});

  @override
  _LoginSupercenterPageState createState() => _LoginSupercenterPageState();
}

class _LoginSupercenterPageState extends State<LoginSupercenterPage> {
  List<LoginData> logins = [];

  @override
  void initState() {
    super.initState();
    _loadLogins();
  }

  Future<void> _loadLogins() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loginsString = prefs.getString('logins');
    if (loginsString != null) {
      setState(() {
        logins = (json.decode(loginsString) as List)
            .map((data) => LoginData.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> _saveLogins() async {
    final prefs = await SharedPreferences.getInstance();
    final String loginsString = json.encode(logins.map((login) => login.toJson()).toList());
    prefs.setString('logins', loginsString);
  }

  void _addOrEditLogin({LoginData? login, bool isEdit = false}) {
    final TextEditingController websiteController = TextEditingController(text: login?.website ?? '');
    final TextEditingController usernameController = TextEditingController(text: login?.username ?? '');
    final TextEditingController passwordController = TextEditingController(text: login?.password ?? '');
    final TextEditingController emailController = TextEditingController(text: login?.email ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Login' : 'Add New Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website/URL'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email (Optional)'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(isEdit ? 'Update' : 'Add'),
              onPressed: () {
                if (isEdit) {
                  setState(() {
                    login!.website = websiteController.text;
                    login.username = usernameController.text;
                    login.password = passwordController.text;
                    login.email = emailController.text;
                  });
                } else {
                  setState(() {
                    logins.add(
                      LoginData(
                        website: websiteController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                        email: emailController.text,
                      ),
                    );
                  });
                }
                _saveLogins();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLogin(LoginData login) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Login'),
          content: Text('Are you sure you want to delete the login for ${login.website}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  logins.remove(login);
                });
                _saveLogins();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Supercenter'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loginbackground.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
              ),
            ),
          ),
          logins.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No Logins Added Yet!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.lock,
                        size: 100,
                        color: Color(0xFFD1C4E9), // Lighter purple color
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Press the + to add a new login',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              : ReorderableColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      final LoginData login = logins.removeAt(oldIndex);
                      logins.insert(newIndex, login);
                      _saveLogins();
                    });
                  },
                  children: logins.map((login) {
                    return Card(
                      key: ValueKey(login),
                      child: ExpansionTile(
                        title: Text(login.website),
                        subtitle: const Text('Tap to view details'),
                        children: <Widget>[
                          ListTile(
                            title: Text('Username: ${login.username}'),
                          ),
                          ListTile(
                            title: Text('Password: ${login.password}'),
                          ),
                          ListTile(
                            title: Text('Email: ${login.email.isNotEmpty ? login.email : "Not provided"}'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text('Edit'),
                                onPressed: () => _addOrEditLogin(login: login, isEdit: true),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () => _deleteLogin(login),
                              ),
                              const SizedBox(width: 8),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditLogin(),
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFD1C4E9), // Lighter purple color
      ),
    );
  }
}
