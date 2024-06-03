class GroceryItem {
  String name;
  bool isCompleted;
  DateTime? completedAt;
  String category;
  String notes;
  int notificationId;
  int quantity;
  String unit;

  GroceryItem({
    required this.name,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    this.notes = '',
    required this.notificationId,
    this.quantity = 1,
    this.unit = 'pcs',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
      'notes': notes,
      'notificationId': notificationId,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      name: json['name'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      category: json['category'],
      notes: json['notes'],
      notificationId: json['notificationId'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}
