part of 'widgets.dart';

// Widget untuk menampilkan informasi biaya pengiriman dalam bentuk card
class CardCost extends StatefulWidget {
  final Costs cost;
  const CardCost(this.cost, {super.key});

  @override
  State<CardCost> createState() => _CardCostState();
}

class _CardCostState extends State<CardCost> {
  // Memformat angka menjadi mata uang Rupiah
  String rupiahMoneyFormatter(int? value) {
    if (value == null) return "Rp0,00";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Memformat satuan "day" menjadi "hari" pada estimasi pengiriman
  String formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    // Use regex to replace 'day' or 'days' with 'hari', handling case-insensitivity just in case
    return etd.replaceAll(RegExp(r'day(s)?', caseSensitive: false), 'hari');
  }

  // >>> FUNGSI INI HARUS ADA DI DALAM _CardCostState <<<
  void _showCostDetails() {
    // Memanggil metode statis dari utility class CostDetailBottomSheet
    CostDetailBottomSheet.show(context, widget.cost);
  }

  @override
  Widget build(BuildContext context) {
    Costs cost = widget.cost;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue[800]!),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      color: Colors.white,
      // !! Gunakan InkWell untuk memicu Bottom Sheet saat di-tap
      child: InkWell(
        onTap: _showCostDetails, // Memanggil fungsi yang baru saja kita definisikan
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          title: Text(
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w700,
            ),
            "${cost.name}: ${cost.service}",
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                "Biaya: ${rupiahMoneyFormatter(cost.cost)}",
              ),
              const SizedBox(height: 4),
              Text(
                style: TextStyle(color: Colors.green[800]),
                "Estimasi sampai: ${formatEtd(cost.etd)}",
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.local_shipping, color: Colors.blue[800]),
          ),
          // Add a chevron to indicate tappability
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        ),
      ),
    );
  }
}