import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:depd_mvvm_2025/data/app_exception.dart';
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';
import 'package:depd_mvvm_2025/shared/shared.dart';

/// Implementasi BaseApiServices untuk menangani request GET, POST ke API RajaOngkir.
class NetworkApiServices implements BaseApiServices {

  // Helper untuk memastikan tidak ada slash ganda dan slash di awal path
  String _cleanPath(String path) {
    // Menghapus slash ganda dan slash di awal path, tapi biarkan slash di dalam path
    return path.replaceAll(RegExp(r'^\/+|\/+$'), '');
  }

  /// Melakukan request GET ke endpoint
  /// Mengembalikan JSON ter-decode atau melempar AppException yang sesuai.
  @override
  Future<dynamic> getApiResponse(String endpoint) async {
    try {
      // FIX URL BUILDING: Separate path and query parameters correctly.
      final uriParts = endpoint.split('?');
      
      // Ambil path utama (subUrl) dan gabungkan dengan endpoint bersih. 
      // Hasilnya harus seperti: 'api/v1/destination/international-destination'
      final path = _cleanPath(Const.subUrl) + '/' + _cleanPath(uriParts[0]); 
      
      Map<String, dynamic> queryParameters = {};

      // Pisahkan query parameters
      if (uriParts.length > 1) {
        final queryStrings = uriParts[1].split('&');
        for (var qs in queryStrings) {
          final pair = qs.split('=');
          if (pair.length == 2) {
            // Add key/value pair to the map; Uri.https handles the final encoding.
            queryParameters[pair[0]] = pair[1];
          }
        }
      }
      
      // Gunakan Uri.https untuk konstruksi URL yang aman.
      final uri = Uri.https(Const.baseUrl, path, queryParameters);

      // Log request GET (untuk debug: URL + header).
      _logRequest('GET', uri, Const.apiKey);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
      );

      // Penanganan respons (status + decode JSON + pemetaan error).
      return _returnResponse(response);
    } on SocketException {
      // Tidak ada koneksi jaringan.
      throw NoInternetException('');
    } on TimeoutException {
      // Waktu request melewati batas timeout.
      throw FetchDataException('Network request timeout!');
    } catch (e) {
      // Error tak terduga saat runtime.
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Melakukan request POST dengan body form-url-encoded.
  @override
  Future<dynamic> postApiResponse(String endpoint, dynamic data) async {
    try {
      // Path akhir: gabungkan subUrl dan path yang bersih
      final path = _cleanPath(Const.subUrl) + '/' + _cleanPath(endpoint); 
      final uri = Uri.https(Const.baseUrl, path);

      // Log request POST termasuk payload body.
      _logRequest('POST', uri, Const.apiKey, data);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'key': Const.apiKey,
        },
        body: data,
      );

      // Delegasi parsing respons dan pemetaan error.
      return _returnResponse(response);
    } on SocketException {
      // Perangkat offline.
      throw NoInternetException('No internet connection!');
    } on TimeoutException {
      // Waktu request melewati batas timeout.
      throw FetchDataException('Network request timeout!');
    } catch (e) {
      // Fallback umum.
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Print debug metadata request (method, URL, header, body).
  void _logRequest(String method, Uri uri, String apiKey, [dynamic data]) {
    print("== $method REQUEST ==");
    // print("API Key: { key: $apiKey }");
    print("Final URL ($method): $uri");
    if (data != null) {
      print("Data body: $data");
    }
    print("");
  }

  /// Print debug detail respons (status, content-type, body).
  void _logResponse(int statusCode, String? contentType, String body) {
    print("Status code: $statusCode");
    print("Content-Type: ${contentType ?? '-'}");

    if (body.isEmpty) {
      print("Body: <empty>");
    } else {
      String formattedBody;
      try {
        final decoded = jsonDecode(body);
        const encoder = JsonEncoder.withIndent('  ');
        formattedBody = encoder.convert(decoded);
      } catch (_) {
        formattedBody = body;
      }

      const maxLen = 8000;
      if (formattedBody.length > maxLen) {
        print(
          "Body (terpotong): ${formattedBody.substring(0, maxLen)}... [${formattedBody.length - maxLen} lebih karakter]",
        );
      } else {
        print("Body: $formattedBody");
      }
    }
    print("");
  }

  /// Memetakan HTTP response menjadi JSON ter-decode atau melempar exception bertipe.
  dynamic _returnResponse(http.Response response) {
    _logResponse(
      response.statusCode,
      response.headers['content-type'],
      response.body,
    );

    switch (response.statusCode) {
      case 200:
        try {
          final decoded = jsonDecode(response.body);
          // decoded null (tidak terjadi di Dart, tapi tetap dicek).
          if (decoded == null) throw FetchDataException('Empty JSON');
          return decoded;
        } catch (_) {
          // JSON tidak bisa di-decode pada status sukses.
          throw FetchDataException('Invalid JSON');
        }

      case 400:
        // Error dari sisi client: payload/parameter salah.
        throw BadRequestException(response.body);

      case 404:
        // Resource atau endpoint tidak ditemukan.
        throw NotFoundException('Not Found: ${response.body}');

      case 500:
        // Kegagalan dari sisi server.
        throw ServerErrorException('Server error: ${response.body}');

      default:
        // Status lain yang tidak ditangani.
        throw FetchDataException(
          'Unexpected status ${response.statusCode}: ${response.body}',
        );
    }
  }
}