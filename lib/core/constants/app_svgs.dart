class AppSvgs {
  // SVG Header & Footers can be prepended or icons can be loaded directly with flutter_svg.

  /// Minimal icon representing total Net Worth: an ascending trend graph ending with a prominent peak
  static const String netWorth = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 21h18M3 18l6-6 4 4 8-8" />
  <circle cx="21" cy="8" r="1" fill="currentColor" />
</svg>
''';

  /// Minimal icon representing Assets: a secure vault safe
  static const String assets = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="3" width="18" height="18" rx="4" />
  <circle cx="12" cy="12" r="3.5" />
  <path d="M12 9.5v1m0 3v1M9.5 12h1m3 0h1" />
</svg>
''';

  /// Minimal icon representing Liabilities: a credit card balance with deduction indications
  static const String liabilities = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="5" width="20" height="14" rx="3" />
  <path d="M2 10h20M6 14h4M14 14h4" />
</svg>
''';

  /// Minimal icon representing Investments: a combination of growing bars and rising arrow line
  static const String investments = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M18 3v4h-4M6 21v-6h4M12 21v-10h4M18 21v-14" />
  <path d="M3 21l6-6 6-4 6-8" />
</svg>
''';

  /// Minimal icon representing Receivables: a secure incoming transfer box
  static const String receivables = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 12H5M10 6l-6 6 6 6" />
  <rect x="16" y="5" width="5" height="14" rx="1.5" />
</svg>
''';

  /// Minimal icon representing Expected Income: a calendar showing schedule and pending state
  static const String expectedIncome = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="4" width="18" height="16" rx="3" />
  <path d="M16 2v4M8 2v4M3 10h18M12 14h.01M8 14h.01M16 14h.01M12 17h.01M8 17h.01M16 17h.01" />
</svg>
''';

  /// Minimal icon representing Goals: a high-precision bullseye targeting system
  static const String goals = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9" />
  <circle cx="12" cy="12" r="5" />
  <circle cx="12" cy="12" r="1.5" fill="currentColor" />
</svg>
''';

  /// Minimal icon representing Reports: a clean document sheet with summary lines
  static const String reports = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
  <polyline points="14 2 14 8 20 8" />
  <line x1="16" y1="13" x2="8" y2="13" />
  <line x1="16" y1="17" x2="8" y2="17" />
  <polyline points="10 9 9 9 8 9" />
</svg>
''';

  /// Minimal icon representing Definitions: an open dictionary book
  static const String definitions = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
  <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
</svg>
''';

  /// Minimal icon representing Backup: a secure cloud export system
  static const String backup = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
  <polyline points="17 8 12 3 7 8" />
  <line x1="12" y1="3" x2="12" y2="15" />
</svg>
''';
}
