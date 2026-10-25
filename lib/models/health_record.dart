/// Represents a single daily health tracking record.
///
/// In Stage 2, this model provides structured sample data for the UI.
/// In Stage 3 and 4, this model will be used with SQLite.
class HealthRecord {
  final int? id;
  final String date; // Format: YYYY-MM-DD
  final int steps;
  final int calories;
  final int water; // In millilitres (mL)

  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  /// Creates a copy of this record with optional updated values.
  /// Useful when editing an existing record.
  HealthRecord copyWith({
    int? id,
    String? date,
    int? steps,
    int? calories,
    int? water,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
    );
  }
}
