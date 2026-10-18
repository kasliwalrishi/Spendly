import 'package:dio/dio.dart';
import 'package:fingenie/data/groups/group_repository.dart';
import 'package:fingenie/presentation/activity/screens/activity_screen.dart';
import 'package:fingenie/presentation/groups/bloc/group_bloc.dart';
import 'package:fingenie/presentation/groups/bloc/group_events.dart';
import 'package:fingenie/presentation/groups/bloc/group_state.dart';
import 'package:fingenie/presentation/groups/screens/create_group_modal.dart';
import 'package:fingenie/presentation/groups/screens/group_screens.dart';
import 'package:fingenie/presentation/home/bloc/expense_bloc.dart';
import 'package:fingenie/presentation/ocr/screens/ocr.dart';
import 'package:fingenie/presentation/profile/screen/profile_page.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GroupsScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
    context.read<GroupBloc>().add(LoadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<GroupBloc>(),
          ),
          BlocProvider.value(
            value: context.read<ExpenseBloc>(),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            title: const Text(
              'Fin Genie.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.group_add),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: MultiBlocProvider(
                        providers: [
                          Provider<GroupRepository>(
                            create: (context) => GroupRepository(
                              dio: Dio(),
                              apiUrl: dotenv.env['API_URL'] ?? '',
                            ),
                          ),
                          BlocProvider<GroupBloc>(
                            create: (context) => GroupBloc(
                              repository: context.read<GroupRepository>(),
                              apiUrl: dotenv.env['API_URL'] ?? '',
                            ),
                          ),
                        ],
                        child: const CreateGroupModal(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
          body: _shownScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              AppLogger.info('BottomNav index: //');

              setState(() => _currentIndex = index);
            },
            selectedItemColor: const Color(0xFF2DD4BF),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups), label: 'Groups'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up), label: 'Activity'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBalanceCard(ExpenseState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFFFCD34D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '+6.5%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '\$76,256.91',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('+ ADD EXPENSE'),
          ),
        ],
      ),
    );
  }

  Widget _shownScreen() {
    if (_currentIndex == 0) {
      return SafeArea(
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExpenseLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(state),
                    const SizedBox(height: 24),
                    _buildBalanceOverview(),
                    const SizedBox(height: 24),
                    _buildGroupsList(),
                    const SizedBox(height: 16),
                    _buildRecentExpenses(state.expenses),
                    const SizedBox(height: 16),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const OcrScreen()));
                        },
                        child: const Text('OCR')),
                  ],
                ),
              );
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
      );
    } else {
      return _screens[_currentIndex - 1];
    }
  }

  Widget _buildBalanceOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard2(
            'YOU OWE',
            '\$562.72',
            'You should Pay to others',
            Icons.arrow_upward,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBalanceCard2(
            'YOU\'RE OWED',
            '\$38822.72',
            'Others should Pay to you',
            Icons.arrow_downward,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard2(
    String title,
    String amount,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Groups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildGroupItem(
                    'Mumbai Hackathon',
                    'you are owed ₹687.50',
                    Icons.airplane_ticket,
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildGroupItem(
                    'SVIET Hack',
                    'you owe ₹135.01',
                    Icons.code,
                    Colors.purple,
                  ),
                  // if (state.isLoading)
                  //   const Center(child: CircularProgressIndicator())
                  // else if (state.errorMessage != null)
                  //   Center(child: Text(state.errorMessage!))
                  // else ...[
                  //   for (int i = 0; i < state.groups.length; i++) ...[
                  //     _buildGroupItem(
                  //       state.groups[i].name,
                  //       state.groups[i].balance >= 0
                  //           ? 'you are owed ₹${state.groups[i].balance.abs()}'
                  //           : 'you owe ₹${state.groups[i].balance.abs()}',
                  //       IconData(
                  //         int.parse(state.groups[i].icon.isEmpty
                  //             ? '0xf415' // Default icon code
                  //             : state.groups[i].icon),
                  //         fontFamily: 'MaterialIcons',
                  //       ),
                  //       Color(int.parse(state.groups[i].color.isEmpty
                  //           ? '0xFF2196F3' // Default color
                  //           : state.groups[i].color)),
                  //     ),
                  //     if (i < state.groups.length - 1) const Divider(),
                  // ],
                  // ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: subtitle.contains('owed') ? Colors.green : Colors.red,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildRecentExpenses(List<int> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ExpenseItem(
                icon: '☕',
                title: 'Coffee',
                amount: -10.12,
                date: DateTime.now(),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String icon;
  final String title;
  final double amount;
  final DateTime date;
  final VoidCallback onTap;

  const ExpenseItem({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        DateFormat('dd MMM - HH:mm').format(date),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Text(
        amount > 0
            ? '+\$${amount.abs().toStringAsFixed(2)}'
            : '-\$${amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: amount > 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
