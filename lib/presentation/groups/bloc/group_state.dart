import 'package:fingenie/domain/models/group_model.dart';

class GroupState {
  final GroupModel? group;
  final List<GroupModel> groups;
  final bool isLoading;
  final String? errorMessage;
  final double balance;
  final List<String> members;
  final double securityDeposit;
  final String? groupCurrency;
  final GroupModel? selectedGroup;

  GroupState({
    this.group,
    this.groups = const [],
    this.isLoading = false,
    this.errorMessage,
    this.balance = 0.0,
    this.members = const [],
    this.securityDeposit = 0.0,
    this.groupCurrency,
    this.selectedGroup,
  });

  GroupState copyWith({
    GroupModel? group,
    List<GroupModel>? groups,
    bool? isLoading,
    String? errorMessage,
    double? balance,
    List<String>? members,
    double? securityDeposit,
    String? groupCurrency,
    GroupModel? selectedGroup,
  }) {
    return GroupState(
      group: group ?? this.group,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      balance: balance ?? this.balance,
      members: members ?? this.members,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      groupCurrency: groupCurrency ?? this.groupCurrency,
      selectedGroup: selectedGroup ?? this.selectedGroup,
    );
  }
}
