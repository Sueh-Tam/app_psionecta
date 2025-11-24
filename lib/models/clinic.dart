class Clinic {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}