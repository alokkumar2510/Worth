import 'package:freezed_annotation/freezed_annotation.dart';

part 'sip.freezed.dart';
part 'sip.g.dart';

@freezed
class Sip with _$Sip {
  const factory Sip({
    required String id,
    required String investmentId,
    required double amount,
    required String frequency, // monthly | weekly | quarterly
    required int sipDate, // day of month (1-31) or day of week (1-7)
    required DateTime startDate,
    DateTime? endDate,
    required int autoCreate, // 0 = No, 1 = Yes
    required int isActive, // 0 = Inactive, 1 = Active
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
    @Default('paid') String importMode, // paid | manual | today
    @Default(0) int completedInstallmentsOverride,
    DateTime? worthCreationDate,
  }) = _Sip;

  factory Sip.fromJson(Map<String, dynamic> json) => _$SipFromJson(json);
}
