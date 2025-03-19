import 'package:flutter/material.dart';
import 'package:nursing_mangment/classes.dart';
import 'package:nursing_mangment/main.dart';

/// USER DASHBOARD (for non-admin users)
class UserDashboardPage extends StatefulWidget {
  final String username;
  const UserDashboardPage({Key? key, required this.username}) : super(key: key);

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  Widget build(BuildContext context) {
    // Filter projects where the logged-in user is a member.
    List<Project> userProjects = DataStore.projects
        .where((project) => project.members.any((user) =>
            user.name.toLowerCase() == widget.username.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}")),
      body: userProjects.isEmpty
          ? const Center(child: Text("No projects assigned to you."))
          : ListView.builder(
              itemCount: userProjects.length,
              itemBuilder: (context, index) {
                Project project = userProjects[index];
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
                                      User(name: widget.username, isAdmin: false),
                                )));
                  },
                );
              },
            ),
    );
  }
}
