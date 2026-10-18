abstract class GroupEvent {}

class LoadGroups extends GroupEvent {}

class CreateGroup extends GroupEvent {
  final String name;
  final String tag;
  final List<String> initialMembers;
  final bool securityDepositRequired;
  final double? securityDeposit;
  final bool autoSettlement;

  CreateGroup({
    required this.name,
    required this.tag,
    this.initialMembers = const [],
    required this.securityDepositRequired,
    this.securityDeposit,
    required this.autoSettlement,
  });
}

class AddGroupMembers extends GroupEvent {
  final String groupId;
  final List<String> memberNumbers;

  AddGroupMembers({
    required this.groupId,
    required this.memberNumbers,
  });
}
