enum ApplicationStatus {
  pending, // 0
  accepted, // 1
  rejected; // 2

  static ApplicationStatus fromInt(int v) =>
      ApplicationStatus.values[v.clamp(0, 2)];

  int toInt() => index;

  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'قيد الانتظار';
      case ApplicationStatus.accepted:
        return 'مقبول';
      case ApplicationStatus.rejected:
        return 'مرفوض';
    }
  }
}

class JobApplicationModel {
  final String id;
  final DateTime createdAt;
  final int postId; // bigint in DB → int in Dart
  final String applicantId; // uuid → references auth.users
  final String? message;
  final ApplicationStatus status;

  /// Populated when joined with "userProfile"
  final String? applicantName;
  final String? applicantAvatarUrl;
  final String? applicantJobTitle;

  const JobApplicationModel({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.applicantId,
    this.message,
    this.status = ApplicationStatus.pending,
    this.applicantName,
    this.applicantAvatarUrl,
    this.applicantJobTitle,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    // Joined "userProfile" data (aliased as "profile" in the query)
    final profile = json['profile'] as Map<String, dynamic>?;

    return JobApplicationModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      postId: json['post_id'] as int,
      applicantId: json['applicant_id'],
      message: json['message'],
      status: ApplicationStatus.fromInt(json['status'] ?? 0),
      // "userProfile" columns
      applicantName: profile?['jobTitle'], // use jobTitle as display label
      applicantJobTitle: profile?['jobTitle'],
      // Avatar URL is built separately via Storage.getPublicUrl
      applicantAvatarUrl: profile != null
          ? '${profile['id']}.png' // passed to Storage.getPublicUrl later
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'post_id': postId,
        'applicant_id': applicantId,
        if (message != null) 'message': message,
        'status': status.toInt(),
      };

  JobApplicationModel copyWith({ApplicationStatus? status}) {
    return JobApplicationModel(
      id: id,
      createdAt: createdAt,
      postId: postId,
      applicantId: applicantId,
      message: message,
      status: status ?? this.status,
      applicantName: applicantName,
      applicantAvatarUrl: applicantAvatarUrl,
      applicantJobTitle: applicantJobTitle,
    );
  }
}
