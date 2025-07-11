// lib/services/exchange_rate_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  final String _apiKey = 'ac6caf3543f5d62ea0c59971'; 
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6/';

  Future<double?> fetchExchangeRate(String targetCurrency) async {
    try {
      if (_apiKey == 'YOUR_API_KEY' || _apiKey.isEmpty) {
        print('ExchangeRateService: API Key belum diatur. Harap daftar di exchangerate-api.com untuk mendapatkan kunci API.');
        return null;
      }

      final response = await http.get(Uri.parse('$_baseUrl$_apiKey/latest/IDR')); 
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
       
        if (data['result'] == 'success') { 
          if (data.containsKey('conversion_rates') && data['conversion_rates'].containsKey(targetCurrency)) { 
            return (data['conversion_rates'][targetCurrency] as num).toDouble();
          } else {
            print('ExchangeRateService: Kurs mata uang target "$targetCurrency" tidak ditemukan.');
            return null;
          }
        } else {
          print('ExchangeRateService: API Error - ${data['error-type']}'); 
          return null;
        }
      } else {
        print('ExchangeRateService: Gagal memuat kurs mata uang. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('ExchangeRateService: Error fetching exchange rate: $e');
      return null;
    }
  }
}
