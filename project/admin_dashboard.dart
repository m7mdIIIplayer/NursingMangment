import 'package:flutter/material.dart';
import 'package:nursing_mangment/classes.dart';
import 'package:nursing_mangment/main.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review),
            onPressed: () {
              // This action could open a global rating view if needed.
              // For simplicity, we let ratings be done per project.
            },
          )
        ],
      ),
      body: DataStore.projects.isEmpty
          ? const Center(child: Text("No projects created."))
          : ListView.builder(
              itemCount: DataStore.projects.length,
              itemBuilder: (context, index) {
                Project project = DataStore.projects[index];
                return ListTile(
                  title: Text(project.title),
                  subtitle:
                      Text("Project Admin: ${project.projectAdmin.name}"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProjectDetailPage(
                                  project: project,
                                  currentUser:
                                       User(name: 'admin', isAdmin: true),
                                )));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog for creating a new project (admin only)
  void _showCreateProjectDialog() {
    String projectTitle = '';
    String workerCount = '';
    List<User> selectedMembers = [];
    User? selectedProjectAdmin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Create New Project"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Project Title"),
                    onChanged: (value) {
                      projectTitle = value;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Number of Workers"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      workerCount = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("Select Members:"),
                  Column(
                    children: DataStore.availableUsers.map((user) {
                      bool isSelected = selectedMembers.contains(user);
                      return CheckboxListTile(
                        title: Text(user.name),
                        value: isSelected,
                        onChanged: (bool? val) {
                          setState(() {
                            if (val == true) {
                              selectedMembers.add(user);
                            } else {
                              selectedMembers.remove(user);
                              if (selectedProjectAdmin == user) {
                                selectedProjectAdmin = null;
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text("Select Project Admin:"),
                  DropdownButton<User>(
                    hint: const Text("Choose admin"),
                    value: selectedProjectAdmin,
                    items: selectedMembers.map((user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (User? value) {
                      setState(() {
                        selectedProjectAdmin = value;
                      });
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (projectTitle.isNotEmpty &&
                      workerCount.isNotEmpty &&
                      selectedMembers.isNotEmpty &&
                      selectedProjectAdmin != null) {
                    Project newProject = Project(
                        title: projectTitle,
                        workerCount: workerCount,
                        members: selectedMembers,
                        projectAdmin: selectedProjectAdmin!,
                        tasks: []);
                    setState(() {
                      DataStore.projects.add(newProject);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Create"),
              )
            ],
          );
        });
      },
    );
  }
}
