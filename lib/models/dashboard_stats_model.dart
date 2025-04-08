class DashboardStats {
  final Overview overview;
  final Financial financial;

  DashboardStats({
    required this.overview,
    required this.financial,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      overview: Overview.fromJson(json['overview']),
      financial: Financial.fromJson(json['financial']),
    );
  }
}

class Overview {
  final int totalProprietaires;
  final int totalAppartements;
  final int totalCharges;
  final int totalPayments;

  Overview({
    required this.totalProprietaires,
    required this.totalAppartements,
    required this.totalCharges,
    required this.totalPayments,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      totalProprietaires: json['totalProprietaires'],
      totalAppartements: json['totalAppartements'],
      totalCharges: json['totalCharges'],
      totalPayments: json['totalPayments'],
    );
  }
}

class Financial {
  final int totalPaymentsAmount;
  final int pendingPayments;
  final int unpaidCharges;

  Financial({
    required this.totalPaymentsAmount,
    required this.pendingPayments,
    required this.unpaidCharges,
  });

  factory Financial.fromJson(Map<String, dynamic> json) {
    return Financial(
      totalPaymentsAmount: json['totalPaymentsAmount'],
      pendingPayments: json['pendingPayments'],
      unpaidCharges: json['unpaidCharges'],
    );
  }
}
