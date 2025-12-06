part of 'pages.dart';

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  late HomeViewModel homeViewModel;

  final weightController = TextEditingController();
  final searchController = TextEditingController();

  final List<String> courierOptions = ["jne", "pos", "tiki", "lion", "sicepat"];
  String selectedCourier = "jne";

  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  int? selectedDestinationCountryId;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    // Load Indonesian provinces (for origin) immediately
    if (homeViewModel.provinceList.status == Status.notStarted) {
      homeViewModel.getProvinceList();
    }

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text.trim();

      if (query.length >= 3) {
        setState(() {
          selectedDestinationCountryId = null;
        });
        homeViewModel.getInternationalDestinationList(search: query);
      } else if (query.length < 3 && query.isNotEmpty) {
        homeViewModel.setInternationalDestinations(
          ApiResponse.error("Masukkan minimal 3 karakter untuk mencari."),
        );
        setState(() {
          selectedDestinationCountryId = null;
        });
      } else if (query.isEmpty) {
        homeViewModel.setInternationalDestinations(ApiResponse.notStarted());
        setState(() {
          selectedDestinationCountryId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Helper widget to display either the search input or the selected country name
  Widget _buildDestinationSelector(HomeViewModel vm) {
    if (selectedDestinationCountryId != null) {
      // Find the selected country by ID for display
      final selectedCountry = vm.internationalDestinations.data?.firstWhere(
        (country) => country.id == selectedDestinationCountryId,
        orElse: () => const InternationalDestination(
          id: null,
          name: 'Negara Tidak Ditemukan',
        ),
      );

      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tujuan Terpilih: ${selectedCountry?.name ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDestinationCountryId = null;
                  searchController.clear();
                  homeViewModel.setInternationalDestinations(
                    ApiResponse.notStarted(),
                  );
                });
              },
              child: const Text('Ubah Negara'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Destination (International)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Cari negara (min 3 karakter)',
            suffixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        _buildCountryList(vm),
      ],
    );
  }

  // Helper widget to build the list of search results
  Widget _buildCountryList(HomeViewModel vm) {
    final status = vm.internationalDestinations.status;
    final countries = vm.internationalDestinations.data ?? [];

    if (status == Status.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (status == Status.error) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          vm.internationalDestinations.message ?? 'Error loading countries',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (countries.isEmpty &&
        searchController.text.length >= 3 &&
        status == Status.completed) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Tidak ada negara ditemukan.'),
      );
    }

    if (countries.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: countries
            .map(
              (d) => InkWell(
                onTap: () {
                  setState(() {
                    selectedDestinationCountryId = d.id;
                    homeViewModel.setInternationalDestinations(
                      ApiResponse.completed([d]),
                    );
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: selectedDestinationCountryId == d.id
                        ? Colors.blue.shade50
                        : Colors.white,
                  ),
                  child: Text(
                    d.name ?? '',
                    style: TextStyle(color: Style.blue800),
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Mulai ketik minimal 3 karakter untuk mencari negara..."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            // --- Logika Auto-Select Kota ---
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (selectedProvinceOriginId != null &&
                  vm.cityOriginList.status == Status.completed &&
                  selectedCityOriginId == null) {
                final cities = vm.cityOriginList.data;
                if (cities != null && cities.isNotEmpty) {
                  // Panggil setState di luar fase build (menggunakan addPostFrameCallback)
                  setState(() {
                    selectedCityOriginId = cities.first.id;
                  });
                }
              }
            });
            // --- END Logika Auto-Select Kota ---

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section for Courier and Weight
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedCourier,
                                  items: courierOptions
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.toUpperCase()),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(
                                    () => selectedCourier = v ?? "pos",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Berat (gr)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // --- Origin (Province Only) ---
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Origin (Indonesia)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              // Dropdown provinsi asal (ONLY PROVINCE SHOWN)
                              Expanded(
                                child: Consumer<HomeViewModel>(
                                  builder: (context, vm, _) {
                                    final provinces =
                                        vm.provinceList.data ?? [];
                                    if (vm.provinceList.status ==
                                        Status.loading) {
                                      return const SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (vm.provinceList.status ==
                                        Status.error) {
                                      return Text(
                                        vm.provinceList.message ?? 'Error',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      );
                                    }

                                    return DropdownButton<int>(
                                      isExpanded: true,
                                      value: selectedProvinceOriginId,
                                      hint: const Text('Pilih provinsi'),
                                      items: provinces
                                          .map(
                                            (p) => DropdownMenuItem<int>(
                                              value: p.id,
                                              child: Text(p.name ?? ''),
                                            ),
                                          )
                                          .toList(),
                                      // LOGIKA DIPINDAHKAN DI SINI
                                      onChanged: (newId) {
                                        setState(() {
                                          selectedProvinceOriginId = newId;
                                          selectedCityOriginId =
                                              null; // Reset City when Province changes
                                        });
                                        if (newId != null) {
                                          // Trigger city data load in the background
                                          vm.getCityOriginList(newId);
                                        }
                                        // Catatan: Auto-select kota terjadi pada WidgetsBinding.instance.addPostFrameCallback di atas.
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Displaying selected city name (Feedback to user)
                          if (selectedCityOriginId != null &&
                              vm.cityOriginList.data != null &&
                              vm.cityOriginList.data!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Kota Asal Otomatis: ${vm.cityOriginList.data!.firstWhere((city) => city.id == selectedCityOriginId, orElse: () => const City(name: 'N/A')).name}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // --- Destination (International Country) Selector ---
                          _buildDestinationSelector(vm),

                          const SizedBox(height: 12),

                          // Button for Calculation
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validation: Province is selected AND City ID is auto-set
                                if (selectedProvinceOriginId != null &&
                                    selectedCityOriginId != null &&
                                    selectedDestinationCountryId != null &&
                                    weightController.text.isNotEmpty) {
                                  final weight =
                                      int.tryParse(weightController.text) ?? 0;
                                  if (weight <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Berat harus lebih dari 0',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }
                                  // Call the International API function
                                  vm.checkInternationalShipmentCost(
                                    selectedCityOriginId!.toString(),
                                    selectedDestinationCountryId!.toString(),
                                    weight,
                                    selectedCourier,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Lengkapi semua field (Pilih Provinsi & Negara Tujuan)!',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Style.blue800,
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text(
                                "Hitung Ongkir Internasional",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Results Display (International) ---
                  Card(
                    color: Colors.blue[50],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer<HomeViewModel>(
                      builder: (context, vm, _) {
                        switch (vm.internationalCostList.status) {
                          case Status.loading:
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          case Status.error:
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  vm.internationalCostList.message ?? 'Error',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          case Status.completed:
                            if (vm.internationalCostList.data == null ||
                                vm.internationalCostList.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    "Tidak ada data ongkir internasional.",
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  vm.internationalCostList.data?.length ?? 0,
                              itemBuilder: (context, index) => CardCost(
                                vm.internationalCostList.data!.elementAt(index),
                              ),
                            );
                          default:
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  "Pilih provinsi dan negara tujuan, lalu hitung.",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Overlay loading
        Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
