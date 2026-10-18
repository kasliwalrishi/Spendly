import 'package:fingenie/presentation/groups/bloc/group_events.dart';
import 'package:fingenie/presentation/groups/bloc/group_state.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/groups/group_repository.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository repository;
  final String apiUrl;

  GroupBloc({
    required this.repository,
    required this.apiUrl,
  }) : super(GroupState()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroup>(_onCreateGroup);
    on<AddGroupMembers>(_onAddGroupMembers);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final groups = await repository.fetchUserGroups();
      emit(state.copyWith(
        isLoading: false,
        groups: groups,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load groups: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateGroup(
      CreateGroup event, Emitter<GroupState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final newGroup = await repository.createGroup(
        name: event.name,
        tag: event.tag,
        securityDepositRequired: event.securityDepositRequired,
        securityDeposit: event.securityDeposit,
        autoSettlement: event.autoSettlement,
        initialMembers: event.initialMembers,
      );

      emit(state.copyWith(
        isLoading: false,
        group: newGroup, // This triggers navigation
        groups: [...state.groups, newGroup],
        errorMessage: null,
      ));
    } catch (e) {
      AppLogger.error('Failed to create group: ${e.toString()}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create group: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddGroupMembers(
      AddGroupMembers event, Emitter<GroupState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        groups: state.groups,
      ));

      AppLogger.info('Finding users for numbers: ${event.memberNumbers}');

      // Find user IDs for all phone numbers
      final List<String> userIds = [];
      for (final phoneNumber in event.memberNumbers) {
        try {
          final userId = await repository.findUserByPhone(phoneNumber);
          userIds.add(userId);
          AppLogger.debug('Found user $userId for number $phoneNumber');
        } catch (e) {
          AppLogger.error('Failed to find user for number $phoneNumber: $e');
          // Continue with other numbers even if one fails
        }
      }

      if (userIds.isEmpty) {
        throw Exception('No valid users found from the provided phone numbers');
      }

      AppLogger.info('Adding members to group ${event.groupId}: $userIds');

      // Add members to group
      await repository.addGroupMembers(
        groupId: event.groupId,
        memberIds: userIds,
      );

      // Fetch updated group details to get latest member list
      final updatedGroup = await repository.getGroupDetails(event.groupId);
      AppLogger.success(
          'Members added successfully. Group now has ${updatedGroup.id} members');

      // // Update state with new group details
      emit(state.copyWith(
        isLoading: false,
        selectedGroup: updatedGroup,
        groups: state.groups
            .map((g) => g.id == updatedGroup.id ? updatedGroup : g)
            .toList(),
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add members: $e');
      AppLogger.error('Stack trace: $stackTrace');

      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add members: ${e.toString()}',
        groups: state.groups,
      ));
    }
  }
}
