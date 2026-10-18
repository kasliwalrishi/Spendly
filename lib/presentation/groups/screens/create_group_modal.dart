import 'package:dio/dio.dart';
import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/data/groups/group_repository.dart';
import 'package:fingenie/presentation/groups/bloc/group_bloc.dart';
import 'package:fingenie/presentation/groups/bloc/group_events.dart';
import 'package:fingenie/presentation/groups/bloc/group_state.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'group_details.screen.dart';

class CreateGroupModal extends StatefulWidget {
  const CreateGroupModal({super.key});

  @override
  CreateGroupModalState createState() => CreateGroupModalState();
}

class CreateGroupModalState extends State<CreateGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _securityDepositController = TextEditingController();
  String _selectedTag = 'others';
  bool _securityDepositRequired = false;
  bool _autoSettlement = false;
  String _selectedCurrency = '₹';
  bool _isLoading = false;

  final List<_GroupTag> _tags = const [
    _GroupTag(name: 'Trip', value: 'trip', icon: Icons.flight),
    _GroupTag(name: 'Home', value: 'home', icon: Icons.home),
    _GroupTag(name: 'Couple', value: 'couple', icon: Icons.favorite),
    _GroupTag(name: 'Flatmates', value: 'flatmates', icon: Icons.people),
    _GroupTag(name: 'Others', value: 'others', icon: Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCurrency();
  }

  Future<void> _loadUserCurrency() async {
    final currentUser = context.read<AuthRepository>().getCurrentUser();
    if (currentUser != null) {
      setState(() {
        _selectedCurrency = switch (currentUser.currency) {
          'USD' => '\$',
          'EUR' => '€',
          _ => '₹',
        };
      });
    }
  }

  Widget _buildTagSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tags
          .map((tag) => _TagChip(
                tag: tag,
                isSelected: _selectedTag == tag.value,
                onSelected: () => setState(() => _selectedTag = tag.value),
              ))
          .toList(),
    );
  }

  Widget _buildSecurityDepositField() {
    if (!_securityDepositRequired) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        controller: _securityDepositController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Security Deposit Amount',
          prefixText: _selectedCurrency,
          prefixStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter deposit amount' : null,
      ),
    );
  }

  void _handleCreateGroup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      // Show loading state
      setState(() => _isLoading = true);

      final newGroup = await context.read<GroupRepository>().createGroup(
        initialMembers: [],
        name: _nameController.text,
        tag: _selectedTag,
        securityDepositRequired: _securityDepositRequired,
        securityDeposit: _securityDepositRequired
            ? double.tryParse(_securityDepositController.text)
            : null,
        autoSettlement: _autoSettlement,
      );

      AppLogger.success('Group created successfully: ${newGroup.id}');

      if (!mounted) return;

      // Navigate to detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<GroupBloc>(
                create: (context) => GroupBloc(
                  repository: GroupRepository(
                    dio: Dio(),
                    apiUrl: dotenv.env['API_URL'] ?? '',
                  ),
                  apiUrl: dotenv.env['API_URL'] ?? '',
                )..add(LoadGroups()),
              ),
            ],
            child: GroupDetailScreen(
              group: newGroup,
              apiUrl: dotenv.env['API_URL'] ?? '',
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create group: $e');
      AppLogger.error('Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.selectedGroup != current.selectedGroup ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        AppLogger.debug('BlocConsumer listener triggered with state: $state');

        // if (state.errorMessage != null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(state.errorMessage!),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // } else {
        AppLogger.debug(
            'Navigating to group details for group: ${state.selectedGroup!.id}');

        // Ensure we're mounted before navigating
        if (!mounted) return;

        // Use a try-catch block for navigation
        try {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider<GroupBloc>(
                    create: (context) => GroupBloc(
                      repository: GroupRepository(
                        dio: Dio(),
                        apiUrl: dotenv.env['API_URL'] ?? '',
                      ),
                      apiUrl: dotenv.env['API_URL'] ?? '',
                    ),
                  ),
                ],
                child: GroupDetailScreen(
                  group: state.selectedGroup!,
                  apiUrl: dotenv.env['API_URL'] ?? '',
                ),
              ),
            ),
          );
          AppLogger.success('Navigation successful');
        } catch (e, stackTrace) {
          AppLogger.error('Navigation failed: $e');
          AppLogger.error('Stack trace: $stackTrace');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to navigate to group details'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // }
      },
      builder: (context, state) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Group',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter group name',
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a group name' : null,
              ),
              const SizedBox(height: 20),
              Text('Select Group Type',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildTagSelector(),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Security Deposit Required'),
                value: _securityDepositRequired,
                onChanged: (value) =>
                    setState(() => _securityDepositRequired = value),
              ),
              _buildSecurityDepositField(),
              SwitchListTile(
                title: const Text('Auto Settlement'),
                value: _autoSettlement,
                onChanged: (value) => setState(() => _autoSettlement = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading ? null : _handleCreateGroup,
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Group',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTag {
  final String name;
  final String value;
  final IconData icon;

  const _GroupTag({
    required this.name,
    required this.value,
    required this.icon,
  });
}

class _TagChip extends StatelessWidget {
  final _GroupTag tag;
  final bool isSelected;
  final VoidCallback onSelected;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tag.icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[800],
            ),
            const SizedBox(width: 8),
            Text(
              tag.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
