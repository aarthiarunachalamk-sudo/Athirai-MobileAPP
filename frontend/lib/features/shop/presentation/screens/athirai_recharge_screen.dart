import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/shop_store.dart';
import '../../../../core/utils/numeric_utils.dart';
import '../theme/heritage_theme.dart';
import '../widgets/athirai_royal_drawer.dart';
import 'athirai_certified_coins_screen.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_profile_dashboard_screen.dart';

/// Screen-accurate luxury Recharge & AUG Coins Wallet screen
/// matching https://infisq.com/recharge with Athirai Royal heritage aesthetics:
/// - Balance card showing available AUG Coins, live gold value, and daily activity
/// - Preset and custom recharge tiers (₹100, ₹1,000, ₹5,000, ₹10,000, ₹1,00,000)
/// - 100 AUG Coins credited per rupee recharged
/// - Autopay / SIP Mandate configuration
/// - Recent recharges and daily login reward transaction history
/// - Direct CTA: "Buy Gold with Coins"
class AthiraiRechargeScreen extends StatefulWidget {
  const AthiraiRechargeScreen({
    super.key,
    required this.store,
    this.onBack,
    this.onBuyGoldWithCoins,
  });

  final ShopStore store;
  final VoidCallback? onBack;
  final VoidCallback? onBuyGoldWithCoins;

  @override
  State<AthiraiRechargeScreen> createState() => _AthiraiRechargeScreenState();
}

class _AthiraiRechargeScreenState extends State<AthiraiRechargeScreen> {
  final _amountCtrl = TextEditingController();
  final List<int> _presetAmounts = [100, 1000, 5000, 10000, 100000];
  int _selectedAmount = 1000;
  String _selectedPaymentMethod = 'upi';
  String _historyFilter = 'all'; // all, reward, recharge, purchase
  bool _isProcessing = false;
  bool _autopayActive = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = '$_selectedAmount';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  int get _currentAmount =>
      int.tryParse(_amountCtrl.text.replaceAll(',', '').trim()) ?? 0;

  double get _calculatedCoins => widget.store.inrToCoins(_currentAmount);

