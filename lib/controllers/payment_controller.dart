import 'package:get/get.dart';
import '../models/payment_details.dart';
import '../services/mock_data_service.dart';

class PaymentController extends GetxController {
  var paymentDetails = Rx<PaymentDetails?>(null);
  var isLoading = false.obs;
  var isProcessing = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var paymentSuccess = false.obs;
  
  // Form fields
  var selectedPaymentMethod = 'credit_card'.obs;
  var cardNumber = ''.obs;
  var expiryDate = ''.obs;
  var cvv = ''.obs;
  var cardHolderName = ''.obs;
  var billingAddress = ''.obs;
  var discountCode = ''.obs;
  var acceptedTerms = false.obs;
  
  // Validation
  var cardNumberError = ''.obs;
  var expiryDateError = ''.obs;
  var cvvError = ''.obs;
  var cardHolderNameError = ''.obs;
  var billingAddressError = ''.obs;
  
  final availablePaymentMethods = MockDataService.getPaymentMethods();

  @override
  void onInit() {
    super.onInit();
    loadPaymentDetails();
  }

  Future<void> loadPaymentDetails([String projectId = 'premium_access']) async {
    try {
      isLoading(true);
      hasError(false);
      
      final details = await MockDataService.getPaymentDetails(projectId);
      paymentDetails(details);
    } catch (e) {
      hasError(true);
      errorMessage('Failed to load payment details: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod(method);
    clearValidationErrors();
  }

  void updateCardNumber(String value) {
    cardNumber(value.replaceAll(' ', ''));
    validateCardNumber();
  }

  void updateExpiryDate(String value) {
    expiryDate(value);
    validateExpiryDate();
  }

  void updateCVV(String value) {
    cvv(value);
    validateCVV();
  }

  void updateCardHolderName(String value) {
    cardHolderName(value);
    validateCardHolderName();
  }

  void updateBillingAddress(String value) {
    billingAddress(value);
    validateBillingAddress();
  }

  void updateDiscountCode(String value) {
    discountCode(value);
  }

  void toggleTermsAcceptance(bool value) {
    acceptedTerms(value);
  }

  Future<void> applyDiscountCode() async {
    if (discountCode.value.isEmpty || paymentDetails.value == null) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Mock API call
      
      // Mock discount logic
      double discount = 0.0;
      switch (discountCode.value.toUpperCase()) {
        case 'SAVE10':
          discount = paymentDetails.value!.price * 0.1;
          break;
        case 'SAVE20':
          discount = paymentDetails.value!.price * 0.2;
          break;
        case 'FIRST50':
          discount = paymentDetails.value!.price * 0.5;
          break;
        default:
          Get.snackbar(
            'error'.tr,
            'Invalid discount code',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
      }

      paymentDetails.value!.discountAmount = discount;
      paymentDetails.value!.calculateTotal();
      paymentDetails.refresh();

      Get.snackbar(
        'success'.tr,
        'Discount applied successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to apply discount code',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> processPayment() async {
    if (!validateForm()) return;

    try {
      isProcessing(true);
      hasError(false);
      paymentSuccess(false);

      // Update payment details with form data
      if (paymentDetails.value != null) {
        paymentDetails.value!.selectedPaymentMethod = selectedPaymentMethod.value;
        paymentDetails.value!.cardNumber = cardNumber.value;
        paymentDetails.value!.expiryDate = expiryDate.value;
        paymentDetails.value!.cvv = cvv.value;
        paymentDetails.value!.cardHolderName = cardHolderName.value;
        paymentDetails.value!.billingAddress = billingAddress.value;
        paymentDetails.value!.discountCode = discountCode.value;
      }

      final success = await MockDataService.processPayment(paymentDetails.value!);

      if (success) {
        paymentSuccess(true);
        Get.snackbar(
          'payment_success'.tr,
          'Your payment has been processed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Navigate to success page or back
        Get.offNamed('/payment-success');
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Payment failed: ${e.toString()}');
      Get.snackbar(
        'payment_failed'.tr,
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing(false);
    }
  }

  bool validateForm() {
    bool isValid = true;
    clearValidationErrors();

    if (selectedPaymentMethod.value == 'credit_card') {
      if (!validateCardNumber()) isValid = false;
      if (!validateExpiryDate()) isValid = false;
      if (!validateCVV()) isValid = false;
      if (!validateCardHolderName()) isValid = false;
      if (!validateBillingAddress()) isValid = false;
    }

    if (!acceptedTerms.value) {
      Get.snackbar(
        'error'.tr,
        'Please accept the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
      );
      isValid = false;
    }

    return isValid;
  }

  bool validateCardNumber() {
    final number = cardNumber.value.replaceAll(' ', '');
    if (number.isEmpty) {
      cardNumberError('Card number is required');
      return false;
    }
    if (number.length < 13 || number.length > 19) {
      cardNumberError('Invalid card number length');
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
      cardNumberError('Card number must contain only digits');
      return false;
    }
    cardNumberError('');
    return true;
  }

  bool validateExpiryDate() {
    if (expiryDate.value.isEmpty) {
      expiryDateError('Expiry date is required');
      return false;
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(expiryDate.value)) {
      expiryDateError('Invalid format (MM/YY)');
      return false;
    }
    expiryDateError('');
    return true;
  }

  bool validateCVV() {
    if (cvv.value.isEmpty) {
      cvvError('CVV is required');
      return false;
    }
    if (cvv.value.length < 3 || cvv.value.length > 4) {
      cvvError('CVV must be 3 or 4 digits');
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cvv.value)) {
      cvvError('CVV must contain only digits');
      return false;
    }
    cvvError('');
    return true;
  }

  bool validateCardHolderName() {
    if (cardHolderName.value.isEmpty) {
      cardHolderNameError('Cardholder name is required');
      return false;
    }
    if (cardHolderName.value.trim().length < 2) {
      cardHolderNameError('Name must be at least 2 characters');
      return false;
    }
    cardHolderNameError('');
    return true;
  }

  bool validateBillingAddress() {
    if (billingAddress.value.isEmpty) {
      billingAddressError('Billing address is required');
      return false;
    }
    if (billingAddress.value.trim().length < 10) {
      billingAddressError('Please enter a complete address');
      return false;
    }
    billingAddressError('');
    return true;
  }

  void clearValidationErrors() {
    cardNumberError('');
    expiryDateError('');
    cvvError('');
    cardHolderNameError('');
    billingAddressError('');
  }

  String formatCardNumber(String value) {
    final cleaned = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  String getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'credit_card':
        return 'payment_credit_card'.tr;
      case 'paypal':
        return 'payment_paypal'.tr;
      case 'google_pay':
        return 'payment_google_pay'.tr;
      case 'apple_pay':
        return 'payment_apple_pay'.tr;
      default:
        return method;
    }
  }

  bool get canProcessPayment => 
      paymentDetails.value != null && 
      !isProcessing.value && 
      acceptedTerms.value;

  double get finalAmount => paymentDetails.value?.totalAmount ?? 0.0;

  String get formattedFinalAmount {
    return '\$${finalAmount.toStringAsFixed(2)}';
  }

  void resetForm() {
    selectedPaymentMethod('credit_card');
    cardNumber('');
    expiryDate('');
    cvv('');
    cardHolderName('');
    billingAddress('');
    discountCode('');
    acceptedTerms(false);
    clearValidationErrors();
    paymentSuccess(false);
    hasError(false);
    errorMessage('');
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
} 