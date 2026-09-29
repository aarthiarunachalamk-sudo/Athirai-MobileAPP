class OrganizationModel {
  final String name;
  final String domain;
  final String provider;
  final String? authorizationUrl;
  final String? state;

  OrganizationModel({
    required this.name,
    required this.domain,
    required this.provider,
    this.authorizationUrl,
    this.state,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json, {String? authorizationUrl, String? state}) {
    return OrganizationModel(
      name: json['name'] as String? ?? 'Your Organization',
      domain: json['domain'] as String? ?? '',
      provider: json['provider'] as String? ?? 'microsoft',
      authorizationUrl: authorizationUrl ?? json['authorization_url'] as String?,
      state: state ?? json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain': domain,
      'provider': provider,
      'authorization_url': authorizationUrl,
      'state': state,
    };
  }
}

class AuthTokensModel {
  final String access;
  final String refresh;

  AuthTokensModel({required this.access, required this.refresh});

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}