  String _formatCoinCount(num coins) {
    final count = coins == coins.roundToDouble()
        ? coins.toInt().toString()
        : coins.toStringAsFixed(1);
    final parts = count.split('.');
    final digits = parts.first;
    final groupedCount = digits.length <= 3
        ? digits
        : '${digits.substring(0, digits.length - 3).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
            (match) => '${match[1]},',
          )},${digits.substring(digits.length - 3)}';
    return parts.length == 1 ? groupedCount : '$groupedCount.${parts[1]}';
  }

  void _selectPreset(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountCtrl.text = '$amount';
    });
  }

  Future<void> _handleRecharge() async {
    final amt = _currentAmount;
    if (amt <= 0) {
      AthiraiSnackBar.show(
        context,
        message: 'Please enter a valid recharge amount',
        isError: true,
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    setState(() => _isProcessing = true);
    final coins = _calculatedCoins;

    // Simulate brief initial connection before showing Razorpay modal
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final phone = widget.store.userPhone.isNotEmpty
        ? widget.store.userPhone
        : '+91 63852 57541';

    // Show interactive Razorpay Checkout Modal Sheet matching reference video
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => _AthiraiRazorpayCheckoutSheet(
        amount: amt,
        coins: coins,
        phoneNumber: phone,
      ),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success == true) {
      final ok = await widget.store.rechargeWallet(
        amount: amt.toDouble(),
        coins: coins,
        paymentMethod: _selectedPaymentMethod,
      );

      if (mounted && ok) {
        _showRechargeSuccessDialog(amt.toDouble(), coins);
      }
    }
  }

  void _showRechargeSuccessDialog(double amount, double coins) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF061B18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x3316A34A),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4ADE80),
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recharge Successful!',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F2E8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+${_formatCoinCount(coins)} AUG Coins added to your vault balance for ₹${amount.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFD1DFDE),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x66020907),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33D4AF37)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NEW VAULT BALANCE:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9FAFA9),
                      ),
                    ),
                    Text(
                      '${_formatCoinCount(widget.store.augCoins)} AUG Coins',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A45B),
                    foregroundColor: const Color(0xFF041A13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAutopayModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF061B18),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Autopay Gold SIP Settings',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFFC7A45B)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Automatically accumulate AUG coins every month to buy physical 24K gold bullion on schedule.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFFA2B4AF),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SIP Auto-Recharge Status:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF7F2E8),
                    ),
                  ),
                  Switch(
                    value: _autopayActive,
                    activeColor: const Color(0xFFFFDF7A),
                    activeTrackColor: const Color(0xFF16A34A),
                    onChanged: (val) {
                      setModalState(() => _autopayActive = val);
                      setState(() => _autopayActive = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'MONTHLY MANDATE AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: const Color(0xFF9FAFA9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0x66020907),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x44C7A45B)),
                ),
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: '₹1,000 / month (10 AUG Coins)'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFFFDF7A),
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    AthiraiSnackBar.show(
                      context,
                      message: _autopayActive
                          ? 'Autopay Gold SIP mandate enabled!'
                          : 'Autopay Gold SIP mandate disabled.',
                      icon: Icons.autorenew_rounded,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7A45B),
                    foregroundColor: const Color(0xFF041A13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _autopayActive ? 'Save SIP Mandate' : 'Confirm Settings',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance & Gold Equivalency Card
                    _buildBalanceCard(),
                    const SizedBox(height: 18),

                    // Buy Recharge & Payment Methods
                    _buildRechargeCard(),
                    const SizedBox(height: 18),

                    // "Buy Gold with Coins" Banner
                    _buildBuyGoldWithCoinsBanner(),
                    const SizedBox(height: 22),

                    // Transaction History Section
                    _buildHistorySection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xCC061B18),
        border: Border(bottom: BorderSide(color: Color(0x22C7A45B), width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFC7A45B),
              size: 19,
            ),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROYAL WALLET & REWARDS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: const Color(0xFFC7A45B),
                ),
              ),
              Text(
                'Recharge & AUG Coins',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F2E8),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Autopay Pill
          InkWell(
            onTap: _showAutopayModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _autopayActive
                    ? const Color(0x3316A34A)
                    : const Color(0x22C7A45B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _autopayActive
                      ? const Color(0xFF16A34A)
                      : const Color(0x66C7A45B),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _autopayActive
                        ? Icons.check_circle_rounded
                        : Icons.autorenew_rounded,
                    size: 12,
                    color: _autopayActive
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFC7A45B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Autopay: ${_autopayActive ? "ON" : "OFF"}',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _autopayActive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF7F2E8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Three-line menu button (☰) in top-right corner (Step 10 Point 2)
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFFC7A45B),
              size: 23,
            ),
            tooltip: 'Menu (Order Summary & Vault)',
            onPressed: () {
              AthiraiRoyalDrawer.show(
                context,
                store: widget.store,
                onSelectHome: widget.onBack,
                onSelectProfile: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiProfileDashboardScreen(
                        store: widget.store,
                      ),
                    ),
                  );
                },
                onSelectOrders: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AthiraiOrderSummaryScreen(
                        store: widget.store,
                      ),
                    ),
                  );
                },
                onSelectRecharge: () {},
                onSelectCollections: widget.onBuyGoldWithCoins,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final goldRupees =
        (widget.store.augCoins * widget.store.augCoinValueInRupees).round();
    // 24K gold rate per gram
    final goldGramRate = widget.store.rates.gold24k;
    final goldGrams = goldGramRate > 0 ? (goldRupees / goldGramRate) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B2E28),
            Color(0xFF071F1B),
            Color(0xFF041512),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x66D4AF37), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE COIN BALANCE',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFFC7A45B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x33D4AF37),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Daily Login: +1 Earned',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFDF7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatCoinCount(widget.store.augCoins),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFDF7A),
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AUG Coins',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE5C882),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Live Gold Equivalence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x44020907),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x33C7A45B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 14, color: Color(0xFFC7A45B)),
                    const SizedBox(width: 6),
                    Text(
                      'Gold Value: ₹$goldRupees',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF7F2E8),
                      ),
                    ),
                  ],
                ),
                Text(
                  goldGrams >= 1.0
                      ? '${goldGrams.toStringAsFixed(2)}g 24K'
                      : '${(goldGrams * 1000).round()}mg 24K Pure Gold',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Today's recharge activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today Recharged:',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF9FAFA9),
                ),
              ),
              Text(
                '₹${widget.store.todayRechargeAmount.toInt()} · ${_formatCoinCount(widget.store.todayCoins)} coins',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF7F2E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x99061B18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33C7A45B), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buy Recharge',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF7F2E8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add coins to your vault to purchase certified gold or redeem on heirlooms.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFFA2B4AF),
            ),
          ),
          const SizedBox(height: 16),

          // Preset Amount Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetAmounts.map((amt) {
              final isSelected = _selectedAmount == amt;
              return InkWell(
                onTap: () => _selectPreset(amt),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0x33D4AF37)
                        : const Color(0x33020907),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : const Color(0x33C7A45B),
                      width: isSelected ? 1.4 : 0.8,
                    ),
                  ),
                  child: Text(
                    '₹${amt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFFFDF7A)
                          : const Color(0xFFD1DFDE),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Custom Amount Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x66020907),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x44C7A45B)),
            ),
            child: Row(
              children: [
                Text(
                  '₹',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC7A45B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF7F2E8),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter custom amount (₹)',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7E7A),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectedAmount = int.tryParse(val.replaceAll(',', '')) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Coin Preview Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x22C7A45B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x44C7A45B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You'll get in Vault:",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD1DFDE),
                  ),
                ),
                Text(
                  '+${_formatCoinCount(_calculatedCoins)} AUG Coins',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Method Selector (UPI / Card / Netbanking)
          Row(
            children: [
              _buildMethodOption('upi', 'UPI Pay'),
              const SizedBox(width: 8),
              _buildMethodOption('card', 'Card'),
              const SizedBox(width: 8),
              _buildMethodOption('netbanking', 'NetBanking'),
            ],
          ),
          const SizedBox(height: 18),

          // Pay & Recharge Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleRecharge,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                shadowColor: const Color(0x44D4AF37),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE5C882),
                      Color(0xFFC7A45B),
                      Color(0xFF9E7B36),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF041A13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PROCESSING...',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF041A13),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'PAY ₹$_currentAmount & RECHARGE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF041A13),
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String key, String label) {
    final isSelected = _selectedPaymentMethod == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x33D4AF37) : const Color(0x33020907),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : const Color(0x33C7A45B),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFFDF7A)
                    : const Color(0xFFA2B4AF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner directing customers to Buy Gold using AUG Coins & Rewards
  Widget _buildBuyGoldWithCoinsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F1706),
            Color(0xFF2E2209),
            Color(0xFF140E02),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x33D4AF37),
            ),
            child: const Center(
              child: Text(
                '🪙',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buy Gold with Coins',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFDF7A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Redeem your AUG coins directly for 24K 999 Fine Gold & 22K certified coins.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFFD1DFDE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (widget.onBuyGoldWithCoins != null) {
                widget.onBuyGoldWithCoins!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AthiraiCertifiedCoinsScreen(
                      store: widget.store,
                      initialTab: 'Silver Coins',
                      onBack: () => Navigator.of(context).pop(),
                      onOpenRecharge: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7A45B),
              foregroundColor: const Color(0xFF041A13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Buy Gold →',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final history = widget.store.walletHistory;
    final filtered = _historyFilter == 'all'
        ? history
        : history.where((t) => t['type'] == _historyFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF7F2E8),
              ),
            ),
            Text(
              '${filtered.length} entries',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF9FAFA9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterTab('all', 'All'),
              _buildFilterTab('reward', 'Rewards'),
              _buildFilterTab('recharge', 'Recharges'),
              _buildFilterTab('purchase', 'Gold Purchases'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x44020907),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x22C7A45B)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 32,
                  color: Color(0xFF6B7E7A),
                ),
                const SizedBox(height: 8),
                Text(
                  'No transactions recorded yet in this view.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFFA2B4AF),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tx = filtered[index];
              final isCredit = tx['direction']?.toString().toLowerCase() == 'credit';
              final type = tx['type']?.toString() ?? 'recharge';
              final coins = parseDouble(tx['coins_credited'], 1.0);
              final source = tx['source']?.toString() ?? 'Athirai Vault';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x66020907),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x22C7A45B)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: type == 'reward'
                            ? const Color(0x3316A34A)
                            : type == 'purchase'
                                ? const Color(0x33C92035)
                                : const Color(0x33D4AF37),
                      ),
                      child: Center(
                        child: Icon(
                          type == 'reward'
                              ? Icons.card_giftcard_rounded
                              : type == 'purchase'
                                  ? Icons.shopping_bag_outlined
                                  : Icons.add_circle_outline_rounded,
                          size: 18,
                          color: type == 'reward'
                              ? const Color(0xFF4ADE80)
                              : type == 'purchase'
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFFFDF7A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF7F2E8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type == 'reward' ? 'Daily Login Privilege' : 'Vault Transaction',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: const Color(0xFF9FAFA9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isCredit ? "+" : "−"}${_formatCoinCount(coins)} AUG',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isCredit
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCredit
                                ? const Color(0x2216A34A)
                                : const Color(0x22C92035),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCredit ? '+ CREDIT' : '− DEBIT',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isCredit
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFF87171),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final isSelected = _historyFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _historyFilter = key),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC7A45B) : const Color(0x22020907),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC7A45B)
                  : const Color(0x33C7A45B),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF041A13)
                  : const Color(0xFFA2B4AF),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen-accurate Razorpay Checkout Sheet matching the video recording:
