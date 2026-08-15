class SchoolClass {
  final int id;
  final String name;

  SchoolClass({
    required this.id,
    required this.name,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'],
      name: json['name'],
    );
  }
}


