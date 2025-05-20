class Doctor {
  final String id;
  final String name;
  final String image;
  String location;
  final double rating;
  final int reviews;
  final String specialistLabel;

  Doctor({
    required this.id,
    required this.name,
    required this.image,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.specialistLabel,
  });
}
