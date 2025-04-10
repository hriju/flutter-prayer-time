import 'package:flutter/material.dart';
import 'package:prayer_time/services/location_service.dart';

class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _locationService = LocationService();
  bool _isLoading = false;
  String? _error;
  bool _useZipCode = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final location = await _locationService.getStoredLocation();
      setState(() {
        _cityController.text = location['city'] ?? '';
        _stateController.text = location['state'] ?? '';
      });
    } catch (e) {
      print('Error loading current location: $e');
    }
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? result;
      if (_useZipCode) {
        result = await _locationService.getCoordinatesFromZipCode(
          _zipCodeController.text,
        );
      } else {
        result = await _locationService.getCoordinatesFromCityState(
          _cityController.text,
          _stateController.text,
        );
      }

      if (result != null) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _error = _useZipCode
              ? 'Could not find location. Please check your ZIP code.'
              : 'Could not find location. Please check your city and state.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error setting location: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set your location to get accurate prayer times',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Toggle between ZIP Code and City/State
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Use ZIP Code'),
                  Switch(
                    value: _useZipCode,
                    onChanged: (value) {
                      setState(() {
                        _useZipCode = value;
                        // Clear the other input when switching
                        if (value) {
                          _cityController.clear();
                          _stateController.clear();
                        } else {
                          _zipCodeController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (_useZipCode) ...[
                // ZIP Code Input
                TextFormField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'ZIP Code',
                    border: OutlineInputBorder(),
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
                ),
              ] else ...[
                // City and State Input
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a state';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveLocation,
                child: Text(_useZipCode ? 'Save ZIP Code' : 'Save City & State'),
              ),
              
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
              
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
} 