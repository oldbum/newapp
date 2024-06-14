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
        title: "Welcome to Chore Score",
        description: "This app will help you manage your day-to-day tasks efficiently.",
        backgroundColor: Colors.blue,
        widgetTitle: Center(
          child: Text(
            "Welcome to Chore Score",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      ContentConfig(
        title: "Track Your Tasks",
        description: "Keep track of your daily tasks and routines with ease.",
        backgroundColor: Colors.green,
        widgetTitle: Center(
          child: Text(
            "Organize your day",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      ContentConfig(
        title: "Stay Organized",
        description: "One place for all of your login information, receipes, and daily journal.",
        backgroundColor: Colors.red,
        widgetTitle: Center(
          child: Text(
            "Information storage",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    ];
  }
}
