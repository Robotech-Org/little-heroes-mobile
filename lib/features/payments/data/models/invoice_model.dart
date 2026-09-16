class InvoiceModel {
  final String name; // ACC-SINV-2026-00001
  final String postingDate;
  final String dueDate;
  final double grandTotal;
  final double outstandingAmount;
  final bool isPaid;
  final String status; // Unpaid | Paid | Overdue
  final String currency;
  final String studentId;
  final String studentName;
  final String admissionId;

  InvoiceModel({
    required this.name,
    required this.postingDate,
    required this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.isPaid,
    required this.status,
    required this.currency,
    required this.studentId,
    required this.studentName,
    required this.admissionId,
  });

  bool get hasOutstanding => outstandingAmount > 0 && !isPaid;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      name: json['name']?.toString() ?? '',
      postingDate: json['posting_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble() ?? 0,
      isPaid: json['is_paid'] == true,
      status: json['status']?.toString() ?? 'Unpaid',
      currency: json['currency']?.toString() ?? 'ETB',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      admissionId: json['admission_id']?.toString() ?? '',
    );
  }
}
