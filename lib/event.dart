class Event {
  final String name;
  final String location;
  final DateTime? date;
  final String notes;
  final List<Guest> guests;
  final List<EventTask> tasks;
  final List<EventExpense> expenses;

  Event({
    required this.name,
    required this.location,
    this.date,
    required this.notes,
    required this.guests,
    required this.tasks,
    required this.expenses,
  });

  Event copyWith({
    String? name,
    String? location,
    DateTime? date,
    String? notes,
    List<Guest>? guests,
    List<EventTask>? tasks,
    List<EventExpense>? expenses,
  }) {
    return Event(
      name: name ?? this.name,
      location: location ?? this.location,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      guests: guests ?? this.guests,
      tasks: tasks ?? this.tasks,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'date': date?.toIso8601String(),
      'notes': notes,
      'guests': guests.map((guest) => guest.toJson()).toList(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      location: json['location'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      notes: json['notes'],
      guests: List<Guest>.from(json['guests'].map((item) => Guest.fromJson(item))),
      tasks: List<EventTask>.from(json['tasks'].map((item) => EventTask.fromJson(item))),
      expenses: List<EventExpense>.from(json['expenses'].map((item) => EventExpense.fromJson(item))),
    );
  }
}

class Guest {
  String name;
  bool isAttending;

  Guest({
    required this.name,
    this.isAttending = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isAttending': isAttending,
    };
  }

  static Guest fromJson(Map<String, dynamic> json) {
    return Guest(
      name: json['name'],
      isAttending: json['isAttending'],
    );
  }
}

class EventTask {
  String name;
  bool isCompleted;

  EventTask({
    required this.name,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  static EventTask fromJson(Map<String, dynamic> json) {
    return EventTask(
      name: json['name'],
      isCompleted: json['isCompleted'],
    );
  }
}

class EventExpense {
  String category;
  double amount;
  DateTime date;

  EventExpense({
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static EventExpense fromJson(Map<String, dynamic> json) {
    return EventExpense(
      category: json['category'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}
