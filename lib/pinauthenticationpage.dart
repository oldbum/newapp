import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinAuthenticationPage extends StatefulWidget {
  final bool isSettingUp;

  const PinAuthenticationPage({super.key, this.isSettingUp = false});

  @override
  _PinAuthenticationPageState createState() => _PinAuthenticationPageState();
}

class _PinAuthenticationPageState extends State<PinAuthenticationPage> {
  final TextEditingController _pinController = TextEditingController();

  Future<void> _setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
  }

  Future<bool> _checkPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('user_pin');
    return storedPin == pin;
  }

  void _onSubmit() async {
    if (widget.isSettingUp) {
      await _setPin(_pinController.text);
      Navigator.of(context).pop(true);
    } else {
      final isValid = await _checkPin(_pinController.text);
      if (isValid) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSettingUp ? 'Set Up PIN' : 'Enter PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSubmit,
              child: Text(widget.isSettingUp ? 'Set PIN' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
