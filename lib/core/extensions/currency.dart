extension CurrencySymbolConverter on String {
  String toCurrencyCode() {
    switch (this) {
      case '₹':
        return 'INR';
      case '\$':
        return 'USD';
      case '€':
        return 'EUR';
      case '£':
        return 'GBP';
      case '¥':
        return 'JPY';
      default:
        return this;
    }
  }
}
