import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String googleMapsApiKey =
      'AIzaSyDLnwSzgsL8IlRM4O65IELlVmehMcyKNLU';

  // Fetch Google Maps Data
  Future<Map<String, dynamic>> fetchGoogleMapsData(
    double lat,
    double lng,
  ) async {
    // Replace with actual Google Maps API logic
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&key=$googleMapsApiKey',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch Google Maps data');
    }
  }
}
