import 'package:flutter/material.dart';
import 'package:prayer_time/services/location_service.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  LocationSelectionPageState createState() => LocationSelectionPageState();
}

class LocationSelectionPageState extends State<LocationSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _zipController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _locationService = LocationService();
  bool _isLoading = false;
  bool _useZipCode = true;
  String? _errorMessage;
  
  // List of US states
  final List<String> _states = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
    'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
    'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
    'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
    'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
  ];

  // List of major US cities
  final List<String> _majorCities = [
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
    'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
    'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'San Francisco',
    'Charlotte', 'Indianapolis', 'Seattle', 'Denver', 'Washington',
    'Boston', 'El Paso', 'Detroit', 'Nashville', 'Portland',
    'Memphis', 'Oklahoma City', 'Las Vegas', 'Louisville', 'Baltimore',
    'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento',
    'Mesa', 'Kansas City', 'Atlanta', 'Miami', 'Omaha',
    'Raleigh', 'Colorado Springs', 'Long Beach', 'Virginia Beach', 'Oakland',
    'Minneapolis', 'Tulsa', 'Arlington', 'Tampa', 'New Orleans',
    'Wichita', 'Cleveland', 'Bakersfield', 'Aurora', 'Anaheim',
    'Honolulu', 'Santa Ana', 'Corpus Christi', 'Riverside', 'Lexington',
    'Pittsburgh', 'Anchorage', 'Stockton', 'Cincinnati', 'Saint Paul',
    'Toledo', 'Newark', 'Greensboro', 'Plano', 'Henderson',
    'Lincoln', 'Buffalo', 'Jersey City', 'Chula Vista', 'Fort Wayne',
    'Orlando', 'St. Petersburg', 'Chandler', 'Laredo', 'Norfolk',
    'Durham', 'Madison', 'Lubbock', 'Irvine', 'Winston-Salem',
    'Glendale', 'Garland', 'Hialeah', 'Reno', 'Chesapeake',
    'Gilbert', 'Baton Rouge', 'Irving', 'Scottsdale', 'North Las Vegas',
    'Fremont', 'Irvine', 'San Bernardino', 'Boise', 'Birmingham'
  ];

  @override
  void dispose() {
    _zipController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  // Filter cities based on input
  List<String> _filterCities(String query) {
    if (query.isEmpty) return [];
    return _majorCities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Filter states based on input
  List<String> _filterStates(String query) {
    if (query.isEmpty) return [];
    return _states
        .where((state) => state.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Use ZIP Code'),
                              value: true,
                              groupValue: _useZipCode,
                              onChanged: (value) {
                                setState(() {
                                  _useZipCode = value!;
                                  _errorMessage = null;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Use City & State'),
                              value: false,
                              groupValue: _useZipCode,
                              onChanged: (value) {
                                setState(() {
                                  _useZipCode = value!;
                                  _errorMessage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_useZipCode)
                TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    labelText: 'Enter ZIP Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a ZIP code';
                    }
                    if (value.length != 5) {
                      return 'Please enter a valid 5-digit ZIP code';
                    }
                    return null;
                  },
                )
              else
                Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _filterCities(textEditingValue.text);
                      },
                      displayStringForOption: (String option) => option,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Enter City',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a city';
                            }
                            return null;
                          },
                        );
                      },
                      onSelected: (String selection) {
                        _cityController.text = selection;
                      },
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _filterStates(textEditingValue.text);
                      },
                      displayStringForOption: (String option) => option,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Enter State',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.map),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a state';
                            }
                            return null;
                          },
                        );
                      },
                      onSelected: (String selection) {
                        _stateController.text = selection;
                      },
                    ),
                  ],
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Set Location',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic>? locationData;
      
      if (_useZipCode) {
        print('Attempting to fetch location for ZIP code: ${_zipController.text}');
        locationData = await _locationService.getCoordinatesFromZipCode(_zipController.text);
        if (locationData == null) {
          setState(() {
            _errorMessage = 'Could not find location for ZIP code ${_zipController.text}. Please try again or use City & State instead.';
          });
          return;
        }
      } else {
        print('Attempting to fetch location for city: ${_cityController.text}, state: ${_stateController.text}');
        locationData = await _locationService.getCoordinatesFromCityState(
          _cityController.text,
          _stateController.text,
        );
        if (locationData == null) {
          setState(() {
            _errorMessage = 'Could not find location for ${_cityController.text}, ${_stateController.text}. Please try again or use ZIP code instead.';
          });
          return;
        }
      }

      print('Successfully found location: ${locationData['city']}, ${locationData['state']}');
      
      await _locationService.storeLocation(locationData['city'], locationData['state']);
      await _locationService.storeCoordinates(
        locationData['latitude'],
        locationData['longitude'],
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      print('Error in location selection: $e');
      setState(() {
        _errorMessage = 'An error occurred while setting your location. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 