class PaymentDetails {
  final String projectId;
  String projectTitle;
  String projectDescription;
  double price;
  String selectedPaymentMethod;
  String cardNumber;
  String expiryDate;
  String cvv;
  String cardHolderName;
  String billingAddress;
  String discountCode;
  double discountAmount;
  double totalAmount;

  PaymentDetails({
    required this.projectId,
    required this.projectTitle,
    required this.projectDescription,
    required this.price,
    this.selectedPaymentMethod = 'credit_card',
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvv = '',
    this.cardHolderName = '',
    this.billingAddress = '',
    this.discountCode = '',
    this.discountAmount = 0.0,
    double? totalAmount,
  }) : totalAmount = totalAmount ?? price;

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      projectId: json['projectId'],
      projectTitle: json['projectTitle'],
      projectDescription: json['projectDescription'],
      price: json['price'].toDouble(),
      selectedPaymentMethod: json['selectedPaymentMethod'] ?? 'credit_card',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cvv: json['cvv'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      billingAddress: json['billingAddress'] ?? '',
      discountCode: json['discountCode'] ?? '',
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectTitle': projectTitle,
      'projectDescription': projectDescription,
      'price': price,
      'selectedPaymentMethod': selectedPaymentMethod,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardHolderName': cardHolderName,
      'billingAddress': billingAddress,
      'discountCode': discountCode,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
    };
  }

  void calculateTotal() {
    totalAmount = price - discountAmount;
    if (totalAmount < 0) totalAmount = 0;
  }
} 