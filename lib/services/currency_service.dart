import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  Future<double> fetchDollarRate() async {
    try {
      final response = await http.get(
        Uri.parse('https://economia.awesomeapi.com.br/last/USD-BRL'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.parse(data['USDBRL']['bid']);
      } else {
        return 0.0; // Retorna zero se a API responder erro (ex: 404)
      }
    } catch (e) {
      return 0.0; // Retorna zero se não houver internet
    }
  }
}