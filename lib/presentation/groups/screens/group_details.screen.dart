import 'package:fingenie/domain/models/group_model.dart';
import 'package:fingenie/presentation/contacts/screens/contact_selection_screen.dart';
import 'package:fingenie/presentation/groups/bloc/group_bloc.dart';
import 'package:fingenie/presentation/groups/bloc/group_events.dart';
import 'package:fingenie/presentation/groups/bloc/group_state.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;
  final String apiUrl; // Add this parameter

  const GroupDetailScreen({
    required this.group,
    required this.apiUrl, // Add this parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final parentGroupBloc = context.read<GroupBloc>();

    AppLogger.info(
        'GroupBloc in GroupDetailScreen: ${context.read<GroupBloc>()}');

    return BlocBuilder<GroupBloc, GroupState>(builder: (context, state) {
      final currentGroup = state.selectedGroup ?? group;
      final members = currentGroup.members ?? [];
      return Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                final currentGroupBloc = context.read<GroupBloc>();

                AppLogger.warning(
                    'GroupBloc before navigation: $currentGroupBloc');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<GroupBloc>.value(
                      value: currentGroupBloc,
                      child: ContactSelectionScreen(
                        onContactsSelected: (contacts) {
                          AppLogger.info(
                              'Contacts selected: ${contacts.length}');
                          currentGroupBloc.add(AddGroupMembers(
                            groupId: group.id,
                            memberNumbers: contacts.map((e) => e).toList(),
                          ));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Group Info Card
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('Created by: ${currentGroup.createdBy}'),
                          Text('Split Strategy: ${currentGroup.splitStrategy}'),
                          Text(
                              'Budget Strategy: ${currentGroup.budgetStrategy}'),
                        ],
                      ),
                    ),
                  ),
// Members List
                  Expanded(
                    child: members.isEmpty
                        ? Center(
                            child: Text(
                              'No members yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    member.role.substring(0, 1).toUpperCase(),
                                  ),
                                ),
                                title: Text(member.userId),
                                subtitle: Text(
                                  'Role: ${member.role}\nShare: ${member.sharePercent}%',
                                ),
                                trailing: member.isActive
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // Navigate to add members screen
        //   },
        //   child: const Icon(Icons.person_add),
        // ),
      );
    });
  }
}
