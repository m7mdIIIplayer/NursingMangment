import 'package:flutter/material.dart';
import 'package:nursing_mangment/screens/login_screen.dart';
import 'classes.dart';


/// MAIN
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}






class ProjectDetailPage extends StatefulWidget {
  final Project project;
  final User currentUser;

  const ProjectDetailPage(
      {Key? key, required this.project, required this.currentUser})
      : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.currentUser.isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: _showRateMembersDialog,
                  tooltip: "Rate Members",
                )
              ]
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic project info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("Project Admin: ${widget.project.projectAdmin.name}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Members: ${widget.project.members.map((e) => e.name).join(', ')}"),
          ),
          const Divider(),
          // List of tasks
          Expanded(
            child: widget.project.tasks.isEmpty
                ? const Center(child: Text("No tasks available."))
                : ListView.builder(
                    itemCount: widget.project.tasks.length,
                    itemBuilder: (context, index) {
                      Task task = widget.project.tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Priority: ${task.priority} | Date: ${task.date != null ? task.date!.toLocal().toString().substring(0, 10) : 'Not set'}"),
                              if (task.note.isNotEmpty)
                                Text("Note: ${task.note}"),
                              if (isAdmin && task.completedBy.isNotEmpty)
                                Text(
                                    "Completed by: ${task.completedBy.join(', ')}"),
                            ],
                          ),
                          trailing: isAdmin
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditTaskDialog(task);
                                  },
                                )
                              : Checkbox(
                                  value: task.completedBy
                                      .contains(widget.currentUser.name),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!task.completedBy.contains(
                                            widget.currentUser.name)) {
                                          task.completedBy
                                              .add(widget.currentUser.name);
                                        }
                                      } else {
                                        task.completedBy
                                            .remove(widget.currentUser.name);
                                      }
                                    });
                                  },
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton:
          isAdmin ? FloatingActionButton(
            onPressed: _showAddTaskDialog,
            child: const Icon(Icons.add),
          ) : null,
    );
  }


  void _showAddTaskDialog() {
    String taskTitle = '';
    String taskPriority = 'Medium';
    DateTime? taskDate;
    String taskNote = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Task"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Task Title"),
                    onChanged: (value) {
                      taskTitle = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: taskPriority,
                    items: ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        taskPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          taskDate = pickedDate;
                        });
                      }
                    },
                    child: Text(taskDate == null
                        ? "Select Date"
                        : "Date: ${taskDate!.toLocal().toString().substring(0, 10)}"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Task Note"),
                    onChanged: (value) {
                      taskNote = value;
                    },
                  ),
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
                  if (taskTitle.isNotEmpty) {
                    setState(() {
                      widget.project.tasks.add(Task(
                        title: taskTitle,
                        priority: taskPriority,
                        date: taskDate,
                        note: taskNote,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              )
            ],
          );
        });
      },
    );
  }

  // For Admin: edit an existing task.
  void _showEditTaskDialog(Task task) {
    String taskTitle = task.title;
    String taskPriority = task.priority;
    DateTime? taskDate = task.date;
    String taskNote = task.note;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Task"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Task Title"),
                    controller: TextEditingController(text: taskTitle),
                    onChanged: (value) {
                      taskTitle = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: taskPriority,
                    items: ['Low', 'Medium', 'High'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        taskPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: taskDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          taskDate = pickedDate;
                        });
                      }
                    },
                    child: Text(taskDate == null
                        ? "Select Date"
                        : "Date: ${taskDate!.toLocal().toString().substring(0, 10)}"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Task Note"),
                    controller: TextEditingController(text: taskNote),
                    onChanged: (value) {
                      taskNote = value;
                    },
                  ),
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
                  setState(() {
                    task.title = taskTitle;
                    task.priority = taskPriority;
                    task.date = taskDate;
                    task.note = taskNote;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        });
      },
    );
  }

  // For Admin: open a dialog to rate each project member.
  void _showRateMembersDialog() {
    // Create a temporary copy of ratings
    Map<String, int> tempRatings = Map.from(widget.project.userRatings);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Rate Project Members (0-10)"),
            content: SingleChildScrollView(
              child: Column(
                children: widget.project.members.map((member) {
                  int currentRating = tempRatings[member.name] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(member.name)),
                        Slider(
                          value: currentRating.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: currentRating.toString(),
                          onChanged: (value) {
                            setState(() {
                              tempRatings[member.name] = value.toInt();
                            });
                          },
                        ),
                        Text("${tempRatings[member.name] ?? 0}"),
                      ],
                    ),
                  );
                }).toList(),
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
                  setState(() {
                    widget.project.userRatings = tempRatings;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        });
      },
    );
  }
}

