part of 'widgets.dart';

// Helper Widget for detail rows in the Bottom Sheet
class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column (Nama Kurir, Layanan, etc.)
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Style.grey800, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
          // Value column (JNE, REG, etc.)
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Class that manages showing the custom bottom sheet
class CostDetailBottomSheet {
  // Utility method to format currency, copied from CardCost for modularity
  static String _rupiahMoneyFormatter(int? value) {
    if (value == null) return "Rp0,00";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Utility method to format ETA, copied from CardCost for modularity
  static String _formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    return etd.replaceAll(RegExp(r'day(s)?', caseSensitive: false), 'hari');
  }

  static void show(BuildContext context, Costs cost) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to control height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            // Use MainAxisSize.min to wrap the content vertically
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header with Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cost.name ?? 'Detail Biaya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Style.blueGrey900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),
              
              // Detail Rows using the Costs model data
              DetailRow(label: 'Nama Kurir \t:', value: cost.name ?? '-'),
              DetailRow(label: 'Kode \t: ', value: cost.code ?? '-'),
              DetailRow(label: 'Layanan \t: ', value: cost.service ?? '-'),
              
              // Description comes from the API response
              DetailRow(label: 'Deskripsi \t: ', value: cost.description ?? 'Layanan Reguler'), 

              // Cost and ETA (Formatted)
              const Divider(height: 16),
              DetailRow(
                label: 'Biaya \t: ',
                value: _rupiahMoneyFormatter(cost.cost),
              ),
              DetailRow(
                label: 'Estimasi Sampai \t: ',
                value: _formatEtd(cost.etd),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}