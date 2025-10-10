import 'package:intl/intl.dart';

class Sale {
  final int? id;
  final int itemId;
  final int companyId;
  final int quantity;
  final double unitPrice;
  final String date;

  Sale({
    this.id,
    required this.itemId,
    required this.companyId,
    required this.quantity,
    required this.unitPrice,
    required this.date,
  });

  static String dateToString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static DateTime stringToDate(String dateString) {
    return DateTime.parse(dateString);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'company_id': companyId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      itemId: map['item_id'],
      companyId: map['company_id'],
      quantity: map['quantity'],
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      date: map['date'],
    );
  }
}