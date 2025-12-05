part of 'model.dart';

// Model to represent an international destination (Country/District/Location)
// Note: Class name should be PascalCase (InternationalDestination) but kept as is for compatibility.
class InternationalDestination extends Equatable {
  // Map 'country_id' (String in API) to 'id' (int in Dart)
  final int? id; 
  // Map 'country_name' to 'name'
  final String? name; 

  const InternationalDestination({this.id, this.name}); 

  // Factory method to create an InternationalDestination object from JSON
  factory InternationalDestination.fromJson(Map<String, dynamic> json) {
    // FIX 1: Read 'country_id' as String
    final idString = json['country_id'] as String?;
    
    // FIX 2: Safely convert String to Int using int.tryParse()
    final parsedId = idString != null ? int.tryParse(idString) : null;
    
    return InternationalDestination(
      // Assign the parsed integer ID
      id: parsedId,
      // FIX 3: Read 'country_name' as String
      name: json['country_name'] as String?,
    );
  }

  // When sending data back (e.g., to the server), it should match the API format.
  Map<String, dynamic> toJson() => {
    'country_id': id.toString(), // Convert back to string for consistency with API request
    'country_name': name,
  };

  @override
  List<Object?> get props => [id, name];
}