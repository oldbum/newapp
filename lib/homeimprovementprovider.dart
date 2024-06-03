import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeImprovementProject {
  String name;
  String description;
  String priority;
  String progress;
  DateTime? deadline;
  List<String> materials;
  double budget;
  DateTime? completedAt;
  bool isCompleted;

  HomeImprovementProject({
    required this.name,
    required this.description,
    required this.priority,
    required this.progress,
    this.deadline,
    this.materials = const [],
    this.budget = 0.0,
    this.completedAt,
    this.isCompleted = false,
  });

  HomeImprovementProject copyWith({
    String? name,
    String? description,
    String? priority,
    String? progress,
    DateTime? deadline,
    List<String>? materials,
    double? budget,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return HomeImprovementProject(
      name: name ?? this.name,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      materials: materials ?? this.materials,
      budget: budget ?? this.budget,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'priority': priority,
      'progress': progress,
      'deadline': deadline?.toIso8601String(),
      'materials': materials,
      'budget': budget,
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  static HomeImprovementProject fromJson(Map<String, dynamic> json) {
    return HomeImprovementProject(
      name: json['name'],
      description: json['description'],
      priority: json['priority'],
      progress: json['progress'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      materials: List<String>.from(json['materials']),
      budget: json['budget'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isCompleted: json['isCompleted'],
    );
  }
}

class HomeImprovementProvider with ChangeNotifier {
  List<HomeImprovementProject> _projects = [];

  List<HomeImprovementProject> get projects => _projects;

  HomeImprovementProvider() {
    _loadProjects();
  }

  void addProject(HomeImprovementProject project) {
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void updateProject(int index, HomeImprovementProject project) {
    _projects[index] = project;
    _saveProjects();
    notifyListeners();
  }

  void deleteProject(int index) {
    _projects.removeAt(index);
    _saveProjects();
    notifyListeners();
  }

  void _saveProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedProjects = _projects.map((project) => jsonEncode(project.toJson())).toList();
    prefs.setStringList('homeImprovementProjects', encodedProjects);
  }

  void _loadProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedProjects = prefs.getStringList('homeImprovementProjects');
    if (encodedProjects != null) {
      _projects = encodedProjects.map((encodedProject) {
        try {
          Map<String, dynamic> projectMap = jsonDecode(encodedProject);
          return HomeImprovementProject.fromJson(projectMap);
        } catch (e) {
          print('Error decoding project: $e');
          return HomeImprovementProject(
            name: 'Unknown',
            description: 'Unknown',
            priority: 'Low',
            progress: 'Not Started',
            deadline: null,
            materials: [],
            budget: 0.0,
          );
        }
      }).toList();
    }
    notifyListeners();
  }
}