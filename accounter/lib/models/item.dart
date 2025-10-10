class Item {
  final int? id;
  final String name;
  final int basePriceCents;
  final String color;

  Item({
    this.id,
    required this.name,
    required this.basePriceCents,
    this.color = '#38A169',
  });

  double get basePriceTL => basePriceCents / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_price_cents': basePriceCents,
      'color': color,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      basePriceCents: map['base_price_cents'],
      color: map['color'] ?? '#38A169',
    );
  }
}