import 'package:flutter/material.dart';
// Adjust this import based on your project structure

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
}
class LoginSupercenterPage extends StatefulWidget {
  const LoginSupercenterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginSupercenterPageState createState() => _LoginSupercenterPageState();
}

class _LoginSupercenterPageState extends State<LoginSupercenterPage> {
  List<LoginData> logins = [];

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
      body: ListView.builder(
        itemCount: logins.length,
        itemBuilder: (context, index) {
          final login = logins[index];
          return Card(
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditLogin(),
        child: const Icon(Icons.add),
      ),
    );
  }
}