
class Currency{
  String countryName, countryCurrency, currencies;
  double countryRate;
  Currency({
    this.countryName,
    this.countryCurrency,
    this.countryRate,
    this.currencies
  });
 
}
Currency currencyJson(Map<String,dynamic> map) => Currency(
  countryName: map["names"] as String,
  countryCurrency: map["currencies"] as String,
  currencies: map["countryCurrencies"] as String,
  countryRate: map["rates"] as double
);

class CurrencyList extends Currency{
  List<Currency> currency;
}