import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/payment_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';

class PaymentGatewayPage extends StatelessWidget {
  final PaymentController controller = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'payment_unlock_project'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Info Card
              _buildProjectInfoCard(),
              const SizedBox(height: 24),
              
              // Payment Methods
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              
              // Payment Form
              _buildPaymentForm(),
              const SizedBox(height: 24),
              
              // Order Summary
              _buildOrderSummary(),
              const SizedBox(height: 32),
              
              // Pay Button
              _buildPayButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.8),
            Theme.of(Get.context!).colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        final paymentDetails = controller.paymentDetails.value;
        if (paymentDetails == null) {
          return const Text(
            'Loading project details...',
            style: TextStyle(color: Colors.white),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    paymentDetails.projectTitle,
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              paymentDetails.projectDescription,
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price:',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '\$${paymentDetails.price.toStringAsFixed(2)}',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payment_payment_methods'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.availablePaymentMethods.map((method) {
            return RadioListTile<String>(
              title: Text(controller.getPaymentMethodDisplayName(method)),
              value: method,
              groupValue: controller.selectedPaymentMethod.value,
              onChanged: (value) => controller.selectPaymentMethod(value ?? method),
              secondary: _getPaymentMethodIcon(method),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit_card':
        return Icon(Icons.credit_card, color: Get.theme.primaryColor);
      case 'paypal':
        return const Icon(Icons.payment, color: Colors.blue);
      case 'google_pay':
        return const Icon(Icons.android, color: Colors.green);
      case 'apple_pay':
        return const Icon(Icons.apple, color: Colors.black);
      default:
        return Icon(Icons.payment, color: Get.theme.primaryColor);
    }
  }

  Widget _buildPaymentForm() {
    return Obx(() {
      if (controller.selectedPaymentMethod.value != 'credit_card') {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Redirecting to ${controller.getPaymentMethodDisplayName(controller.selectedPaymentMethod.value)}...',
              style: Get.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: controller.cardNumber.value,
                onChanged: controller.updateCardNumber,
                decoration: InputDecoration(
                  labelText: 'payment_card_number'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.credit_card),
                  errorText: controller.cardNumberError.value.isEmpty ? null : controller.cardNumberError.value,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: controller.expiryDate.value,
                      onChanged: controller.updateExpiryDate,
                      decoration: InputDecoration(
                        labelText: 'payment_expiry_date'.tr,
                        border: const OutlineInputBorder(),
                        hintText: 'MM/YY',
                        errorText: controller.expiryDateError.value.isEmpty ? null : controller.expiryDateError.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: controller.cvv.value,
                      onChanged: controller.updateCVV,
                      decoration: InputDecoration(
                        labelText: 'payment_cvv'.tr,
                        border: const OutlineInputBorder(),
                        errorText: controller.cvvError.value.isEmpty ? null : controller.cvvError.value,
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: controller.cardHolderName.value,
                onChanged: controller.updateCardHolderName,
                decoration: InputDecoration(
                  labelText: 'payment_cardholder_name'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  errorText: controller.cardHolderNameError.value.isEmpty ? null : controller.cardHolderNameError.value,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: controller.billingAddress.value,
                onChanged: controller.updateBillingAddress,
                decoration: InputDecoration(
                  labelText: 'payment_billing_address'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                  errorText: controller.billingAddressError.value.isEmpty ? null : controller.billingAddressError.value,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'payment_order_summary'.tr,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: controller.discountCode.value,
                    onChanged: controller.updateDiscountCode,
                    decoration: InputDecoration(
                      labelText: 'payment_discount_code'.tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.applyDiscountCode,
                  child: Text('payment_apply_discount'.tr),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final paymentDetails = controller.paymentDetails.value;
              if (paymentDetails == null) return const SizedBox();
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('\$${paymentDetails.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (paymentDetails.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:'),
                        Text(
                          '-\$${paymentDetails.discountAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'payment_total'.tr,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        controller.formattedFinalAmount,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Column(
      children: [
        Obx(() => CheckboxListTile(
          title: const Text('I accept the terms and conditions'),
          value: controller.acceptedTerms.value,
          onChanged: (value) => controller.toggleTermsAcceptance(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        )),
        const SizedBox(height: 16),
        Obx(() => CustomButton(
          text: controller.isProcessing.value 
              ? 'payment_processing'.tr 
              : 'payment_pay_now'.tr,
          onPressed: controller.canProcessPayment ? controller.processPayment : null,
          isLoading: controller.isProcessing.value,
          width: double.infinity,
        )),
      ],
    );
  }
} 