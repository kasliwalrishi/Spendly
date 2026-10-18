import 'package:country_picker/country_picker.dart';
import 'package:fingenie/core/config/theme/app_colors.dart';
import 'package:fingenie/presentation/onboarding/screens/info/finance_rules.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

const Map<String, String> countryCurrencyMap = {
  'AF': '؋', // Afghanistan - Afghan Afghani
  'AL': 'L', // Albania - Albanian Lek
  'DZ': 'دج', // Algeria - Algerian Dinar
  'AD': '€', // Andorra - Euro
  'AO': 'Kz', // Angola - Angolan Kwanza
  'AR': '\$', // Argentina - Argentine Peso
  'AM': '֏', // Armenia - Armenian Dram
  'AU': '\$', // Australia - Australian Dollar
  'AT': '€', // Austria - Euro
  'AZ': '₼', // Azerbaijan - Azerbaijani Manat
  'BH': '.د.ب', // Bahrain - Bahraini Dinar
  'BD': '৳', // Bangladesh - Bangladeshi Taka
  'BY': 'Br', // Belarus - Belarusian Ruble
  'BE': '€', // Belgium - Euro
  'BT': 'Nu.', // Bhutan - Bhutanese Ngultrum
  'BO': 'Bs.', // Bolivia - Bolivian Boliviano
  'BA': 'KM', // Bosnia and Herzegovina - Convertible Mark
  'BR': 'R', // Brazil - Brazilian Real
  'BG': 'лв', // Bulgaria - Bulgarian Lev
  'CA': '\$', // Canada - Canadian Dollar
  'CL': '\$', // Chile - Chilean Peso
  'CN': '¥', // China - Chinese Yuan
  'CO': '\$', // Colombia - Colombian Peso
  'CR': '₡', // Costa Rica - Costa Rican Colón
  'HR': '€', // Croatia - Euro
  'CU': '₱', // Cuba - Cuban Peso
  'CZ': 'Kč', // Czech Republic - Czech Koruna
  'DK': 'kr', // Denmark - Danish Krone
  'EG': '£', // Egypt - Egyptian Pound
  'EU': '€', // European Union - Euro
  'FI': '€', // Finland - Euro
  'FR': '€', // France - Euro
  'DE': '€', // Germany - Euro
  'GR': '€', // Greece - Euro
  'HK': 'HK', // Hong Kong - Hong Kong Dollar
  'HU': 'Ft', // Hungary - Hungarian Forint
  'IS': 'kr', // Iceland - Icelandic Króna
  'IN': '₹', // India - Indian Rupee
  'ID': 'Rp', // Indonesia - Indonesian Rupiah
  'IR': '﷼', // Iran - Iranian Rial
  'IQ': 'ع.د', // Iraq - Iraqi Dinar
  'IE': '€', // Ireland - Euro
  'IL': '₪', // Israel - Israeli New Shekel
  'IT': '€', // Italy - Euro
  'JP': '¥', // Japan - Japanese Yen
  'JO': 'د.ا', // Jordan - Jordanian Dinar
  'KZ': '₸', // Kazakhstan - Kazakhstani Tenge
  'KE': 'KSh', // Kenya - Kenyan Shilling
  'KR': '₩', // South Korea - South Korean Won
  'KW': 'د.ك', // Kuwait - Kuwaiti Dinar
  'LB': 'ل.ل', // Lebanon - Lebanese Pound
  'MY': 'RM', // Malaysia - Malaysian Ringgit
  'MX': '\$', // Mexico - Mexican Peso
  'MA': 'د.م.', // Morocco - Moroccan Dirham
  'NP': 'रू', // Nepal - Nepalese Rupee
  'NL': '€', // Netherlands - Euro
  'NZ': '\$', // New Zealand - New Zealand Dollar
  'NG': '₦', // Nigeria - Nigerian Naira
  'NO': 'kr', // Norway - Norwegian Krone
  'PK': '₨', // Pakistan - Pakistani Rupee
  'PE': 'S/', // Peru - Peruvian Sol
  'PH': '₱', // Philippines - Philippine Peso
  'PL': 'zł', // Poland - Polish Złoty
  'PT': '€', // Portugal - Euro
  'QA': 'ر.ق', // Qatar - Qatari Riyal
  'RO': 'lei', // Romania - Romanian Leu
  'RU': '₽', // Russia - Russian Ruble
  'SA': 'ر.س', // Saudi Arabia - Saudi Riyal
  'RS': 'дин.', // Serbia - Serbian Dinar
  'SG': 'S\$', // Singapore - Singapore Dollar
  'ZA': 'R', // South Africa - South African Rand
  'ES': '€', // Spain - Euro
  'LK': 'Rs', // Sri Lanka - Sri Lankan Rupee
  'SE': 'kr', // Sweden - Swedish Krona
  'CH': 'CHF', // Switzerland - Swiss Franc
  'TH': '฿', // Thailand - Thai Baht
  'TR': '₺', // Turkey - Turkish Lira
  'UA': '₴', // Ukraine - Ukrainian Hryvnia
  'AE': 'د.إ', // United Arab Emirates - UAE Dirham
  'GB': '£', // United Kingdom - British Pound Sterling
  'US': '\$', // United States - US Dollar
  'VN': '₫', // Vietnam - Vietnamese Đồng
  'YE': '﷼', // Yemen - Yemeni Rial
};

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCountry;
  String? _selectedCurrency;
  // Form controllers
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();

  // State variables
  double _progress = 0.2;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page! < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _progress += 0.2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBasicInfoScreen(),
                      _buildIncomeScreen(),
                    ],
                  ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                Colors.green,
                Colors.blue,
                Colors.pink
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's Get Started!",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 32),
            Align(
                alignment: Alignment.center,
                child:
                    Lottie.asset('assets/onboarding/form.json', height: 200)),
            const SizedBox(height: 32),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                  text: _selectedCountry), // Add this line
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
                suffixIcon: Icon(Icons.arrow_drop_down),
                hintText: 'Select your country',
              ),
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  countryListTheme: CountryListThemeData(
                    borderRadius: BorderRadius.circular(8),
                    inputDecoration: InputDecoration(
                      hintText: 'Search country',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onSelect: (Country country) {
                    final currencySymbol =
                        countryCurrencyMap[country.countryCode] ??
                            country.countryCode;
                    setState(() {
                      _selectedCountry = '${country.name} ($currencySymbol)';
                      _selectedCurrency = currencySymbol;
                    });
                  },
                );
              },
              validator: (value) => _selectedCountry == null
                  ? 'Please select your country'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your age' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                prefixIcon: Icon(Icons.work_outline),
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter your occupation'
                  : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _nextPage();
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The Magic of 50-30-20",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 24),
          Align(
              alignment: Alignment.center,
              child: Lottie.asset('assets/onboarding/chart.json', height: 200)),
          const SizedBox(height: 24),
          Text(
            "The 50-30-20 rule helps you budget smarter: 50% for needs, 30% for wants, and 20% for savings and investments.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Income',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _selectedCurrency ?? '₹',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 12, left: 12),
            ),
            onChanged: (value) {
              setState(() {
                // Update calculations
              });
            },
          ),
          const SizedBox(height: 32),
          if (_incomeController.text.isNotEmpty) ...[
            _buildBudgetBreakdown(),
            const SizedBox(height: 32),
          ],
          ElevatedButton(
            onPressed: () {
              _confettiController.play();
              // Navigate to main app
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FinanceRulesScreen(
                            currencyCode: _selectedCurrency ?? 'INR',
                            monthlyIncome: _incomeController.text.isNotEmpty
                                ? double.tryParse(_incomeController.text) ?? 0
                                : 0,
                            age: int.parse(_ageController.text),
                            occupation: _occupationController.text,
                          )));
            },
            child: const Text('Complete Setup'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBreakdown() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Monthly Budget Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildBudgetItem('Needs (50%)', income * 0.5, AppColors.primary),
        _buildBudgetItem('Wants (30%)', income * 0.3, AppColors.secondary),
        _buildBudgetItem('Savings (20%)', income * 0.2, AppColors.error),
      ],
    );
  }

  Widget _buildBudgetItem(String title, double amount, Color color) {
    final currencySymbol = _selectedCurrency ?? '₹';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            '$currencySymbol${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
