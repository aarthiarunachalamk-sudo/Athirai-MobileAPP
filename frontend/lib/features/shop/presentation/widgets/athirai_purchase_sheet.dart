import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import '../screens/athirai_order_summary_screen.dart';
import 'athirai_receipt_helper.dart';

/// Interactive modal sheet implementing Step 8 (Purchase Process), Step 9 (Buy AUG Coins via Razorpay),
/// Step 10 (Payment Success & Order Summary), and Step 11 (Download Receipt).
class AthiraiPurchaseSheet {
  static void show(
    BuildContext context, {
    required ShopProduct product,
    required ShopStore store,
    VoidCallback? onOrderCompleted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PurchaseSheetContent(
        product: product,
        store: store,
        onOrderCompleted: onOrderCompleted,
      ),
    );
  }
}

class _PurchaseSheetContent extends StatefulWidget {
  const _PurchaseSheetContent({
    required this.product,
    required this.store,
    this.onOrderCompleted,
  });

  final ShopProduct product;
  final ShopStore store;
  final VoidCallback? onOrderCompleted;

  @override
  State<_PurchaseSheetContent> createState() => _PurchaseSheetContentState();
}

class _PurchaseSheetContentState extends State<_PurchaseSheetContent> {
  bool _isProcessing = false;
  bool _isEditingAddress = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _doorCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _townCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pinCtrl;
  late final TextEditingController _stateCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    _nameCtrl = TextEditingController(text: s.deliveryName);
    _phoneCtrl = TextEditingController(text: s.deliveryPhone);
    _doorCtrl = TextEditingController(text: s.doorNo);
    _streetCtrl = TextEditingController(text: s.streetName);
    _townCtrl = TextEditingController(text: s.town);
    _cityCtrl = TextEditingController(text: s.city);
    _pinCtrl = TextEditingController(text: s.pincode);
    _stateCtrl = TextEditingController(text: s.state);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _doorCtrl.dispose();
    _streetCtrl.dispose();
    _townCtrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  void _saveAddress() {
    widget.store.updateDeliveryAddress(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      doorNo: _doorCtrl.text.trim(),
      streetName: _streetCtrl.text.trim(),
      town: _townCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      pincode: _pinCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
    );
    setState(() => _isEditingAddress = false);
  }

