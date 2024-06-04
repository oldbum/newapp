import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_app/homeimprovementprovider.dart';
import 'package:provider/provider.dart';
import 'home_improvement.dart';
import 'homeimprovementprovider.dart' as home_improvement_provider;

class HomeImprovementsPage extends StatefulWidget {
  const HomeImprovementsPage({super.key});

  @override
  _HomeImprovementsPageState createState() => _HomeImprovementsPageState();
}

class _HomeImprovementsPageState extends State<HomeImprovementsPage> {
  void _addProject(home_improvement_provider.HomeImprovementProvider provider) {
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  final newProject = HomeImprovementProject(
                    name: nameController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    progress: selectedProgress,
                    deadline: selectedDeadline,
                    materials: materialsController.text.split(',').map((e) => e.trim()).toList(),
                    budget: double.parse(budgetController.text),
                  );
                  provider.addProject(newProject);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editProject(home_improvement_provider.HomeImprovementProvider provider, int index, HomeImprovementProject project) {
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  final updatedProject = project.copyWith(
                    name: nameController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    progress: selectedProgress,
                    deadline: selectedDeadline,
                    materials: materialsController.text.split(',').map((e) => e.trim()).toList(),
                    budget: double.parse(budgetController.text),
                    isCompleted: project.isCompleted,
                    completedAt: project.completedAt,
                  );
                  provider.updateProject(index, updatedProject);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(home_improvement_provider.HomeImprovementProvider provider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                provider.deleteProject(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleCompletion(home_improvement_provider.HomeImprovementProvider provider, int index, HomeImprovementProject project) {
    final updatedProject = project.copyWith(isCompleted: true, completedAt: DateTime.now(), progress: 'Completed');
    provider.updateProject(index, updatedProject);
    provider.moveToHistory(index);
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
              MaterialPageRoute(builder: (context) => HomeImprovementsHistoryPage(history: Provider.of<home_improvement_provider.HomeImprovementProvider>(context, listen: false).history)),
            ),
          ),
        ],
      ),
      body: Consumer<home_improvement_provider.HomeImprovementProvider>(
        builder: (context, provider, child) {
          final projects = provider.projects;
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/home_improvements_background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_repair_service,
                            size: 100,
                            color: Colors.purple.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Home Improvement Projects Yet!',
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
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
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
                                  onPressed: () => _editProject(provider, index, project),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProject(provider, index),
                                ),
                                Checkbox(
                                  value: project.isCompleted,
                                  onChanged: (bool? value) {
                                    if (value != null && value) {
                                      _toggleCompletion(provider, index, project);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<home_improvement_provider.HomeImprovementProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () => _addProject(provider),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class HomeImprovementsHistoryPage extends StatelessWidget {
  final List<HomeImprovementProject> history;

  const HomeImprovementsHistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final completedProjects = history.where((project) => project.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Improvements History'),
      ),
      body: ListView.builder(
        itemCount: completedProjects.length,
        itemBuilder: (context, index) {
          final project = completedProjects[index];
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