/// MODEL CLASSES

// User model: a simple representation with name and role.
class User {
  final String name;
  final bool isAdmin;

  User({required this.name, this.isAdmin = false});
}

// Task model: now includes a note and a list of users who marked it as complete.
class Task {
  String title;
  String priority;
  DateTime? date;
  List<String> completedBy;
  String note;

  Task({
    required this.title,
    this.priority = 'Medium',
    this.date,
    List<String>? completedBy,
    this.note = '',
  }) : completedBy = completedBy ?? [];
}

// Project model: includes a map for member ratings.
class Project {
  String title;
  String workerCount;
  List<User> members;
  User projectAdmin;
  List<Task> tasks;
  Map<String, int> userRatings;

  Project({
    required this.title,
    required this.workerCount,
    required this.members,
    required this.projectAdmin,
    required this.tasks,
    Map<String, int>? userRatings,
  }) : userRatings = userRatings ?? {};
}

/// GLOBAL DATASTORE
class DataStore {
  static List<Project> projects = [];

  // In a real app, available users would come from a database.
  static List<User> availableUsers = [
    User(name: 'Alice'),
    User(name: 'Bob'),
    User(name: 'Charlie'),
  ];
}