  // Step 8 & 10: Place order with AUG Coins
  Future<void> _handleConfirmPurchase() async {
    setState(() => _isProcessing = true);

    final res = await widget.store.placeOrderWithCoins(
      productName: widget.product.name,
      totalAmountInr: widget.product.price,
      productImage: widget.product.item.assetPreview,
      metalPurity: widget.product.materialLabel,
      weightGrams: widget.product.weightGrams,
      quantity: 1,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res['success'] == true) {
      final order = res['order'] as Map<String, dynamic>;
      Navigator.of(context).pop(); // close bottom sheet
      _showSuccessCelebrationDialog(order);
      widget.onOrderCompleted?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Purchase could not be processed: ${res['error'] ?? 'Unknown error'}'),
        ),
      );
    }
  }

  // Step 9: Buy AUG Coins via Razorpay Gateway sheet
  void _openRazorpayCoinsSheet(double shortfallInr, double shortfallCoins) {
    final mobileCtrl = TextEditingController(text: widget.store.deliveryPhone);
    double rechargeAmount = shortfallInr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (rzpCtx) => StatefulBuilder(
        builder: (ctx, setRzpState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF04120E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: HeritageTheme.goldBorder, width: 1.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Razorpay Header (Step 9 Point 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C2340),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF0284C7), width: 0.8),
                          ),
                          child: Text(
                            'Razorpay',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buy AUG Coins',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: HeritageTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: HeritageTheme.goldPrimary),
                      onPressed: () => Navigator.of(rzpCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Notice: 1 Rupee = 100 AUG Coins
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: HeritageTheme.goldBright, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Coin Value: 1 Rupee = 100 AUG Coins\nPaying ₹${rechargeAmount.toStringAsFixed(0)} will credit ${(rechargeAmount * 100).toInt()} AUG Coins to your vault.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: HeritageTheme.textLight,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Step 9 Point 3: Mobile Number
                Text(
                  'Mobile Number (Step 9)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: HeritageTheme.textLight),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: HeritageTheme.textLight, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: HeritageTheme.goldPrimary, size: 18),
                    hintText: 'Enter 10-digit mobile number',
                    hintStyle: const TextStyle(color: HeritageTheme.textMutedDark, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF081C17),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: HeritageTheme.goldBorderSubtle),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Amount Selection (Step 9 Point 4)
                Text(
                  'Payment Amount (INR)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: HeritageTheme.textLight),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final amt in [shortfallInr, shortfallInr + 500, shortfallInr + 1000])
                      ChoiceChip(
                        label: Text('₹${amt.toInt()} (= ${(amt * 100).toInt()} Coins)'),
                        selected: (rechargeAmount - amt).abs() < 1,
                        onSelected: (sel) {
                          if (sel) setRzpState(() => rechargeAmount = amt);
                        },
                        selectedColor: HeritageTheme.goldPrimary,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: (rechargeAmount - amt).abs() < 1 ? Colors.black : HeritageTheme.textLight,
                        ),
                        backgroundColor: const Color(0xFF081C17),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Razorpay Payment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(rzpCtx).pop(); // close rzp sheet
                      setState(() => _isProcessing = true);

                      // Simulate Razorpay Gateway & Credit AUG Coins (Step 9 Point 5)
                      final ok = await widget.store.buyAUGCoinsViaRazorpay(
                        amountInr: rechargeAmount,
                        mobileNumber: mobileCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      if (ok) {
                        _showRazorpayCoinsCreditedDialog(
                          context,
                          rechargeAmount,
                          (rechargeAmount * 100).toInt(),
                          _handleConfirmPurchase,
                        );
                      } else {
                        setState(() => _isProcessing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red.shade900,
                            content: const Text('Razorpay payment cancelled or failed.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Make Payment ₹${rechargeAmount.toInt()} via Razorpay →',
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRazorpayCoinsCreditedDialog(
    BuildContext context,
    double amountInr,
    int coins,
    VoidCallback onProceedToOrder,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF061B16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageTheme.goldBorder, width: 1.1),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 8),
            Text(
              'Coins Added via Razorpay!',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: HeritageTheme.textLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment of ₹${amountInr.toInt()} Successful via Razorpay.',
              style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.goldBright),
            ),
            const SizedBox(height: 8),
            Text(
              '+$coins AUG Coins credited to your vault. Click below to complete your jewellery purchase.',
              style: GoogleFonts.inter(fontSize: 12.5, color: HeritageTheme.textLight, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              onProceedToOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageTheme.goldPrimary,
              foregroundColor: const Color(0xFF041814),
            ),
            child: const Text('Confirm Purchase / வாங்குக'),
          ),
        ],
      ),
    );
  }

  // Step 10 & 11: Payment Success & Order Summary Celebratory Dialog
  void _showSuccessCelebrationDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF041814),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HeritageTheme.goldBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(color: Colors.black87, blurRadius: 40, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Badge
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFC7A45B), Color(0xFF7A5822)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF041814), size: 44),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Order Confirmed!',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: HeritageTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paid with AUG Coins • 100% BIS Hallmarked',
                style: GoogleFonts.inter(fontSize: 11.5, color: HeritageTheme.goldBright),
              ),
              const SizedBox(height: 14),

              // Order Details Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF020B09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.6),
                ),
                child: Column(
                  children: [
                    _orderRow('Invoice No', order['invoice_number']?.toString() ?? 'INV-ATH'),
                    const SizedBox(height: 4),
                    _orderRow('Product', order['product_name']?.toString() ?? widget.product.name),
                    const SizedBox(height: 4),
                    _orderRow('AUG Coins Paid', '🪙 ${order['coins_used'] ?? (widget.product.price * 100)} Coins'),
                    const SizedBox(height: 4),
                    _orderRow('Deliver to', order['delivery_name']?.toString() ?? widget.store.deliveryName),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Step 11: Download Receipt Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AthiraiReceiptHelper.downloadAndPrintReceipt(context, order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageTheme.goldPrimary,
                    foregroundColor: const Color(0xFF041814),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(
                    'Download Tax Receipt (PDF)',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Step 10: View in Order Summary
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthiraiOrderSummaryScreen(store: widget.store),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HeritageTheme.textLight,
                    side: const BorderSide(color: HeritageTheme.goldBorderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 16, color: HeritageTheme.goldBright),
                  label: Text(
                    'View in Order Summary →',
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: HeritageTheme.textMutedDark)),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: HeritageTheme.textLight),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinsNeeded = widget.store.inrToCoins(widget.product.price);
    final userCoins = widget.store.augCoins;
    final hasEnoughCoins = userCoins >= coinsNeeded;
    final shortfallCoins = coinsNeeded - userCoins;
    final shortfallInr = shortfallCoins / 100.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF04120E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: HeritageTheme.goldBorder, width: 1.2)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Purchase with AUG Coins',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.textLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HeritageTheme.goldPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Snippet
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF061814),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFF030D0A),
                        child: widget.product.item.assetPreview.startsWith('http')
                            ? Image.network(widget.product.item.assetPreview, fit: BoxFit.cover)
                            : Image.asset(widget.product.item.assetPreview, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.diamond, color: HeritageTheme.goldPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: HeritageTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.product.materialLabel} • ${widget.product.weightGrams.toStringAsFixed(2)} g',
                            style: GoogleFonts.inter(fontSize: 11, color: HeritageTheme.textMutedDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '🪙 ${coinsNeeded.toInt()} AUG Coins  (${rupees(widget.product.price)})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: HeritageTheme.goldBright,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Step 8 Point 4: Delivery Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: HeritageTheme.goldBright, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Delivery Address (Step 8)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditingAddress = !_isEditingAddress);
                    },
                    child: Text(
                      _isEditingAddress ? 'Done' : 'Change',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HeritageTheme.goldBright,
                      ),
                    ),
                  ),
                ],
              ),

              if (_isEditingAddress) ...[
                _textField('Full Name', _nameCtrl),
                const SizedBox(height: 8),
                _textField('Phone', _phoneCtrl),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _textField('Door No', _doorCtrl)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _textField('Street', _streetCtrl)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _textField('City', _cityCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _textField('Pincode', _pinCtrl)),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2C24),
                    foregroundColor: HeritageTheme.goldBright,
                  ),
                  child: const Text('Save Address'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061814),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.store.deliveryName} • ${widget.store.deliveryPhone}',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: HeritageTheme.textLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.store.doorNo}, ${widget.store.streetName}, ${widget.store.town}, ${widget.store.city} - ${widget.store.pincode}, ${widget.store.state}',
                        style: GoogleFonts.inter(fontSize: 11, color: HeritageTheme.textMutedDark),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // AUG Coins Balance & Comparison
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasEnoughCoins ? const Color(0x3310B981) : const Color(0x33EF4444),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasEnoughCoins ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your AUG Coins Vault:', style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.textLight)),
                        Text('🪙 ${userCoins.toInt()} Coins', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: HeritageTheme.goldBright)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Coins Required:', style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.textLight)),
                        Text('🪙 ${coinsNeeded.toInt()} Coins', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: HeritageTheme.textLight)),
                      ],
                    ),
                    if (!hasEnoughCoins) ...[
                      const Divider(color: Color(0x44EF4444), height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shortfall Amount:', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFCA5A5))),
                          Text('₹${shortfallInr.toInt()} (${shortfallCoins.toInt()} Coins)', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFFFCA5A5))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons: Pay with Coins OR Buy AUG Coins (Step 9)
              if (_isProcessing) ...[
                const Center(
                  child: CircularProgressIndicator(color: HeritageTheme.goldPrimary),
                ),
              ] else if (hasEnoughCoins) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleConfirmPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeritageTheme.goldPrimary,
                      foregroundColor: const Color(0xFF030D0A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Pay 🪙 ${coinsNeeded.toInt()} AUG Coins & Place Order →',
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ] else ...[
                // Step 9: User lacks enough coins -> Offer Buy AUG Coins via Razorpay
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openRazorpayCoinsSheet(shortfallInr, shortfallCoins),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: Text(
                      'Buy AUG Coins (Razorpay ₹${shortfallInr.toInt()}) →',
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: HeritageTheme.textLight, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: HeritageTheme.textMutedDark, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF081C17),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
