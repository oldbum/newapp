import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<ContentConfig> slides = [];

  @override
  void initState() {
    super.initState();
    slides.add(
      ContentConfig(
        title: "Welcome to MyApp",
        description: "Your one-stop solution for managing tasks efficiently.",
        widgetDescription: Container(
          height: 200,
          width: double.infinity,
          color: Colors.blueAccent,
          child: Center(
            child: Text(
              'Welcome',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
    slides.add(
      ContentConfig(
        title: "Track Your Tasks",
        description: "Easily track your daily tasks and stay organized.",
        widgetDescription: Container(
          height: 200,
          width: double.infinity,
          color: Colors.greenAccent,
          child: Center(
            child: Text(
              'Track Tasks',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
    );
    slides.add(
      ContentConfig(
        title: "Manage Your Groceries",
        description: "Keep your grocery list handy and updated.",
        widgetDescription: Container(
          height: 200,
          width: double.infinity,
          color: Colors.orangeAccent,
          child: Center(
            child: Text(
              'Manage Groceries',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
    );
    slides.add(
      ContentConfig(
        title: "Get Started",
        description: "Create an account to sync your data across devices.",
        widgetDescription: Container(
          height: 200,
          width: double.infinity,
          color: Colors.purpleAccent,
          child: Center(
            child: Text(
              'Get Started',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        backgroundColor: Colors.purpleAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      listContentConfig: slides,
      onDonePress: () {
        Navigator.pushReplacementNamed(context, '/signup');
      },
    );
  }
}