import 'item.dart';

class PendingSale {
  final Item item;
  final int companyId;
  int quantity;

  PendingSale({
    required this.item,
    required this.companyId,
    this.quantity = 1,
  });
}