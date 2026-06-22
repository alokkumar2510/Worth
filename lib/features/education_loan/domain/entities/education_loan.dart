import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ============================================================
// LOAN STATUS ENUMS
// ============================================================
enum LoanStatus { sanctioned, active, moratorium, repaying, closed, defaulted }
enum CourseStatus { ongoing, completed, dropped }
enum DocumentType { sanctionLetter, disbursementLetter, interestCertificate, repaymentSchedule, bankCommunication, other }

extension LoanStatusLabel on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.sanctioned: return 'Sanctioned';
      case LoanStatus.active: return 'Active - Study Phase';
      case LoanStatus.moratorium: return 'Moratorium Period';
      case LoanStatus.repaying: return 'Repayment Phase';
      case LoanStatus.closed: return 'Closed';
      case LoanStatus.defaulted: return 'Defaulted';
    }
  }
}

extension CourseStatusLabel on CourseStatus {
  String get label {
    switch (this) {
      case CourseStatus.ongoing: return 'Ongoing';
      case CourseStatus.completed: return 'Completed';
      case CourseStatus.dropped: return 'Dropped';
    }
  }
}

extension DocumentTypeLabel on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.sanctionLetter: return 'Sanction Letter';
      case DocumentType.disbursementLetter: return 'Disbursement Letter';
      case DocumentType.interestCertificate: return 'Interest Certificate';
      case DocumentType.repaymentSchedule: return 'Repayment Schedule';
      case DocumentType.bankCommunication: return 'Bank Communication';
      case DocumentType.other: return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.sanctionLetter: return '📄';
      case DocumentType.disbursementLetter: return '📋';
      case DocumentType.interestCertificate: return '📊';
      case DocumentType.repaymentSchedule: return '📅';
      case DocumentType.bankCommunication: return '🏦';
      case DocumentType.other: return '📁';
    }
  }
}

