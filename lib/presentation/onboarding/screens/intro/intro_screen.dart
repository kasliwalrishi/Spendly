import 'package:dio/dio.dart';
import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/data/groups/group_repository.dart';
import 'package:fingenie/presentation/auth/bloc/login_bloc/login_bloc.dart';
import 'package:fingenie/presentation/auth/screens/login.dart';
import 'package:fingenie/presentation/groups/bloc/group_bloc.dart';
import 'package:fingenie/presentation/home/bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:fingenie/core/config/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
  }

  Future<void> _checkIntroStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

    if (!mounted) return;
    if (!hasSeenIntro) return;

    final apiUrl = dotenv.env['API_URL'] ?? '';
    final authRepository = AuthRepository();
    final groupRepository = GroupRepository(
      dio: Dio(),
      apiUrl: apiUrl,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<ExpenseBloc>(
              create: (context) => ExpenseBloc(),
            ),
            BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(
                authRepository: authRepository,
                dio: Dio(),
              ),
            ),
            BlocProvider<GroupBloc>(
              create: (context) => GroupBloc(
                repository: groupRepository,
                apiUrl: apiUrl,
              ),
            ),
          ],
          child: Builder(
            builder: (context) => const LoginScreen(),
          ),
        ),
      ),
    );
  }

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    if (!context.mounted) return;

    final apiUrl = dotenv.env['API_URL'] ?? '';
    final authRepository = AuthRepository();
    final groupRepository = GroupRepository(
      dio: Dio(),
      apiUrl: apiUrl,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<ExpenseBloc>(
              create: (context) => ExpenseBloc(),
            ),
            BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(
                authRepository: authRepository,
                dio: Dio(),
              ),
            ),
            BlocProvider<GroupBloc>(
              create: (context) => GroupBloc(
                repository: groupRepository,
                apiUrl: apiUrl,
              ),
            ),
          ],
          child: Builder(
            builder: (context) => const LoginScreen(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        );

    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        );

    Widget _buildImage(String assetName) {
      return Container(
        height: 300,
        margin: const EdgeInsets.only(top: 40),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(20),
        //   boxShadow: [
        //     BoxShadow(
        //       // ignore: deprecated_member_use
        //       color: Colors.black.withOpacity(0.1),
        //       blurRadius: 20,
        //       offset: const Offset(0, 10),
        //     ),
        //   ],
        // ),
        child: Lottie.asset(
          'assets/intro/$assetName',
          fit: BoxFit.contain,
        ),
      );
    }

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Smart Expense Tracking",
          body:
              "Take control of your finances with AI-powered expense tracking",
          image: _buildImage('expense_tracking.json'),
          decoration: PageDecoration(
            titleTextStyle: titleStyle ?? const TextStyle(),
            bodyTextStyle: bodyStyle ?? const TextStyle(),
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
            imagePadding: const EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Hassle-free Group Expenses",
          body: "Split bills instantly, settle up smoothly",
          image: _buildImage('2.json'),
          decoration: PageDecoration(
            titleTextStyle: titleStyle ?? const TextStyle(),
            bodyTextStyle: bodyStyle ?? const TextStyle(),
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
            imagePadding: const EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Your AI Financial Assistant",
          body: "Get personalized insights and chat with FinGenie.",
          image: _buildImage('5.json'),
          decoration: PageDecoration(
            titleTextStyle: titleStyle ?? const TextStyle(),
            bodyTextStyle: bodyStyle ?? const TextStyle(),
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
            imagePadding: const EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Bank-grade Security",
          body: "Your data is encrypted and secure.",
          image: _buildImage('security.json'),
          decoration: PageDecoration(
            titleTextStyle: titleStyle ?? const TextStyle(),
            bodyTextStyle: bodyStyle ?? const TextStyle(),
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
            imagePadding: const EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Gamified Personal Finance",
          body: "Master personal finance through interactive experiences.",
          image: _buildImage('6.json'),
          decoration: PageDecoration(
            titleTextStyle: titleStyle ?? const TextStyle(),
            bodyTextStyle: bodyStyle ?? const TextStyle(),
            bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
            imagePadding: const EdgeInsets.only(top: 40),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: Text(
        'Skip',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.primary),
      ),
      next: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'Get Started',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: AppColors.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
