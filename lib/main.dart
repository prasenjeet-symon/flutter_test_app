import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/search-input.dart';
import 'package:flutter_test_app/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Orbit Search Input Test',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            textTheme: const TextTheme(titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), bodyMedium: TextStyle(fontSize: 14), bodySmall: TextStyle(fontSize: 12), labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          home: const SearchTestScreen(),
        );
      },
    );
  }
}

class SearchTestScreen extends StatefulWidget {
  const SearchTestScreen({super.key});

  @override
  State<SearchTestScreen> createState() => _SearchTestScreenState();
}

class _SearchTestScreenState extends State<SearchTestScreen> {
  final TextEditingController _countryController = TextEditingController(text: 'country1');
  final TextEditingController _stateController = TextEditingController(text: 'state1');
  final TextEditingController _cityController = TextEditingController(text: 'city1');
  final OrbitFormManager _formManager = OrbitFormManager();
  String? _countryDisplay;
  String? _stateDisplay;
  String? _cityDisplay;

  // Mock search functions
  Future<List<SearchResult>> _searchCountries(String query) async {
    final mockData = [
      SearchResult(id: 'country1', title: 'United States', subtitle: 'North America', isVerified: true),
      SearchResult(id: 'country2', title: 'Canada', subtitle: 'North America', isVerified: true),
      SearchResult(id: 'country3', title: 'India', subtitle: 'Asia', isVerified: false),
    ];
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.isEmpty) return mockData;
    return mockData.where((result) => result.title.toLowerCase().contains(query.toLowerCase()) || (result.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
  }

  Future<List<SearchResult>> _searchStates(String query) async {
    final country = _formManager.get('country').value as SearchResult?;
    if (country == null) return [];
    final mockData = {
      'country1': [
        SearchResult(id: 'state1', title: 'California', subtitle: 'West Coast', isVerified: true),
        SearchResult(id: 'state2', title: 'Texas', subtitle: 'South', isVerified: false),
        SearchResult(id: 'state3', title: 'New York', subtitle: 'East Coast', isVerified: true),
      ],
      'country2': [SearchResult(id: 'state4', title: 'Ontario', subtitle: 'Central Canada', isVerified: true), SearchResult(id: 'state5', title: 'Quebec', subtitle: 'Eastern Canada', isVerified: false)],
      'country3': [SearchResult(id: 'state6', title: 'Maharashtra', subtitle: 'Western India', isVerified: true), SearchResult(id: 'state7', title: 'Karnataka', subtitle: 'Southern India', isVerified: false)],
    };
    await Future.delayed(const Duration(milliseconds: 500));
    final states = mockData[country.id] ?? [];
    if (query.isEmpty) return states;
    return states.where((result) => result.title.toLowerCase().contains(query.toLowerCase()) || (result.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
  }

  Future<List<SearchResult>> _searchCities(String query) async {
    final state = _formManager.get('state').value as SearchResult?;
    if (state == null) return [];
    final mockData = {
      'state1': [SearchResult(id: 'city1', title: 'Los Angeles', subtitle: 'CA', isVerified: true), SearchResult(id: 'city2', title: 'San Francisco', subtitle: 'CA', isVerified: true)],
      'state2': [SearchResult(id: 'city3', title: 'Houston', subtitle: 'TX', isVerified: false), SearchResult(id: 'city4', title: 'Austin', subtitle: 'TX', isVerified: true)],
      'state3': [SearchResult(id: 'city5', title: 'New York City', subtitle: 'NY', isVerified: true)],
      'state4': [SearchResult(id: 'city6', title: 'Toronto', subtitle: 'ON', isVerified: true)],
      'state5': [SearchResult(id: 'city7', title: 'Montreal', subtitle: 'QC', isVerified: false)],
      'state6': [SearchResult(id: 'city8', title: 'Mumbai', subtitle: 'MH', isVerified: true)],
      'state7': [SearchResult(id: 'city9', title: 'Bangalore', subtitle: 'KA', isVerified: true)],
    };
    await Future.delayed(const Duration(milliseconds: 500));
    final cities = mockData[state.id] ?? [];
    if (query.isEmpty) return cities;
    return cities.where((result) => result.title.toLowerCase().contains(query.toLowerCase()) || (result.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dependent Search Inputs Test')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrbitSearchInput<SearchResult>(
              orbitKey: 'country',
              orbitFormManager: _formManager,
              controller: _countryController,
              labelText: 'Select Country',
              hintText: 'Search countries...',
              validator: (value) => value == null || value.isEmpty ? 'Please select a country' : null,
              isCompact: true,
              isLocal: true,
              onSearch: (term, s) => _searchCountries(term),
              verticalMargin: 8.h,
              onFocused: () => print('Country input focused'),
              onBlur: () => print('Country input blurred'),
              onChanged: (SearchResult? result) {
                setState(() {
                  _countryDisplay = result != null ? '${result.title} (${result.subtitle ?? 'No subtitle'})' : 'No country selected';
                });
              },
            ),
            OrbitSearchInput<SearchResult>(
              orbitKey: 'state',
              orbitParentKey: 'country',
              orbitFormManager: _formManager,
              controller: _stateController,
              labelText: 'Select State',
              hintText: 'Search states...',
              validator: (value) => value == null || value.isEmpty ? 'Please select a state' : null,
              isCompact: true,
              isLocal: true,
              onSearch: (term, s) => _searchStates(term),
              verticalMargin: 8.h,
              onFocused: () => print('State input focused'),
              onBlur: () => print('State input blurred'),
              onChanged: (SearchResult? result) {
                setState(() {
                  _stateDisplay = result != null ? '${result.title} (${result.subtitle ?? 'No subtitle'})' : 'No state selected';
                });
              },
            ),
            OrbitSearchInput<SearchResult>(
              orbitKey: 'city',
              orbitParentKey: 'state',
              orbitFormManager: _formManager,
              controller: _cityController,
              labelText: 'Select City',
              hintText: 'Search cities...',
              validator: (value) => value == null || value.isEmpty ? 'Please select a city' : null,
              isCompact: true,
              isLocal: true,
              onSearch: (term, s) => _searchCities(term),
              verticalMargin: 8.h,
              onFocused: () => print('City input focused'),
              onBlur: () => print('City input blurred'),
              onChanged: (SearchResult? result) {
                setState(() {
                  _cityDisplay = result != null ? '${result.title} (${result.subtitle ?? 'No subtitle'})' : 'No city selected';
                });
              },
            ),
            SizedBox(height: 16.h),
            Text('Country: ${_countryDisplay ?? 'None'}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text('State: ${_stateDisplay ?? 'None'}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 8.h),
            Text('City: ${_cityDisplay ?? 'None'}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                setState(() {
                  _countryController.text = 'country1';
                  _stateController.text = 'state1';
                  _cityController.text = 'city1';
                  _countryDisplay = 'None';
                  _stateDisplay = 'None';
                  _cityDisplay = 'None';
                });
              },
              child: const Text('Reset Local Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
