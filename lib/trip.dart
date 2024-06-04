class PackingItem {
  String name;
  int quantity;
  String category;
  bool isPacked;

  PackingItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.isPacked = false,
  });
  
  static fromJson(item) {}
}

class ChecklistItem {
  String name;
  bool isChecked;

  ChecklistItem({
    required this.name,
    this.isChecked = false,
  });
  
  static fromJson(item) {}
}

class Trip {
  String tripName;
  String destination;
  DateTime? startDate;
  DateTime? endDate;
  String notes;
  List<PackingItem> packingList;
  List<ChecklistItem> preTripChecklist;
  List<ChecklistItem> inTripChecklist;
  List<ChecklistItem> postTripChecklist;
  List<Map<String, dynamic>> expenses;

  Trip({
    required this.tripName,
    required this.destination,
    this.startDate,
    this.endDate,
    required this.notes,
    required this.packingList,
    required this.preTripChecklist,
    required this.inTripChecklist,
    required this.postTripChecklist,
    required this.expenses,
  });

  Trip copyWith({
    String? tripName,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    List<PackingItem>? packingList,
    List<ChecklistItem>? preTripChecklist,
    List<ChecklistItem>? inTripChecklist,
    List<ChecklistItem>? postTripChecklist,
    List<Map<String, dynamic>>? expenses,
  }) {
    return Trip(
      tripName: tripName ?? this.tripName,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      packingList: packingList ?? this.packingList,
      preTripChecklist: preTripChecklist ?? this.preTripChecklist,
      inTripChecklist: inTripChecklist ?? this.inTripChecklist,
      postTripChecklist: postTripChecklist ?? this.postTripChecklist,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,
      'destination': destination,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'packingList': packingList.map((item) => item.toJson()).toList(),
      'preTripChecklist': preTripChecklist.map((item) => item.toJson()).toList(),
      'inTripChecklist': inTripChecklist.map((item) => item.toJson()).toList(),
      'postTripChecklist': postTripChecklist.map((item) => item.toJson()).toList(),
      'expenses': expenses,
    };
  }

  static Trip fromJson(Map<String, dynamic> json) {
    return Trip(
      tripName: json['tripName'],
      destination: json['destination'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      notes: json['notes'],
      packingList: List<PackingItem>.from(json['packingList'].map((item) => PackingItem.fromJson(item))),
      preTripChecklist: List<ChecklistItem>.from(json['preTripChecklist'].map((item) => ChecklistItem.fromJson(item))),
      inTripChecklist: List<ChecklistItem>.from(json['inTripChecklist'].map((item) => ChecklistItem.fromJson(item))),
      postTripChecklist: List<ChecklistItem>.from(json['postTripChecklist'].map((item) => ChecklistItem.fromJson(item))),
      expenses: List<Map<String, dynamic>>.from(json['expenses']),
    );
  }
}

extension PackingItemExtension on PackingItem {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
      'isPacked': isPacked,
    };
  }

  static PackingItem fromJson(Map<String, dynamic> json) {
    return PackingItem(
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      isPacked: json['isPacked'],
    );
  }
}

extension ChecklistItemExtension on ChecklistItem {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isChecked': isChecked,
    };
  }

  static ChecklistItem fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      name: json['name'],
      isChecked: json['isChecked'],
    );
  }
}
