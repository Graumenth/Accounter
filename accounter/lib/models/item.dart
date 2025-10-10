class Item {
  final int? id;
  final String name;
  final int basePriceCents;

  Item({
    this.id,
    required this.name,
    required this.basePriceCents,
  });

  double get basePriceTL => basePriceCents / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePriceCents': basePriceCents,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      basePriceCents: map['basePriceCents'],
    );
  }
}