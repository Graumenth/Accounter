class Company {
  final int? id;
  final String name;
  final String color;

  Company({
    this.id,
    required this.name,
    this.color = '#2563EB',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      color: map['color'] ?? '#2563EB',
    );
  }
}