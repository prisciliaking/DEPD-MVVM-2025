import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart';

// Repository untuk menangani logika bisnis terkait data ongkir
class HomeRepository {
  // NetworkApiServices hanya perlu 1 instance sehingga tidak perlu ganti service selama aplikasi berjalan
  final _apiServices = NetworkApiServices();

  // Mengambil daftar provinsi dari API
  Future<List<Province>> fetchProvinceList() async {
    final response = await _apiServices.getApiResponse('destination/province');

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data provinsi
    final data = response['data'];
    if (data is! List) return [];

    // Ubah setiap item (Map) menjadi object Province
    return data.map((e) => Province.fromJson(e)).toList();
  }

  // Mengambil daftar kota berdasarkan ID provinsi
  Future<List<City>> fetchCityList(var provId) async {
    final response = await _apiServices.getApiResponse(
      'destination/city/$provId',
    );

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data kota
    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => City.fromJson(e)).toList();
  }

  // Menghitung biaya pengiriman berdasarkan parameter yang diberikan
  Future<List<Costs>> checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    // Kirim request POST untuk kalkulasi ongkir
    final response = await _apiServices
        .postApiResponse('calculate/district/domestic-cost', {
          "origin": origin,
          "destination": destination,
          "weight": weight.toString(),
          "courier": courier,
        });

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data biaya pengiriman
    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }

  // --- International Methods (Updated) ---

  // Endpoint: rajaongkir.komerce.id/api/v1/destination/international-destination
  // Mengambil daftar negara tujuan internasional, dengan fixed limit/offset
  Future<List<InternationalDestination>> fetchInternationalDestinationList({
    required String search, 
  }) async {
    // FIX: Construct the full endpoint including limit=20 and offset=0, 
    // leveraging the now-fixed NetworkApiServices for URI construction.
    final endpoint = 'destination/international-destination?search=$search&limit=20&offset=0';

    final response = await _apiServices.getApiResponse(endpoint);

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse international destination data
    final data = response['data'];
    if (data is! List) return [];

    // Map raw data to the InternationalDestination model
    return data.map((e) => InternationalDestination.fromJson(e)).toList();
  }
  
  // Endpoint: rajaongkir.komerce.id/api/v1/calculate/international-cost
  // Menghitung biaya pengiriman internasional
  Future<List<Costs>> checkInternationalShipmentCost(
    String originCityId, // Domestic City ID
    String destinationCountryId, // International Country ID
    int weight,
    String courier,
  ) async {
    // Uses the international cost calculation endpoint
    final response = await _apiServices
        .postApiResponse('calculate/international-cost', {
          // Origin must be domestic city ID and destination must be country ID
          "origin": originCityId,
          "destination": destinationCountryId,
          "weight": weight.toString(),
          "courier": courier,
        });

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Uses the existing Costs model, as requested.
    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }
}
