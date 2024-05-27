import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      listContentConfig: _createSlides(),
      onDonePress: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      onSkipPress: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  List<ContentConfig> _createSlides() {
    return [
      ContentConfig(
        title: "Welcome to the App",
        description: "This app will help you manage your daily tasks efficiently.",
        backgroundColor: Colors.blue,
        widgetTitle: Center(
          child: Text(
            "Welcome Image Placeholder",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      ContentConfig(
        title: "Track Your Tasks",
        description: "Keep track of your daily tasks with ease.",
        backgroundColor: Colors.green,
        widgetTitle: Center(
          child: Text(
            "Tasks Image Placeholder",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      ContentConfig(
        title: "Stay Organized",
        description: "Stay organized and achieve your goals.",
        backgroundColor: Colors.red,
        widgetTitle: Center(
          child: Text(
            "Organized Image Placeholder",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    ];
  }
}
