import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkProject {
  String name;
  String description;
  String priority;
  String progress;
  bool isCompleted;
  DateTime? completedAt;
  DateTime deadline;

  WorkProject({
    required this.name,
    required this.description,
    required this.priority,
    required this.progress,
    this.isCompleted = false,
    this.completedAt,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'priority': priority,
        'progress': progress,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'deadline': deadline.toIso8601String(),
      };

  static WorkProject fromJson(Map<String, dynamic> json) => WorkProject(
        name: json['name'],
        description: json['description'],
        priority: json['priority'],
        progress: json['progress'],
        isCompleted: json['isCompleted'],
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        deadline: DateTime.parse(json['deadline']),
      );
}

class WorkProjectsPage extends StatefulWidget {
  const WorkProjectsPage({super.key});

  @override
  _WorkProjectsPageState createState() => _WorkProjectsPageState();
}

class _WorkProjectsPageState extends State<WorkProjectsPage> {
  final List<WorkProject> _projects = [];
  final List<WorkProject> _projectHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectList = _projects.map((project) => jsonEncode(project.toJson())).toList();
    final projectHistoryList = _projectHistory.map((project) => jsonEncode(project.toJson())).toList();
    await prefs.setStringList('projects', projectList);
    await prefs.setStringList('projectHistory', projectHistoryList);
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectList = prefs.getStringList('projects') ?? [];
    final projectHistoryList = prefs.getStringList('projectHistory') ?? [];
    setState(() {
      _projects.addAll(projectList.map((project) => WorkProject.fromJson(jsonDecode(project))).toList());
      _projectHistory.addAll(projectHistoryList.map((project) => WorkProject.fromJson(jsonDecode(project))).toList());
    });
  }

  void _addProject() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedPriority = 'Low';
    String selectedProgress = 'Not Started';
    final List<String> priorityOptions = ['Low', 'Medium', 'High'];
    final List<String> progressOptions = ['Not Started', 'In Progress', 'Completed'];
    DateTime? selectedDeadline = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Project'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Project Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Priority'),
                    DropdownButton<String>(
                      value: selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPriority = newValue!;
                        });
                      },
                      items: priorityOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Progress'),
                    DropdownButton<String>(
                      value: selectedProgress,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProgress = newValue!;
                        });
                      },
                      items: progressOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Deadline'),
                    ListTile(
                      title: Text(selectedDeadline != null
                          ? DateFormat('yMMMd').format(selectedDeadline!)
                          : 'Select Deadline'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDeadline) {
                          setState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _projects.add(WorkProject(
                      name: nameController.text,
                      description: descriptionController.text,
                      priority: selectedPriority,
                      progress: selectedProgress,
                      deadline: selectedDeadline ?? DateTime.now(),
                    ));
                  });
                  _saveProjects();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editProject(WorkProject project) {
    final TextEditingController nameController = TextEditingController(text: project.name);
    final TextEditingController descriptionController = TextEditingController(text: project.description);
    String selectedPriority = project.priority;
    String selectedProgress = project.progress;
    final List<String> priorityOptions = ['Low', 'Medium', 'High'];
    final List<String> progressOptions = ['Not Started', 'In Progress', 'Completed'];
    DateTime? selectedDeadline = project.deadline;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Project Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Priority'),
                    DropdownButton<String>(
                      value: selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPriority = newValue!;
                        });
                      },
                      items: priorityOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Progress'),
                    DropdownButton<String>(
                      value: selectedProgress,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProgress = newValue!;
                        });
                      },
                      items: progressOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Deadline'),
                    ListTile(
                      title: Text(selectedDeadline != null
                          ? DateFormat('yMMMd').format(selectedDeadline!)
                          : 'Select Deadline'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDeadline) {
                          setState(() {
                            selectedDeadline = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    project.name = nameController.text;
                    project.description = descriptionController.text;
                    project.priority = selectedPriority;
                    project.progress = selectedProgress;
                    project.deadline = selectedDeadline!;
                  });
                  _saveProjects();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(WorkProject project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete ${project.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  project.isCompleted = true;
                  project.completedAt = DateTime.now();
                  _projects.remove(project);
                  _projectHistory.add(project);
                });
                _saveProjects();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleProjectCompletion(WorkProject project) {
    setState(() {
      project.isCompleted = !project.isCompleted;
      if (project.isCompleted) {
        project.completedAt = DateTime.now();
        project.progress = 'Completed';
        _projectHistory.add(project);
        _projects.remove(project);
      }
    });
    _saveProjects();
  }

  void _showProjectHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectHistoryPage(projects: _projectHistory)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showProjectHistory,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/work_projects_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work,
                        size: 100,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Work Projects Yet!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap the + button to add your first project.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${project.description}'),
                            Text('Priority: ${project.priority}'),
                            Text('Progress: ${project.progress}'),
                            Text('Deadline: ${DateFormat('yMMMd').format(project.deadline)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editProject(project),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteProject(project),
                            ),
                            Checkbox(
                              value: project.isCompleted,
                              onChanged: (bool? value) {
                                _toggleProjectCompletion(project);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProjectHistoryPage extends StatelessWidget {
  final List<WorkProject> projects;

  const ProjectHistoryPage({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final completedProjects = projects.where((project) => project.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project History'),
      ),
      body: ListView.builder(
        itemCount: completedProjects.length,
        itemBuilder: (context, index) {
          final project = completedProjects[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(project.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${project.description}'),
                  Text('Priority: ${project.priority}'),
                  Text('Progress: ${project.progress}'),
                  Text('Deadline: ${DateFormat('yMMMd').format(project.deadline)}'),
                  Text('Completed at: ${DateFormat('yMMMd').format(project.completedAt!)} ${DateFormat('jm').format(project.completedAt!)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}