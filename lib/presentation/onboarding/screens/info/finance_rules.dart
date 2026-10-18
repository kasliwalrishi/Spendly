import 'package:dio/dio.dart';
import 'package:fingenie/core/config/theme/app_colors.dart';
import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/data/groups/group_repository.dart';
import 'package:fingenie/presentation/groups/bloc/group_bloc.dart';
import 'package:fingenie/presentation/home/bloc/expense_bloc.dart';
import 'package:fingenie/presentation/home/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FinanceRulesScreen extends StatefulWidget {
  final String currencyCode;
  final double monthlyIncome;
  final int age;
  final String occupation;
  const FinanceRulesScreen(
      {super.key,
      required this.currencyCode,
      required this.monthlyIncome,
      required this.age,
      required this.occupation});

  @override
  State<FinanceRulesScreen> createState() => _FinanceRulesScreenState();
}

class _FinanceRulesScreenState extends State<FinanceRulesScreen> {
  final PageController _pageController = PageController();
  int _currentRule = 0;
  bool _showDetail = false;
  bool _isLoading = false;
  final AuthRepository _authRepository = AuthRepository();

  final List<FinanceRule> rules = [
    FinanceRule(
      title: "24-Hour Rule",
      description:
          "Wait 24 hours before any non-essential purchase. This cooling-off period helps avoid impulse buying and ensures mindful spending.",
      icon: "timer",
      tips: [
        "Add items to a wishlist instead of buying immediately",
        "Set calendar reminders for review after 24 hours",
        "Calculate the item's value in terms of work hours"
      ],
    ),
    FinanceRule(
      title: "HALT Rule",
      description:
          "Never make financial decisions when Hungry, Angry, Lonely, or Tired. These emotional states often lead to poor spending choices.",
      icon: "emotional_state",
      tips: [
        "Check your emotional state before opening shopping apps",
        "Create a pre-purchase checklist",
        "Practice mindfulness before financial decisions"
      ],
    ),
    FinanceRule(
      title: "Emergency Fund Principle",
      description:
          "Maintain 3-6 months of essential expenses in an easily accessible account. This safety net protects you from unexpected financial shocks.",
      icon: "emergency_fund",
      tips: [
        "Calculate your monthly essential expenses",
        "Set up automatic transfers to emergency fund",
        "Keep this fund separate from regular savings"
      ],
    ),
    FinanceRule(
      title: "10-Second Rule",
      description:
          "Take 10 seconds to check your account balance and monthly budget before any purchase. This quick pause promotes awareness.",
      icon: "quick_check",
      tips: [
        "Enable quick balance checking in your banking app",
        "Create shortcuts to your budget tracking tool",
        "Practice mindful spending pauses"
      ],
    ),
    FinanceRule(
      title: "Sunk Cost Fallacy",
      description:
          "Don't continue spending money on something just because you've already invested in it. Past expenses shouldn't influence future decisions.",
      icon: "sunk_cost",
      tips: [
        "Evaluate decisions based on future value",
        "Learn to recognize emotional attachments",
        "Focus on opportunity costs"
      ],
    ),
    // Additional rules...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentRule = index;
                    _showDetail = false;
                  });
                },
                itemCount: rules.length,
                itemBuilder: (context, index) {
                  return _buildRuleCard(rules[index]);
                },
              ),
            ),
            _buildNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Essential Finance Rules",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Master these principles for better financial health",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentRule + 1) / rules.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(FinanceRule rule) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      rule.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rule.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AnimatedCrossFade(
                            firstChild: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showDetail = true;
                                });
                              },
                              child: const Text("Learn More"),
                            ),
                            secondChild: _buildTips(rule),
                            crossFadeState: _showDetail
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                            sizeCurve: Curves.easeInOut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTips(FinanceRule rule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pro Tips:",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...rule.tips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showDetail = false;
            });
          },
          child: const Text("Got it!"),
        ),
      ],
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentRule > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          else
            const SizedBox(width: 48),
          Text(
            "${_currentRule + 1}/${rules.length}",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_currentRule < rules.length - 1)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          else
            SizedBox(
              width: 130, // Fixed width for the button
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final updatedUser =
                              await _authRepository.updateProfileLocally(
                            currency: widget.currencyCode,
                            age: widget.age,
                            occupation: widget.occupation,
                            monthlyIncome: widget.monthlyIncome,
                          );

                          if (!mounted) return;

                          if (updatedUser != null) {
                            final apiUrl = dotenv.env['API_URL'] ?? '';
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => ExpenseBloc(),
                                    ),
                                    BlocProvider(
                                      create: (context) => GroupBloc(
                                        repository: GroupRepository(
                                          dio: Dio(),
                                          apiUrl: apiUrl,
                                        ),
                                        apiUrl: apiUrl,
                                      ),
                                    ),
                                  ],
                                  child: const HomeScreen(),
                                ),
                              ),
                            );
                          } else {
                            // Show error snackbar
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update profile'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: Text(
                        "Get Started",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class FinanceRule {
  final String title;
  final String description;
  final String icon;
  final List<String> tips;

  FinanceRule({
    required this.title,
    required this.description,
    required this.icon,
    required this.tips,
  });
}