// ============================================================
// CORE LOAN RECORD
// ============================================================
class EducationLoan {
  final String id;
  final String lenderName;         // Bank / NBFC name
  final String courseName;
  final String institutionName;
  final double sanctionedAmount;
  final double interestRate;       // Annual % rate
  final DateTime sanctionDate;
  final DateTime? courseStartDate;
  final DateTime? courseEndDate;
  final int moratoriumMonths;      // months after course end before EMI starts
  final DateTime? emiStartDate;
  final double? expectedEmi;
  final LoanStatus status;
  final CourseStatus courseStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  EducationLoan({
    String? id,
    required this.lenderName,
    required this.courseName,
    required this.institutionName,
    required this.sanctionedAmount,
    required this.interestRate,
    required this.sanctionDate,
    this.courseStartDate,
    this.courseEndDate,
    this.moratoriumMonths = 6,
    this.emiStartDate,
    this.expectedEmi,
    this.status = LoanStatus.sanctioned,
    this.courseStatus = CourseStatus.ongoing,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculated moratorium end date
  DateTime? get moratoriumEndDate {
    if (courseEndDate == null) return null;
    return DateTime(courseEndDate!.year, courseEndDate!.month + moratoriumMonths, courseEndDate!.day);
  }

  /// Calculated EMI start date (moratorium end + 1 day or explicit)
  DateTime? get computedEmiStartDate {
    if (emiStartDate != null) return emiStartDate;
    return moratoriumEndDate?.add(const Duration(days: 1));
  }

  EducationLoan copyWith({
    String? lenderName,
    String? courseName,
    String? institutionName,
    double? sanctionedAmount,
    double? interestRate,
    DateTime? sanctionDate,
    DateTime? courseStartDate,
    DateTime? courseEndDate,
    int? moratoriumMonths,
    DateTime? emiStartDate,
    double? expectedEmi,
    LoanStatus? status,
    CourseStatus? courseStatus,
    String? notes,
  }) {
    return EducationLoan(
      id: id,
      lenderName: lenderName ?? this.lenderName,
      courseName: courseName ?? this.courseName,
      institutionName: institutionName ?? this.institutionName,
      sanctionedAmount: sanctionedAmount ?? this.sanctionedAmount,
      interestRate: interestRate ?? this.interestRate,
      sanctionDate: sanctionDate ?? this.sanctionDate,
      courseStartDate: courseStartDate ?? this.courseStartDate,
      courseEndDate: courseEndDate ?? this.courseEndDate,
      moratoriumMonths: moratoriumMonths ?? this.moratoriumMonths,
      emiStartDate: emiStartDate ?? this.emiStartDate,
      expectedEmi: expectedEmi ?? this.expectedEmi,
      status: status ?? this.status,
      courseStatus: courseStatus ?? this.courseStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lenderName': lenderName,
    'courseName': courseName,
    'institutionName': institutionName,
    'sanctionedAmount': sanctionedAmount,
    'interestRate': interestRate,
    'sanctionDate': sanctionDate.toIso8601String(),
    'courseStartDate': courseStartDate?.toIso8601String(),
    'courseEndDate': courseEndDate?.toIso8601String(),
    'moratoriumMonths': moratoriumMonths,
    'emiStartDate': emiStartDate?.toIso8601String(),
    'expectedEmi': expectedEmi,
    'status': status.name,
    'courseStatus': courseStatus.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory EducationLoan.fromJson(Map<String, dynamic> j) => EducationLoan(
    id: j['id'] as String,
    lenderName: j['lenderName'] as String,
    courseName: j['courseName'] as String,
    institutionName: j['institutionName'] as String,
    sanctionedAmount: (j['sanctionedAmount'] as num).toDouble(),
    interestRate: (j['interestRate'] as num).toDouble(),
    sanctionDate: DateTime.parse(j['sanctionDate'] as String),
    courseStartDate: j['courseStartDate'] != null ? DateTime.parse(j['courseStartDate'] as String) : null,
    courseEndDate: j['courseEndDate'] != null ? DateTime.parse(j['courseEndDate'] as String) : null,
    moratoriumMonths: (j['moratoriumMonths'] as num?)?.toInt() ?? 6,
    emiStartDate: j['emiStartDate'] != null ? DateTime.parse(j['emiStartDate'] as String) : null,
    expectedEmi: j['expectedEmi'] != null ? (j['expectedEmi'] as num).toDouble() : null,
    status: LoanStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => LoanStatus.sanctioned),
    courseStatus: CourseStatus.values.firstWhere((e) => e.name == j['courseStatus'], orElse: () => CourseStatus.ongoing),
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );
}

// ============================================================
// DISBURSEMENT
// ============================================================
class LoanDisbursement {
  final String id;
  final String loanId;
  final DateTime date;
  final String semester;
  final double amount;
  final String purpose;
  final String? notes;
  final DateTime createdAt;

  LoanDisbursement({
    String? id,
    required this.loanId,
    required this.date,
    required this.semester,
    required this.amount,
    required this.purpose,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  LoanDisbursement copyWith({
    DateTime? date,
    String? semester,
    double? amount,
    String? purpose,
    String? notes,
  }) => LoanDisbursement(
    id: id,
    loanId: loanId,
    date: date ?? this.date,
    semester: semester ?? this.semester,
    amount: amount ?? this.amount,
    purpose: purpose ?? this.purpose,
    notes: notes ?? this.notes,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'date': date.toIso8601String(),
    'semester': semester,
    'amount': amount,
    'purpose': purpose,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LoanDisbursement.fromJson(Map<String, dynamic> j) => LoanDisbursement(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    date: DateTime.parse(j['date'] as String),
    semester: j['semester'] as String,
    amount: (j['amount'] as num).toDouble(),
    purpose: j['purpose'] as String,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

// ============================================================
// INTEREST RECORD
// ============================================================
class LoanInterestRecord {
  final String id;
  final String loanId;
  final DateTime date;
  final double principalAtDate;
  final double rateAtDate;
  final int daysAccrued;
  final double interestAmount;
  final String? notes;
  final DateTime createdAt;

  LoanInterestRecord({
    String? id,
    required this.loanId,
    required this.date,
    required this.principalAtDate,
    required this.rateAtDate,
    required this.daysAccrued,
    required this.interestAmount,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'date': date.toIso8601String(),
    'principalAtDate': principalAtDate,
    'rateAtDate': rateAtDate,
    'daysAccrued': daysAccrued,
    'interestAmount': interestAmount,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LoanInterestRecord.fromJson(Map<String, dynamic> j) => LoanInterestRecord(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    date: DateTime.parse(j['date'] as String),
    principalAtDate: (j['principalAtDate'] as num).toDouble(),
    rateAtDate: (j['rateAtDate'] as num).toDouble(),
    daysAccrued: (j['daysAccrued'] as num).toInt(),
    interestAmount: (j['interestAmount'] as num).toDouble(),
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

// ============================================================
// LOAN DOCUMENT
// ============================================================
class LoanDocument {
  final String id;
  final String loanId;
  final String name;
  final DocumentType type;
  final DateTime uploadDate;
  final String? filePath;
  final String? notes;
  final DateTime createdAt;

  LoanDocument({
    String? id,
    required this.loanId,
    required this.name,
    required this.type,
    required this.uploadDate,
    this.filePath,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'name': name,
    'type': type.name,
    'uploadDate': uploadDate.toIso8601String(),
    'filePath': filePath,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LoanDocument.fromJson(Map<String, dynamic> j) => LoanDocument(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    name: j['name'] as String,
    type: DocumentType.values.firstWhere((e) => e.name == j['type'], orElse: () => DocumentType.other),
    uploadDate: DateTime.parse(j['uploadDate'] as String),
    filePath: j['filePath'] as String?,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

// ============================================================
// SEMESTER EXPENSE
// ============================================================
class SemesterExpense {
  final String id;
  final String loanId;
  final String semesterName;
  final double tuitionFees;
  final double hostelFees;
  final double booksCost;
  final double otherCosts;
  final double loanAmountUsed;
  final double selfFundedAmount;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;
  final String? notes;
  final DateTime createdAt;

  SemesterExpense({
    String? id,
    required this.loanId,
    required this.semesterName,
    this.tuitionFees = 0.0,
    this.hostelFees = 0.0,
    this.booksCost = 0.0,
    this.otherCosts = 0.0,
    this.loanAmountUsed = 0.0,
    this.selfFundedAmount = 0.0,
    this.semesterStart,
    this.semesterEnd,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  double get totalCost => tuitionFees + hostelFees + booksCost + otherCosts;

  SemesterExpense copyWith({
    String? semesterName,
    double? tuitionFees,
    double? hostelFees,
    double? booksCost,
    double? otherCosts,
    double? loanAmountUsed,
    double? selfFundedAmount,
    DateTime? semesterStart,
    DateTime? semesterEnd,
    String? notes,
  }) => SemesterExpense(
    id: id,
    loanId: loanId,
    semesterName: semesterName ?? this.semesterName,
    tuitionFees: tuitionFees ?? this.tuitionFees,
    hostelFees: hostelFees ?? this.hostelFees,
    booksCost: booksCost ?? this.booksCost,
    otherCosts: otherCosts ?? this.otherCosts,
    loanAmountUsed: loanAmountUsed ?? this.loanAmountUsed,
    selfFundedAmount: selfFundedAmount ?? this.selfFundedAmount,
    semesterStart: semesterStart ?? this.semesterStart,
    semesterEnd: semesterEnd ?? this.semesterEnd,
    notes: notes ?? this.notes,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'semesterName': semesterName,
    'tuitionFees': tuitionFees,
    'hostelFees': hostelFees,
    'booksCost': booksCost,
    'otherCosts': otherCosts,
    'loanAmountUsed': loanAmountUsed,
    'selfFundedAmount': selfFundedAmount,
    'semesterStart': semesterStart?.toIso8601String(),
    'semesterEnd': semesterEnd?.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SemesterExpense.fromJson(Map<String, dynamic> j) => SemesterExpense(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    semesterName: j['semesterName'] as String,
    tuitionFees: (j['tuitionFees'] as num?)?.toDouble() ?? 0,
    hostelFees: (j['hostelFees'] as num?)?.toDouble() ?? 0,
    booksCost: (j['booksCost'] as num?)?.toDouble() ?? 0,
    otherCosts: (j['otherCosts'] as num?)?.toDouble() ?? 0,
    loanAmountUsed: (j['loanAmountUsed'] as num?)?.toDouble() ?? 0,
    selfFundedAmount: (j['selfFundedAmount'] as num?)?.toDouble() ?? 0,
    semesterStart: j['semesterStart'] != null ? DateTime.parse(j['semesterStart'] as String) : null,
    semesterEnd: j['semesterEnd'] != null ? DateTime.parse(j['semesterEnd'] as String) : null,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

// ============================================================
// EMI SIMULATION SNAPSHOT
// ============================================================
class EmiSimulation {
  final String id;
  final String loanId;
  final DateTime savedAt;
  final double outstanding;
  final double interestRate;
  final double emiAmount;
  final DateTime closureDate;
  final double totalInterest;
  final double totalRepayment;
  final String? label;

  EmiSimulation({
    String? id,
    required this.loanId,
    required this.outstanding,
    required this.interestRate,
    required this.emiAmount,
    required this.closureDate,
    required this.totalInterest,
    required this.totalRepayment,
    this.label,
    DateTime? savedAt,
  })  : id = id ?? _uuid.v4(),
        savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'savedAt': savedAt.toIso8601String(),
    'outstanding': outstanding,
    'interestRate': interestRate,
    'emiAmount': emiAmount,
    'closureDate': closureDate.toIso8601String(),
    'totalInterest': totalInterest,
    'totalRepayment': totalRepayment,
    'label': label,
  };

  factory EmiSimulation.fromJson(Map<String, dynamic> j) => EmiSimulation(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    outstanding: (j['outstanding'] as num).toDouble(),
    interestRate: (j['interestRate'] as num).toDouble(),
    emiAmount: (j['emiAmount'] as num).toDouble(),
    closureDate: DateTime.parse(j['closureDate'] as String),
    totalInterest: (j['totalInterest'] as num).toDouble(),
    totalRepayment: (j['totalRepayment'] as num).toDouble(),
    label: j['label'] as String?,
    savedAt: DateTime.parse(j['savedAt'] as String),
  );
}

// ============================================================
// PREPAYMENT SIMULATION
// ============================================================
class PrepaymentSimulation {
  final String id;
  final String loanId;
  final DateTime savedAt;
  final double outstanding;
  final double interestRate;
  final double regularEmi;
  final double extraPayment;
  final String frequency;          // 'monthly' | 'quarterly' | 'yearly' | 'onetime'
  final DateTime baseClosureDate;  // without prepayment
  final DateTime newClosureDate;   // with prepayment
  final double interestSaved;
  final int monthsSaved;

  PrepaymentSimulation({
    String? id,
    required this.loanId,
    required this.outstanding,
    required this.interestRate,
    required this.regularEmi,
    required this.extraPayment,
    required this.frequency,
    required this.baseClosureDate,
    required this.newClosureDate,
    required this.interestSaved,
    required this.monthsSaved,
    DateTime? savedAt,
  })  : id = id ?? _uuid.v4(),
        savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'savedAt': savedAt.toIso8601String(),
    'outstanding': outstanding,
    'interestRate': interestRate,
    'regularEmi': regularEmi,
    'extraPayment': extraPayment,
    'frequency': frequency,
    'baseClosureDate': baseClosureDate.toIso8601String(),
    'newClosureDate': newClosureDate.toIso8601String(),
    'interestSaved': interestSaved,
    'monthsSaved': monthsSaved,
  };

  factory PrepaymentSimulation.fromJson(Map<String, dynamic> j) => PrepaymentSimulation(
    id: j['id'] as String,
    loanId: j['loanId'] as String,
    outstanding: (j['outstanding'] as num).toDouble(),
    interestRate: (j['interestRate'] as num).toDouble(),
    regularEmi: (j['regularEmi'] as num).toDouble(),
    extraPayment: (j['extraPayment'] as num).toDouble(),
    frequency: j['frequency'] as String,
    baseClosureDate: DateTime.parse(j['baseClosureDate'] as String),
    newClosureDate: DateTime.parse(j['newClosureDate'] as String),
    interestSaved: (j['interestSaved'] as num).toDouble(),
    monthsSaved: (j['monthsSaved'] as num).toInt(),
    savedAt: DateTime.parse(j['savedAt'] as String),
  );
}

// ============================================================
// LOAN FORECAST POINT
// ============================================================
class LoanForecastPoint {
  final String label;        // e.g. 'After Graduation', 'After 1 Year EMI'
  final DateTime date;
  final double outstanding;
  final double totalInterestAccrued;

  const LoanForecastPoint({
    required this.label,
    required this.date,
    required this.outstanding,
    required this.totalInterestAccrued,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'date': date.toIso8601String(),
    'outstanding': outstanding,
    'totalInterestAccrued': totalInterestAccrued,
  };

  factory LoanForecastPoint.fromJson(Map<String, dynamic> j) => LoanForecastPoint(
    label: j['label'] as String,
    date: DateTime.parse(j['date'] as String),
    outstanding: (j['outstanding'] as num).toDouble(),
    totalInterestAccrued: (j['totalInterestAccrued'] as num).toDouble(),
  );
}

// ============================================================
// TOP-LEVEL STATE — serialized to/from settings key
// ============================================================
class EducationLoanState {
  final EducationLoan? loan;
  final List<LoanDisbursement> disbursements;
  final List<LoanInterestRecord> interestRecords;
  final List<LoanDocument> documents;
  final List<SemesterExpense> semesterExpenses;
  final List<EmiSimulation> emiSimulations;
  final List<PrepaymentSimulation> prepaymentSimulations;

  const EducationLoanState({
    this.loan,
    this.disbursements = const [],
    this.interestRecords = const [],
    this.documents = const [],
    this.semesterExpenses = const [],
    this.emiSimulations = const [],
    this.prepaymentSimulations = const [],
  });

  /// Total amount disbursed so far
  double get totalDisbursed =>
      disbursements.fold(0.0, (sum, d) => sum + d.amount);

  /// Remaining eligible amount
  double get remainingEligible =>
      (loan?.sanctionedAmount ?? 0) - totalDisbursed;

  EducationLoanState copyWith({
    EducationLoan? loan,
    bool clearLoan = false,
    List<LoanDisbursement>? disbursements,
    List<LoanInterestRecord>? interestRecords,
    List<LoanDocument>? documents,
    List<SemesterExpense>? semesterExpenses,
    List<EmiSimulation>? emiSimulations,
    List<PrepaymentSimulation>? prepaymentSimulations,
  }) {
    return EducationLoanState(
      loan: clearLoan ? null : (loan ?? this.loan),
      disbursements: disbursements ?? this.disbursements,
      interestRecords: interestRecords ?? this.interestRecords,
      documents: documents ?? this.documents,
      semesterExpenses: semesterExpenses ?? this.semesterExpenses,
      emiSimulations: emiSimulations ?? this.emiSimulations,
      prepaymentSimulations: prepaymentSimulations ?? this.prepaymentSimulations,
    );
  }

  Map<String, dynamic> toJson() => {
    'loan': loan?.toJson(),
    'disbursements': disbursements.map((e) => e.toJson()).toList(),
    'interestRecords': interestRecords.map((e) => e.toJson()).toList(),
    'documents': documents.map((e) => e.toJson()).toList(),
    'semesterExpenses': semesterExpenses.map((e) => e.toJson()).toList(),
    'emiSimulations': emiSimulations.map((e) => e.toJson()).toList(),
    'prepaymentSimulations': prepaymentSimulations.map((e) => e.toJson()).toList(),
  };

  factory EducationLoanState.fromJson(Map<String, dynamic> j) {
    return EducationLoanState(
      loan: j['loan'] != null ? EducationLoan.fromJson(j['loan'] as Map<String, dynamic>) : null,
      disbursements: (j['disbursements'] as List<dynamic>? ?? [])
          .map((e) => LoanDisbursement.fromJson(e as Map<String, dynamic>))
          .toList(),
      interestRecords: (j['interestRecords'] as List<dynamic>? ?? [])
          .map((e) => LoanInterestRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (j['documents'] as List<dynamic>? ?? [])
          .map((e) => LoanDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      semesterExpenses: (j['semesterExpenses'] as List<dynamic>? ?? [])
          .map((e) => SemesterExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
      emiSimulations: (j['emiSimulations'] as List<dynamic>? ?? [])
          .map((e) => EmiSimulation.fromJson(e as Map<String, dynamic>))
          .toList(),
      prepaymentSimulations: (j['prepaymentSimulations'] as List<dynamic>? ?? [])
          .map((e) => PrepaymentSimulation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
