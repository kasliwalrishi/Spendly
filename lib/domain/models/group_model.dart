class GroupModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String defaultCurrency;
  final String groupType;
  final bool isRecurring;
  final double securityDepositRequired;
  final bool requiresAdminApproval;
  final String budgetStrategy;
  final DateTime billingCycleStart;
  final String splitStrategy;
  final bool autoSettlement;
  final List<GroupMember>? members;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.defaultCurrency,
    required this.groupType,
    required this.isRecurring,
    required this.securityDepositRequired,
    required this.requiresAdminApproval,
    required this.budgetStrategy,
    required this.billingCycleStart,
    required this.splitStrategy,
    required this.autoSettlement,
    this.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'] as String? ?? '',
      defaultCurrency: json['defaultCurrency'] as String? ?? 'INR',
      groupType: json['groupType'] as String? ?? 'others',
      isRecurring: json['isRecurring'] as bool? ?? false,
      securityDepositRequired:
          (json['securityDepositRequired'] as num?)?.toDouble() ?? 0.0,
      requiresAdminApproval: json['requiresAdminApproval'] as bool? ?? false,
      budgetStrategy: json['budgetStrategy'] as String? ?? 'equal',
      billingCycleStart: json['billingCycleStart'] != null
          ? DateTime.parse(json['billingCycleStart'])
          : DateTime.now(),
      splitStrategy: json['splitStrategy'] as String? ?? 'equal',
      autoSettlement: json['autoSettlement'] as bool? ?? false,
      members: (json['members'] as List<dynamic>?)
          ?.map((memberJson) =>
              GroupMember.fromJson(memberJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'defaultCurrency': defaultCurrency,
      'groupType': groupType,
      'isRecurring': isRecurring,
      'securityDepositRequired': securityDepositRequired,
      'requiresAdminApproval': requiresAdminApproval,
      'budgetStrategy': budgetStrategy,
      'billingCycleStart': billingCycleStart.toIso8601String(),
      'splitStrategy': splitStrategy,
      'autoSettlement': autoSettlement,
      'members': members?.map((member) => member.toJson()).toList(),
    };
  }
}

class GroupMember {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String groupId;
  final String userId;
  final String role;
  final DateTime? joinedAt;
  final bool isActive;
  final double sharePercent;

  GroupMember({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.groupId,
    required this.userId,
    required this.role,
    this.joinedAt,
    required this.isActive,
    required this.sharePercent,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String? ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      groupId: json['groupId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      joinedAt:
          json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      isActive: json['isActive'] as bool? ?? true,
      sharePercent: (json['sharePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt?.toIso8601String(),
      'isActive': isActive,
      'sharePercent': sharePercent,
    };
  }
}
