class CompanyItemPrice {
  final int? id;
  final int companyId;
  final int itemId;
  final int customPriceCents;

  CompanyItemPrice({
    this.id,
    required this.companyId,
    required this.itemId,
    required this.customPriceCents,
  });

  double get customPriceTL => customPriceCents / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'item_id': itemId,
      'custom_price_cents': customPriceCents,
    };
  }

  factory CompanyItemPrice.fromMap(Map<String, dynamic> map) {
    return CompanyItemPrice(
      id: map['id'],
      companyId: map['company_id'],
      itemId: map['item_id'],
      customPriceCents: map['custom_price_cents'],
    );
  }
}