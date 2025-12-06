part of 'model.dart';

class InternationalDestination extends Equatable {
  final int? id; 
  final String? name; 

  const InternationalDestination({this.id, this.name}); 

  // Factory method to create an InternationalDestination object from JSON
  factory InternationalDestination.fromJson(Map<String, dynamic> json) {
    final idString = json['country_id'] as String?;
    final parsedId = idString != null ? int.tryParse(idString) : null;
    
    return InternationalDestination(
      id: parsedId,
      name: json['country_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'country_id': id.toString(),
    'country_name': name,
  };

  @override
  List<Object?> get props => [id, name];
}