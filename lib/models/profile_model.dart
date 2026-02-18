class UserProfileModel {
  final String id;
  final DateTime? createdAt;
  final String jobTitle;
  final String? description;
  final String? skills;
  final int completedProject;
  final int succesProject;
  final int numberofYearsExperince;
  final int status;

  const UserProfileModel({
    required this.id,
    this.createdAt,
    required this.jobTitle,
    this.description,
    this.skills,
    this.completedProject = 0,
    this.succesProject = 0,
    this.numberofYearsExperince = 0,
    this.status = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      jobTitle: json['jobTitle'],
      description: json['description'],
      skills: json['skills'],
      completedProject: json['completedProject'] ?? 0,
      succesProject: json['succesProject'] ?? 0,
      numberofYearsExperince: json['numberofYearsExperince'] ?? 0,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'jobTitle': jobTitle,
        'description': description,
        'skills': skills,
        'completedProject': completedProject,
        'succesProject': succesProject,
        'numberofYearsExperince': numberofYearsExperince,
        'status': status,
      };

  UserProfileModel copyWith({
    String? jobTitle,
    String? description,
    String? skills,
    int? completedProject,
    int? succesProject,
    int? numberofYearsExperince,
    int? status,
  }) {
    return UserProfileModel(
      id: id,
      createdAt: createdAt,
      jobTitle: jobTitle ?? this.jobTitle,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      completedProject: completedProject ?? this.completedProject,
      succesProject: succesProject ?? this.succesProject,
      numberofYearsExperince:
          numberofYearsExperince ?? this.numberofYearsExperince,
      status: status ?? this.status,
    );
  }

  /// Returns skills as a List (stored as comma-separated string in DB)
  List<String> get skillsList => skills == null || skills!.trim().isEmpty
      ? []
      : skills!.split(',').map((s) => s.trim()).toList();

  /// Success rate as percentage (0–100)
  int get successRate => completedProject == 0
      ? 0
      : ((succesProject / completedProject) * 100).round();
}
