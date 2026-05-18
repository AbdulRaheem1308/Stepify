class Company {
  final String id;
  final String name;
  final String? domain;
  final String? logoUrl;
  final int memberCount;

  Company({
    required this.id,
    required this.name,
    this.domain,
    this.logoUrl,
    this.memberCount = 0,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      domain: json['domain'],
      logoUrl: json['logoUrl'],
      memberCount: json['memberCount'] ?? 0,
    );
  }
}

class CompanyMember {
  final String id;
  final String userId;
  final String companyId;
  final CompanyRole role;
  final int totalSteps;
  final Map<String, dynamic>? userMetadata; // name, avatar, etc.

  CompanyMember({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.role,
    this.totalSteps = 0,
    this.userMetadata,
  });
  
  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    return CompanyMember(
      id: json['id'],
      userId: json['userId'],
      companyId: json['companyId'],
      role: _parseRole(json['role']),
      totalSteps: json['totalSteps'] ?? 0,
      userMetadata: json['user'],
    );
  }

  static CompanyRole _parseRole(String? role) {
    switch (role) {
      case 'ADMIN': return CompanyRole.admin;
      case 'MANAGER': return CompanyRole.manager;
      default: return CompanyRole.employee;
    }
  }
}

enum CompanyRole { admin, manager, employee }
