part of 'pages.dart';

class BlankPage extends StatelessWidget {
  // Uses super.key, not Key? key
  const BlankPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: No Scaffold here
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps_rounded, // Dashboard Icon
              size: 64, 
              color: Style.blue800,
            ),
            const SizedBox(height: 16),
            const Text(
              "Hello World",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              "This is the basic home page content.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}