/// - Green "Test Mode" ribbon in top right
/// - Header with Shield icon, BitByte Wallet Recharge, Price Summary, and user phone
/// - Exit Confirmation Dialog when 'X' is tapped ("Are you sure you want to exit?")
/// - Payment options tabs: UPI, Cards, EMI, Netbanking, Wallet, Pay Later
/// - UPI QR Code with live countdown timer (11:55) and app badges
/// - Interactive payment completion simulation
class _AthiraiRazorpayCheckoutSheet extends StatefulWidget {
  const _AthiraiRazorpayCheckoutSheet({
    required this.amount,
    required this.coins,
    required this.phoneNumber,
  });

  final int amount;
  final double coins;
  final String phoneNumber;

  @override
  State<_AthiraiRazorpayCheckoutSheet> createState() =>
      _AthiraiRazorpayCheckoutSheetState();
}

class _AthiraiRazorpayCheckoutSheetState
    extends State<_AthiraiRazorpayCheckoutSheet> {
  String _selectedTab = 'UPI';
  int _secondsLeft = 715; // 11:55
  Timer? _countdownTimer;
  bool _isCompleting = false;

  final List<Map<String, dynamic>> _tabs = [
    {'id': 'UPI', 'label': 'UPI', 'icon': Icons.qr_code_2_rounded},
    {'id': 'Cards', 'label': 'Cards', 'icon': Icons.credit_card_rounded},
    {'id': 'EMI', 'label': 'EMI', 'icon': Icons.percent_rounded},
    {'id': 'Netbanking', 'label': 'Netbanking', 'icon': Icons.account_balance_rounded},
    {'id': 'Wallet', 'label': 'Wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'id': 'Pay Later', 'label': 'Pay Later', 'icon': Icons.watch_later_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        if (mounted) setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smartphone_rounded,
                  color: Color(0xFF4B5563),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to exit?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will be taken back to BitByte Wallet Recharge website',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Button: Continue to payment
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF1F2937),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue to payment',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Button: Yes, exit
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Yes, exit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completePayment() {
    setState(() => _isCompleting = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final amtFormatted = widget.amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0A231F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
      ),
      child: Column(
        children: [
          // ── Razorpay Top Header with Test Mode Ribbon & Close ──────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF061B18),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(bottom: BorderSide(color: Color(0x33C7A45B), width: 0.8)),
            ),
            child: Row(
              children: [
                // Shield Logo
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1366E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BitByte Wallet Recharge',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Price Summary  ₹$amtFormatted',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFDF7A),
                        ),
                      ),
                      Text(
                        'Using as ${widget.phoneNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF9FAFA9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Green Test Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: const Text(
                    'Test Mode',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Close Button
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFE5E7EB), size: 22),
                  onPressed: _showExitDialog,
                ),
              ],
            ),
          ),

          // ── Payment Options Tabs & Content View ───────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Payment Options List
                Container(
                  width: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF041512),
                    border: Border(right: BorderSide(color: Color(0x33C7A45B), width: 0.8)),
                  ),
                  child: ListView.builder(
                    itemCount: _tabs.length,
                    itemBuilder: (ctx, idx) {
                      final t = _tabs[idx];
                      final isSelected = _selectedTab == t['id'];
                      return InkWell(
                        onTap: () => setState(() => _selectedTab = t['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0B2E28)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                t['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? const Color(0xFFFFDF7A)
                                    : const Color(0xFF8E9E94),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t['label'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF8E9E94),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Column: Active Option View
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF081F1B),
                    child: _buildTabContent(amtFormatted),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Secured by Razorpay Banner ─────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF04120F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF8E9E94)),
                    const SizedBox(width: 4),
                    Text(
                      'Secured by Razorpay',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF8E9E94),
                      ),
                    ),
                  ],
                ),
                Text(
                  '100% RBI Compliant',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC7A45B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String amtFormatted) {
    switch (_selectedTab) {
      case 'Cards':
        return _buildCardsContent(amtFormatted);
      case 'Netbanking':
        return _buildNetbankingContent(amtFormatted);
      case 'Wallet':
        return _buildWalletContent(amtFormatted);
      case 'EMI':
      case 'Pay Later':
        return _buildGenericContent(_selectedTab, amtFormatted);
      case 'UPI':
      default:
        return _buildUpiQrContent(amtFormatted);
    }
  }

  Widget _buildUpiQrContent(String amtFormatted) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPI QR',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFFFDF7A)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_secondsLeft),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFDF7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Scan the QR using any UPI App',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF9FAFA9),
            ),
          ),
          const SizedBox(height: 12),

          // Apps Row (GPay, PhonePe, Paytm, BHIM)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppPill('GPay', const Color(0xFF4285F4)),
              const SizedBox(width: 6),
              _buildAppPill('PhonePe', const Color(0xFF5F259F)),
              const SizedBox(width: 6),
              _buildAppPill('Paytm', const Color(0xFF00B9F5)),
              const SizedBox(width: 6),
              _buildAppPill('BHIM', const Color(0xFF00796B)),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Painted QR Code Container
          Container(
            width: 170,
            height: 170,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: CustomPaint(
              painter: _UpiQrPainter(),
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A231F),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, color: Color(0xFFFFDF7A), size: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Simulate Payment Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: _isCompleting ? null : _completePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Simulate UPI Payment (₹$amtFormatted)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsContent(String amtFormatted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 12),
        _buildMockField('Card Number', '4111 •••• •••• 1234'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildMockField('Expiry', '12 / 28')),
            const SizedBox(width: 8),
            Expanded(child: _buildMockField('CVV', '•••')),
          ],
        ),
        const SizedBox(height: 8),
        _buildMockField('Cardholder Name', 'Ananya Sharma'),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isCompleting ? null : _completePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7A45B),
              foregroundColor: const Color(0xFF041A13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Pay ₹$amtFormatted',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetbankingContent(String amtFormatted) {
    final banks = ['SBI', 'HDFC', 'ICICI', 'Axis Bank', 'Kotak'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Popular Bank',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: banks.map((bank) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x33041A13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x33C7A45B)),
              ),
              child: Text(
                bank,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFD1DFDE)),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isCompleting ? null : _completePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7A45B),
              foregroundColor: const Color(0xFF041A13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Pay ₹$amtFormatted via Netbanking',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletContent(String amtFormatted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Wallets',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text('Paytm, PhonePe, Mobikwik, Amazon Pay', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA2B4AF))),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isCompleting ? null : _completePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7A45B),
              foregroundColor: const Color(0xFF041A13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Pay ₹$amtFormatted',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericContent(String title, String amtFormatted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 10),
        Text('Eligible plans available for ₹$amtFormatted', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA2B4AF))),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isCompleting ? null : _completePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7A45B),
              foregroundColor: const Color(0xFF041A13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm ₹$amtFormatted', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _buildAppPill(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.6), width: 0.8),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMockField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8E9E94))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x33020907),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x33C7A45B)),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFF7F2E8)),
          ),
        ),
      ],
    );
  }
}

