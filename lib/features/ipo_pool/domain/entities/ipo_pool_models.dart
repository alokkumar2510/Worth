import 'dart:math';
import 'package:collection/collection.dart';

class IpoContributor {
  final String id;
  final String name;
  final double contribution;
  final String phone;
  final String notes;
  final double amountReceived; // Paid back to contributor
  final String upiId; // UPI ID for payments
  final DateTime? createdAt;
  final String? fundingSource;
  final String? fundingLiabilityId;
  final String? fundingDetails;

  IpoContributor({
    required this.id,
    required this.name,
    required this.contribution,
    required this.phone,
    required this.notes,
    this.amountReceived = 0.0,
    this.upiId = '',
    this.createdAt,
    this.fundingSource,
    this.fundingLiabilityId,
    this.fundingDetails,
  });

  IpoContributor copyWith({
    String? id,
    String? name,
    double? contribution,
    String? phone,
    String? notes,
    double? amountReceived,
    String? upiId,
    DateTime? createdAt,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) {
    return IpoContributor(
      id: id ?? this.id,
      name: name ?? this.name,
      contribution: contribution ?? this.contribution,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      amountReceived: amountReceived ?? this.amountReceived,
      upiId: upiId ?? this.upiId,
      createdAt: createdAt ?? this.createdAt,
      fundingSource: fundingSource ?? this.fundingSource,
      fundingLiabilityId: fundingLiabilityId ?? this.fundingLiabilityId,
      fundingDetails: fundingDetails ?? this.fundingDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contribution': contribution,
      'phone': phone,
      'notes': notes,
      'amountReceived': amountReceived,
      'upiId': upiId,
      'createdAt': createdAt?.toIso8601String(),
      'fundingSource': fundingSource,
      'fundingLiabilityId': fundingLiabilityId,
      'fundingDetails': fundingDetails,
    };
  }

  factory IpoContributor.fromJson(Map<String, dynamic> json) {
    return IpoContributor(
      id: json['id'] as String,
      name: json['name'] as String,
      contribution: (json['contribution'] as num).toDouble(),
      phone: json['phone'] as String,
      notes: json['notes'] as String,
      amountReceived: (json['amountReceived'] as num?)?.toDouble() ?? 0.0,
      upiId: json['upiId'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      fundingSource: json['fundingSource'] as String?,
      fundingLiabilityId: json['fundingLiabilityId'] as String?,
      fundingDetails: json['fundingDetails'] as String?,
    );
  }
}

class IpoAllotment {
  final String id;
  final String status; // 'Applied', 'Allotted', 'Rejected'
  final int lotsReceived;
  final int sharesReceived;

  IpoAllotment({
    required this.id,
    this.status = 'Applied',
    this.lotsReceived = 0,
    this.sharesReceived = 0,
  });

  IpoAllotment copyWith({
    String? id,
    String? status,
    int? lotsReceived,
    int? sharesReceived,
  }) {
    return IpoAllotment(
      id: id ?? this.id,
      status: status ?? this.status,
      lotsReceived: lotsReceived ?? this.lotsReceived,
      sharesReceived: sharesReceived ?? this.sharesReceived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'lotsReceived': lotsReceived,
      'sharesReceived': sharesReceived,
    };
  }

  factory IpoAllotment.fromJson(Map<String, dynamic> json) {
    return IpoAllotment(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'Applied',
      lotsReceived: json['lotsReceived'] as int? ?? 0,
      sharesReceived: json['sharesReceived'] as int? ?? 0,
    );
  }
}

class PaymentVerification {
  final String id;
  final String contributorId;
  final String contributorName;
  final double expectedAmount;
  final double receivedAmount;
  final String status; // 'Pending', 'Verified', 'Rejected', 'Partial'
  final String paymentMethod; // 'UPI', 'Bank Transfer', 'Cash'
  final String transactionRef;
  final String upiRef;
  final String screenshot;
  final DateTime? verificationDate;
  final String verifiedBy;

  PaymentVerification({
    required this.id,
    required this.contributorId,
    required this.contributorName,
    required this.expectedAmount,
    this.receivedAmount = 0.0,
    this.status = 'Pending',
    this.paymentMethod = 'UPI',
    this.transactionRef = '',
    this.upiRef = '',
    this.screenshot = '',
    this.verificationDate,
    this.verifiedBy = '',
  });

  PaymentVerification copyWith({
    String? id,
    String? contributorId,
    String? contributorName,
    double? expectedAmount,
    double? receivedAmount,
    String? status,
    String? paymentMethod,
    String? transactionRef,
    String? upiRef,
    String? screenshot,
    DateTime? Function()? verificationDate,
    String? verifiedBy,
  }) {
    return PaymentVerification(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionRef: transactionRef ?? this.transactionRef,
      upiRef: upiRef ?? this.upiRef,
      screenshot: screenshot ?? this.screenshot,
      verificationDate: verificationDate != null ? verificationDate() : this.verificationDate,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contributorId': contributorId,
      'contributorName': contributorName,
      'expectedAmount': expectedAmount,
      'receivedAmount': receivedAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionRef': transactionRef,
      'upiRef': upiRef,
      'screenshot': screenshot,
      'verificationDate': verificationDate?.toIso8601String(),
      'verifiedBy': verifiedBy,
    };
  }

  factory PaymentVerification.fromJson(Map<String, dynamic> json) {
    return PaymentVerification(
      id: json['id'] as String,
      contributorId: json['contributorId'] as String,
      contributorName: json['contributorName'] as String? ?? '',
      expectedAmount: (json['expectedAmount'] as num).toDouble(),
      receivedAmount: (json['receivedAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      transactionRef: json['transactionRef'] as String? ?? '',
      upiRef: json['upiRef'] as String? ?? '',
      screenshot: json['screenshot'] as String? ?? '',
      verificationDate: json['verificationDate'] != null ? DateTime.parse(json['verificationDate'] as String) : null,
      verifiedBy: json['verifiedBy'] as String? ?? '',
    );
  }
}

class SettlementRecord {
  final String id;
  final String contributorId;
  final String contributorName;
  final double amount;
  final String method; // 'UPI', 'Bank Transfer', 'Cash'
  final String transactionId;
  final String referenceNumber;
  final String notes;
  final DateTime date;

  SettlementRecord({
    required this.id,
    required this.contributorId,
    required this.contributorName,
    required this.amount,
    this.method = 'UPI',
    this.transactionId = '',
    this.referenceNumber = '',
    this.notes = '',
    required this.date,
  });

  SettlementRecord copyWith({
    String? id,
    String? contributorId,
    String? contributorName,
    double? amount,
    String? method,
    String? transactionId,
    String? referenceNumber,
    String? notes,
    DateTime? date,
  }) {
    return SettlementRecord(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contributorId': contributorId,
      'contributorName': contributorName,
      'amount': amount,
      'method': method,
      'transactionId': transactionId,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }

  factory SettlementRecord.fromJson(Map<String, dynamic> json) {
    return SettlementRecord(
      id: json['id'] as String,
      contributorId: json['contributorId'] as String,
      contributorName: json['contributorName'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String? ?? 'UPI',
      transactionId: json['transactionId'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class IpoPool {
  final String id;
  final String name;
  final double applicationCost;
  final double issuePrice;
  final int lotSize;
  final int sharesPerLot;
  final int soloApplications;
  final double? listingPrice;
  final List<IpoContributor> contributors;
  final List<IpoAllotment> allotments;
  final DateTime createdAt;
  final DateTime? deletedAt;

  // New ledger/archive fields
  final String companyName;
  final String status; // 'Upcoming', 'Open', 'Closed', 'Listed', 'Archived'
  final String settlementStatus; // 'Pending', 'Settled', 'Partially Settled'

  // Communications & Audit trail
  final List<PoolNote> notes;
  final List<PoolActivity> activities;

  // Verification & Payout centers
  final List<PaymentVerification> verifications;
  final List<SettlementRecord> settlements;

  final String? fundingSource;
  final String? fundingLiabilityId;
  final String? fundingDetails;

  IpoPool({
    required this.id,
    required this.name,
    required this.applicationCost,
    required this.issuePrice,
    required this.lotSize,
    required this.sharesPerLot,
    this.soloApplications = 0,
    this.listingPrice,
    required this.contributors,
    required this.allotments,
    required this.createdAt,
    this.companyName = '',
    this.status = 'Open',
    this.settlementStatus = 'Pending',
    this.notes = const [],
    this.activities = const [],
    this.verifications = const [],
    this.settlements = const [],
    this.deletedAt,
    this.fundingSource,
    this.fundingLiabilityId,
    this.fundingDetails,
  });

  // Verification Helpers
  double getContributorVerifiedContribution(String contributorId) {
    final verification = verifications.firstWhereOrNull((v) => v.contributorId == contributorId);
    if (verification == null) {
      // Compatibility fallback: default to expected contribution
      final c = contributors.firstWhereOrNull((contrib) => contrib.id == contributorId);
      return c?.contribution ?? 0.0;
    }
    if (verification.status == 'Verified') {
      final c = contributors.firstWhereOrNull((contrib) => contrib.id == contributorId);
      return c?.contribution ?? 0.0;
    } else if (verification.status == 'Partial') {
      return verification.receivedAmount;
    }
    return 0.0;
  }

  String getContributorVerificationStatus(String contributorId) {
    final verification = verifications.firstWhereOrNull((v) => v.contributorId == contributorId);
    return verification?.status ?? 'Verified'; // Compatibility fallback
  }

  double getContributorTotalSettled(String contributorId) {
    return settlements
        .where((s) => s.contributorId == contributorId)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  // Calculations (Updated to respect verification rules)
  double get totalPoolAmount {
    return totalGroupContribution;
  }

  int get fullApplications {
    if (applicationCost <= 0) return 0;
    return totalPoolAmount ~/ applicationCost;
  }

  double get totalApplications {
    if (applicationCost <= 0) return 0.0;
    return totalPoolAmount / applicationCost;
  }

  double get remainingAmount {
    if (applicationCost <= 0) return 0.0;
    return totalPoolAmount % applicationCost;
  }

  double get groupApplications {
    return max(0.0, totalApplications - soloApplications);
  }

  double get totalGroupContribution {
    return contributors.fold(0.0, (sum, c) => sum + getContributorVerifiedContribution(c.id));
  }

  double get gainPerShare {
    if (listingPrice == null) return 0.0;
    return listingPrice! - issuePrice;
  }

  int get soloSharesReceived {
    int sum = 0;
    for (int i = 0; i < min(soloApplications, allotments.length); i++) {
      final all = allotments[i];
      if (all.status == 'Allotted') {
        sum += all.sharesReceived;
      }
    }
    return sum;
  }

  int get groupSharesReceived {
    int sum = 0;
    for (int i = soloApplications; i < allotments.length; i++) {
      final all = allotments[i];
      if (all.status == 'Allotted') {
        sum += all.sharesReceived;
      }
    }
    return sum;
  }

  double get soloProfit {
    return gainPerShare * soloSharesReceived;
  }

  double get groupProfit {
    return gainPerShare * groupSharesReceived;
  }

  double get totalProfit {
    return soloProfit + groupProfit;
  }

  // Get list of actual allotments generated/aligned with the applications count
  List<IpoAllotment> get alignedAllotments {
    final targetLength = fullApplications;
    if (allotments.length == targetLength) {
      return allotments;
    }
    final List<IpoAllotment> result = List.from(allotments);
    if (result.length > targetLength) {
      return result.sublist(0, targetLength);
    } else {
      while (result.length < targetLength) {
        result.add(IpoAllotment(id: 'app_${result.length + 1}'));
      }
      return result;
    }
  }

  IpoPool copyWith({
    String? id,
    String? name,
    double? applicationCost,
    double? issuePrice,
    int? lotSize,
    int? sharesPerLot,
    int? soloApplications,
    double? Function()? listingPrice, // Allow setting to null
    List<IpoContributor>? contributors,
    List<IpoAllotment>? allotments,
    DateTime? createdAt,
    String? companyName,
    String? status,
    String? settlementStatus,
    List<PoolNote>? notes,
    List<PoolActivity>? activities,
    List<PaymentVerification>? verifications,
    List<SettlementRecord>? settlements,
    DateTime? Function()? deletedAt,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) {
    return IpoPool(
      id: id ?? this.id,
      name: name ?? this.name,
      applicationCost: applicationCost ?? this.applicationCost,
      issuePrice: issuePrice ?? this.issuePrice,
      lotSize: lotSize ?? this.lotSize,
      sharesPerLot: sharesPerLot ?? this.sharesPerLot,
      soloApplications: soloApplications ?? this.soloApplications,
      listingPrice: listingPrice != null ? listingPrice() : this.listingPrice,
      contributors: contributors ?? this.contributors,
      allotments: allotments ?? this.allotments,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      verifications: verifications ?? this.verifications,
      settlements: settlements ?? this.settlements,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
      fundingSource: fundingSource ?? this.fundingSource,
      fundingLiabilityId: fundingLiabilityId ?? this.fundingLiabilityId,
      fundingDetails: fundingDetails ?? this.fundingDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'applicationCost': applicationCost,
      'issuePrice': issuePrice,
      'lotSize': lotSize,
      'sharesPerLot': sharesPerLot,
      'soloApplications': soloApplications,
      'listingPrice': listingPrice,
      'contributors': contributors.map((c) => c.toJson()).toList(),
      'allotments': allotments.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'companyName': companyName,
      'status': status,
      'settlementStatus': settlementStatus,
      'notes': notes.map((n) => n.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'verifications': verifications.map((v) => v.toJson()).toList(),
      'settlements': settlements.map((s) => s.toJson()).toList(),
      'deletedAt': deletedAt?.toIso8601String(),
      'fundingSource': fundingSource,
      'fundingLiabilityId': fundingLiabilityId,
      'fundingDetails': fundingDetails,
    };
  }

  factory IpoPool.fromJson(Map<String, dynamic> json) {
    return IpoPool(
      id: json['id'] as String,
      name: json['name'] as String,
      applicationCost: (json['applicationCost'] as num).toDouble(),
      issuePrice: (json['issuePrice'] as num).toDouble(),
      lotSize: json['lotSize'] as int,
      sharesPerLot: json['sharesPerLot'] as int,
      soloApplications: json['soloApplications'] as int? ?? 0,
      listingPrice: (json['listingPrice'] as num?)?.toDouble(),
      contributors: (json['contributors'] as List<dynamic>?)
              ?.map((c) => IpoContributor.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      allotments: (json['allotments'] as List<dynamic>?)
              ?.map((a) => IpoAllotment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      companyName: json['companyName'] as String? ?? '',
      status: json['status'] as String? ?? 'Open',
      settlementStatus: json['settlementStatus'] as String? ?? 'Pending',
      notes: (json['notes'] as List<dynamic>?)
              ?.map((n) => PoolNote.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => PoolActivity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      verifications: (json['verifications'] as List<dynamic>?)
              ?.map((v) => PaymentVerification.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((s) => SettlementRecord.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      fundingSource: json['fundingSource'] as String?,
      fundingLiabilityId: json['fundingLiabilityId'] as String?,
      fundingDetails: json['fundingDetails'] as String?,
    );
  }
}

class PoolNote {
  final String id;
  final String author;
  final String content;
  final String category; // 'Contribution', 'Application', 'Allotment', 'Settlement', 'General'
  final bool isPinned;
  final DateTime createdAt;
  final List<String> attachments;

  PoolNote({
    required this.id,
    required this.author,
    required this.content,
    required this.category,
    this.isPinned = false,
    required this.createdAt,
    this.attachments = const [],
  });

  PoolNote copyWith({
    String? id,
    String? author,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? createdAt,
    List<String>? attachments,
  }) {
    return PoolNote(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'category': category,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory PoolNote.fromJson(Map<String, dynamic> json) {
    return PoolNote(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      category: json['category'] as String? ?? 'General',
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class PoolActivity {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String userId;

  PoolActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.userId,
  });

  PoolActivity copyWith({
    String? id,
    String? type,
    String? description,
    DateTime? timestamp,
    String? userId,
  }) {
    return PoolActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory PoolActivity.fromJson(Map<String, dynamic> json) {
    return PoolActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String? ?? 'User',
    );
  }
}
