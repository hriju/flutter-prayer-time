import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationMethodPage extends StatefulWidget {
  const CalculationMethodPage({super.key});

  @override
  CalculationMethodPageState createState() => CalculationMethodPageState();
}

class CalculationMethodPageState extends State<CalculationMethodPage> {
  final List<Map<String, dynamic>> _calculationMethods = [
    {'id': 2, 'name': 'Islamic Society of North America (ISNA)'},
    {'id': 3, 'name': 'Muslim World League (MWL)'},
    {'id': 4, 'name': 'Umm al-Qura University, Makkah'},
    {'id': 5, 'name': 'Egyptian General Authority of Survey'},
    {'id': 7, 'name': 'Institute of Geophysics, University of Tehran'},
    {'id': 8, 'name': 'Gulf Region'},
    {'id': 9, 'name': 'Kuwait'},
    {'id': 10, 'name': 'Qatar'},
    {'id': 11, 'name': 'Majlis Ugama Islam Singapura, Singapore'},
    {'id': 12, 'name': 'Union Organization Islamic de France'},
    {'id': 13, 'name': 'Diyanet İşleri Başkanlığı, Turkey'},
    {'id': 14, 'name': 'Spiritual Administration of Muslims of Russia'},
  ];

  final List<Map<String, dynamic>> _juristicMethods = [
    {'id': 0, 'name': 'Shafi\'i, Maliki, Hanbali'},
    {'id': 1, 'name': 'Hanafi'},
  ];

  int? _selectedMethod;
  int? _selectedJuristicMethod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedMethods();
  }

  Future<void> _loadSelectedMethods() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMethod = prefs.getInt('calculation_method') ?? 2; // Default to ISNA
      _selectedJuristicMethod = prefs.getInt('juristic_method') ?? 0; // Default to Shafi'i
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedMethod(int methodId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calculation_method', methodId);
    setState(() {
      _selectedMethod = methodId;
    });
  }

  Future<void> _saveSelectedJuristicMethod(int methodId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('juristic_method', methodId);
    setState(() {
      _selectedJuristicMethod = methodId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Calculation Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._calculationMethods.map((method) {
                    return RadioListTile<int>(
                      title: Text(method['name']),
                      value: method['id'],
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        if (value != null) {
                          _saveSelectedMethod(value);
                        }
                      },
                    );
                  }).toList(),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Juristic Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._juristicMethods.map((method) {
                    return RadioListTile<int>(
                      title: Text(method['name']),
                      value: method['id'],
                      groupValue: _selectedJuristicMethod,
                      onChanged: (value) {
                        if (value != null) {
                          _saveSelectedJuristicMethod(value);
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
} 