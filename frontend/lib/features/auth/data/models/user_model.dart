class UserModel {
  final int id;
  final String? email;
  final String? mobileNumber;
  final String fullName;
  final String? avatarUrl;
  final bool isSsoUser;
  final String ssoProvider;
  final String organizationDomain;
  final bool isProfileCompleted;

  UserModel({
    required this.id,
    this.email,
    this.mobileNumber,
    required this.fullName,
    this.avatarUrl,
    required this.isSsoUser,
    required this.ssoProvider,
    required this.organizationDomain,
    required this.isProfileCompleted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isSsoUser: json['is_sso_user'] as bool? ?? false,
      ssoProvider: json['sso_provider'] as String? ?? '',
      organizationDomain: json['organization_domain'] as String? ?? '',
      isProfileCompleted: json['is_profile_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile_number': mobileNumber,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_sso_user': isSsoUser,
      'sso_provider': ssoProvider,
      'organization_domain': organizationDomain,
      'is_profile_completed': isProfileCompleted,
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? mobileNumber,
    String? fullName,
    String? avatarUrl,
    bool? isSsoUser,
    String? ssoProvider,
    String? organizationDomain,
    bool? isProfileCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSsoUser: isSsoUser ?? this.isSsoUser,
      ssoProvider: ssoProvider ?? this.ssoProvider,
      organizationDomain: organizationDomain ?? this.organizationDomain,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}