/// Custom painter generating an authentic QR matrix with positioning squares
class _UpiQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final step = size.width / 21;

    // Corner Finder Patterns
    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, step * 7, step * 7), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(x + step, y + step, step * 5, step * 5), whitePaint);
      canvas.drawRect(Rect.fromLTWH(x + step * 2, y + step * 2, step * 3, step * 3), paint);
    }

    drawFinder(0, 0);
    drawFinder(size.width - step * 7, 0);
    drawFinder(0, size.height - step * 7);

    // Timing patterns & modules
    for (int i = 8; i < 13; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(i * step, 6 * step, step, step), paint);
        canvas.drawRect(Rect.fromLTWH(6 * step, i * step, step, step), paint);
      }
    }

    // Grid Modules
    final pattern = [
      [8, 1], [9, 3], [10, 4], [12, 2], [13, 3],
      [1, 8], [3, 9], [4, 10], [2, 12], [5, 13],
      [14, 8], [15, 9], [17, 10], [18, 12], [19, 13],
      [8, 14], [9, 15], [10, 17], [12, 18], [13, 19],
      [14, 14], [16, 16], [18, 18], [15, 17], [17, 15],
      [9, 9], [10, 10], [11, 11], [12, 12], [13, 13],
    ];

    for (final p in pattern) {
      canvas.drawRect(Rect.fromLTWH(p[0] * step, p[1] * step, step, step), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

