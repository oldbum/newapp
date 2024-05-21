import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
}

class HomeImprovementsPage extends StatefulWidget {
  const HomeImprovementsPage({super.key});

  @override
  _HomeImprovementsPageState createState() => _HomeImprovementsPageState();
}

class _HomeImprovementsPageState extends State<HomeImprovementsPage> {
  final List<HomeImprovementProject> _projects = [];
  final List<HomeImprovementProject> _history = [];

  void _addProject() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController materialsController = TextEditingController();
    final TextEditingController budgetController = TextEditingController();
    String selectedPriority = 'Low';
    String selectedProgress = 'Not Started';
    DateTime? selectedDeadline;

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
                    TextField(
                      controller: materialsController,
                      decoration: const InputDecoration(labelText: 'Materials (comma separated)'),
                    ),
                    TextField(
                      controller: budgetController,
                      decoration: const InputDecoration(labelText: 'Budget'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                      items: ['Low', 'Medium', 'High'].map<DropdownMenuItem<String>>((String value) {
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
                      items: ['Not Started', 'In Progress', 'Completed'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text('Select Deadline: ${selectedDeadline != null ? DateFormat('yMMMd').format(selectedDeadline!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime(2000),
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
                if (nameController.text.isNotEmpty && double.tryParse(budgetController.text) != null) {
                  setState(() {
                    _projects.add(HomeImprovementProject(
                      name: nameController.text,
                      description: descriptionController.text,
                      priority: selectedPriority,
                      progress: selectedProgress,
                      deadline: selectedDeadline,
                      materials: materialsController.text.split(',').map((e) => e.trim()).toList(),
                      budget: double.parse(budgetController.text),
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

  void _editProject(HomeImprovementProject project) {
    final TextEditingController nameController = TextEditingController(text: project.name);
    final TextEditingController descriptionController = TextEditingController(text: project.description);
    final TextEditingController materialsController = TextEditingController(text: project.materials.join(', '));
    final TextEditingController budgetController = TextEditingController(text: project.budget.toString());
    String selectedPriority = project.priority;
    String selectedProgress = project.progress;
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
                    TextField(
                      controller: materialsController,
                      decoration: const InputDecoration(labelText: 'Materials (comma separated)'),
                    ),
                    TextField(
                      controller: budgetController,
                      decoration: const InputDecoration(labelText: 'Budget'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                      items: ['Low', 'Medium', 'High'].map<DropdownMenuItem<String>>((String value) {
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
                      items: ['Not Started', 'In Progress', 'Completed'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text('Select Deadline: ${selectedDeadline != null ? DateFormat('yMMMd').format(selectedDeadline!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime(2000),
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
                if (nameController.text.isNotEmpty && double.tryParse(budgetController.text) != null) {
                  setState(() {
                    project.name = nameController.text;
                    project.description = descriptionController.text;
                    project.priority = selectedPriority;
                    project.progress = selectedProgress;
                    project.deadline = selectedDeadline;
                    project.materials = materialsController.text.split(',').map((e) => e.trim()).toList();
                    project.budget = double.parse(budgetController.text);
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

  void _toggleCompletion(HomeImprovementProject project) {
    setState(() {
      project.isCompleted = true;
      project.completedAt = DateTime.now();
      project.progress = 'Completed';
      _projects.remove(project);
      _history.add(project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Improvements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeImprovementsHistoryPage(history: _history)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            color: project.isCompleted ? Colors.green[100] : Colors.red[100],
            child: ListTile(
              title: Text(project.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority: ${project.priority}'),
                  Text('Progress: ${project.progress}'),
                  if (project.deadline != null) Text('Deadline: ${DateFormat('yMMMd').format(project.deadline!)}'),
                  Text('Materials: ${project.materials.join(', ')}'),
                  Text('Budget: \$${project.budget.toStringAsFixed(2)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProject(project),
                  ),
                  Checkbox(
                    value: project.isCompleted,
                    onChanged: (bool? value) {
                      _toggleCompletion(project);
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

class HomeImprovementsHistoryPage extends StatelessWidget {
  final List<HomeImprovementProject> history;

  const HomeImprovementsHistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Improvements History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final project = history[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            color: Colors.grey[300],
            child: ListTile(
              title: Text(project.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority: ${project.priority}'),
                  Text('Progress: ${project.progress}'),
                  if (project.deadline != null) Text('Deadline: ${DateFormat('yMMMd').format(project.deadline!)}'),
                  Text('Materials: ${project.materials.join(', ')}'),
                  Text('Budget: \$${project.budget.toStringAsFixed(2)}'),
                  if (project.completedAt != null) Text('Completed at: ${DateFormat('yMMMd').format(project.completedAt!)} ${DateFormat('jm').format(project.completedAt!)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}