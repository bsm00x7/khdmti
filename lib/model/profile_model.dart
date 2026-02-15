class ProfileModel {
  final String id;
  final String jobTitle;
  final String? description;
  final String? skills;
  final int completedProject;
  final int succesProject;
  final int numberofYearsExperince;

  const ProfileModel({
    required this.id,
    required this.jobTitle,
    this.description,
    this.skills,
    this.completedProject = 0,
    this.succesProject = 0,
    this.numberofYearsExperince = 0,
  });

  ProfileModel copyWith({
    String? id,
    String? jobTitle,
    String? description,
    String? skills,
    int? completedProject,
    int? succesProject,
    int? numberofYearsExperince,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      completedProject: completedProject ?? this.completedProject,
      succesProject: succesProject ?? this.succesProject,
      numberofYearsExperince:
          numberofYearsExperince ?? this.numberofYearsExperince,
    );
  }

  /// 🔄 From Supabase
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      jobTitle: json['jobTitle'],
      description: json['description'],
      skills: json['skills'],
      completedProject: json['completedProject'] ?? 0,
      succesProject: json['succesProject'] ?? 0,
      numberofYearsExperince: json['numberofYearsExperince'] ?? 0,
    );
  }

  /// 🔃 To Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'description': description,
      'skills': skills,
      'completedProject': completedProject,
      'succesProject': succesProject,
      'numberofYearsExperince': numberofYearsExperince,
    };
  }
}
