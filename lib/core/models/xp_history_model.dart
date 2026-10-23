class XpTransaction {
  final String id;
  final String sourceType;
  final String transactionType;
  final num amount;
  final String? description;
  final DateTime? createdAt;

  const XpTransaction({
    required this.id,
    required this.sourceType,
    required this.transactionType,
    required this.amount,
    this.description,
    this.createdAt,
  });

  factory XpTransaction.fromJson(Map<String, dynamic> json) => XpTransaction(
    id: json['xpTransactionId'].toString(),
    sourceType: json['sourceType'] as String? ?? '',
    transactionType: json['transactionType'] as String? ?? 'EARN',
    amount: json['xpAmount'] as num? ?? 0,
    description: json['description'] as String?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
  );
}

class XpHistoryPage {
  final List<XpTransaction> items;
  final String? nextCursor;
  const XpHistoryPage({required this.items, this.nextCursor});

  factory XpHistoryPage.fromJson(Map<String, dynamic> json) => XpHistoryPage(
    items: (json['data'] as List)
        .map(
          (item) =>
              XpTransaction.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    nextCursor: (json['pagination'] as Map?)?['nextCursor'] as String?,
  );
}
