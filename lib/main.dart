import 'dart:collection';
import 'dart:convert';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:currencyconverter/Currency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Currency>> readFile() async {
  String currencies = await rootBundle.loadString('assets/currencies.json');
  String countries = await rootBundle.loadString('assets/countries.json');
  String rates = await rootBundle.loadString('assets/rates.json');
  List<Currency> allCurrencies = [];

  Map<String, dynamic> rateMap = json.decode(rates);
  Map<String, dynamic> countryMap = json.decode(countries);
  Map<String, dynamic> currenciesMap = json.decode(currencies);
  String baseCurrency = rateMap['base'];
  int timestamp = rateMap['timestamp'];
  Map<String, double> allRates = {};
  rateMap['rates'].forEach((k, v) {
    allRates.putIfAbsent(k, () {
      if (v.runtimeType == int) {
        return (v as int).toDouble();
      } else
        return v;
    });
  });
  Map<String, dynamic> countriesWithCountryName = countryMap['names'];
  Map<String, dynamic> countriesWithCountryCode = countryMap['currencies'];
  Map<String, dynamic> currencyCodeWithCurrencyName =
      currenciesMap['countryCurrencies'];

  String countryCode;
  String countryName;
  String currencyCode;
  String currencyName;
  double currentRate;
  countriesWithCountryName.forEach((key, value) {
    countryCode = key;
    countryName = value;
    currencyCode = countriesWithCountryCode[countryCode];
    currentRate = allRates[currencyCode];
    currencyName = currencyCodeWithCurrencyName[currencyCode];

    Currency currency = new Currency(
        baseCurrencyCode: baseCurrency,
        countryCode: countryCode,
        countryName: countryName,
        currencyCode: currencyCode,
        rate: currentRate,
        timestamp: timestamp,
        currencyName: currencyName);

    allCurrencies.add(currency);
  });

  return allCurrencies;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Currency> allCurrencies = await readFile();
  runApp(MyApp(data: allCurrencies));
}

class MyApp extends StatelessWidget {
  final List<Currency> data;
  MyApp({this.data});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(data: data),
    );
  }
}

class CurrencyWidget extends StatefulWidget {
  CurrencyWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CurrencyState();
  }
}

class _CurrencyState extends State<CurrencyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Flag'),
      ),
      body: FutureBuilder<List<Currency>>(
          future: readFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              child: ListView(
                children: List<Widget>.generate(snapshot.data.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, snapshot.data[index]);
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                              'images/${snapshot.data[index].countryCode.toLowerCase()}.png'),
                          SizedBox(
                            width: 10,
                          ),
                          Text('${snapshot.data[index].currencyName}'),
                          Expanded(
                            child: Text(
                              '${snapshot.data[index].rate}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Currency> data;
  MyHomePage({Key key, this.data}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Currency toCurrency, fromCurrency;

  _MyHomePageState();

  @override
  void initState() {
    super.initState();
    widget.data.forEach((currency) {
      if (currency.countryCode.toLowerCase() == 'us') {
        fromCurrency = currency;
      } else if (currency.countryCode.toLowerCase() == 'pk') {
        toCurrency = currency;
      }
    });
  }

  Color fromColor = Colors.black;
  Color toColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Country'),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  fromCurrency = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return CurrencyWidget();
                      },
                    ),
                  );
                  setState(() {});
                },
                child: Row(
                  children: <Widget>[
                    Image.asset(
                        'images/${fromCurrency.countryCode.toLowerCase()}.png'),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '${fromCurrency.countryName}',
                    ),
                    Expanded(
                        child: Text('0.0',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 30,
                              color: fromColor,
                            ))),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  toCurrency = await Navigator.push(context,
                      MaterialPageRoute(builder: (build) {
                    return CurrencyWidget();
                  }));
                },
                child: Row(
                  children: <Widget>[
                    // Image.asset('images/${toCurrency.countryCode.toLowerCase()}.png'),
                    SizedBox(
                      width: 30,
                    ),
                    Text(''
                        // '${toCurrency.countryName}',
                        ),
                    Expanded(
                        child: Text('0.0',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 30,
                              color: fromColor,
                            ))),
                  ],
                ),
              ),
              Spacer(),
              VirtualKeyboard(
                  type: VirtualKeyboardType.Numeric,
                  fontSize: 30,
                  // Callback for key press event
                  onKeyPress: (key) => print(key.text)),
            ],
          ),
        ),
      ),
    );
  }
}
