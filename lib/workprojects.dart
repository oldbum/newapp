import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
}

class WorkProjectsPage extends StatefulWidget {
  const WorkProjectsPage({super.key});

  @override
  _WorkProjectsPageState createState() => _WorkProjectsPageState();
}

class _WorkProjectsPageState extends State<WorkProjectsPage> {
  final List<WorkProject> _projects = [];
  final List<WorkProject> _projectHistory = [];

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
      body: ListView.builder(
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