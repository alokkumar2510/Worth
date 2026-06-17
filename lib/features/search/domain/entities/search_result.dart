class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String type; // account | transaction | asset | liability | receivable | investment | goal
  final DateTime? date;
  final double? amount;

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.date,
    this.amount,
  });
}
