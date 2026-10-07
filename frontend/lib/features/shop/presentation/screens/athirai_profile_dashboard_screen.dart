import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';
import 'athirai_order_summary_screen.dart';
import 'athirai_recharge_screen.dart';

/// Screen-accurate luxury Profile Dashboard (Step 6 & 7)
/// - Opens upon login or via top-right ☰ menu
/// - Profile details & delivery address management
/// - Real-time AUG Coins Vault with 1 Rupee = 100 AUG Coins ratio
/// - Manual Coin Creation / Generation (Step 7 #5)
/// - Navigation to Order Summary, Recharge, and Jewellery Collections
class AthiraiProfileDashboardScreen extends StatefulWidget {
  const AthiraiProfileDashboardScreen({
    super.key,
    required this.store,
    this.onBack,
    this.onOpenMenu,
    this.onOpenOrders,
    this.onOpenCollection,
    this.onOpenRecharge,
    this.onSignOut,
  });

  final ShopStore store;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenCollection;
  final VoidCallback? onOpenRecharge;
  final VoidCallback? onSignOut;

  @override
  State<AthiraiProfileDashboardScreen> createState() => _AthiraiProfileDashboardScreenState();
}

class _AthiraiProfileDashboardScreenState extends State<AthiraiProfileDashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.store.loadFromBackend();
    widget.store.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.store,
                builder: (context, _) {
                  return RefreshIndicator(
                    color: HeritageTheme.goldBright,
                    backgroundColor: const Color(0xFF04100D),
                    onRefresh: () async {
                      await widget.store.loadFromBackend();
                      await widget.store.loadOrders();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      children: [
                        _buildProfileHeaderCard(),
                        const SizedBox(height: 16),
                        _buildAugCoinsVaultCard(),
                        const SizedBox(height: 16),
                        _buildDeliveryAddressCard(),
                        const SizedBox(height: 16),
                        _buildServicesGrid(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF04120E),
        border: Border(
          bottom: BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: HeritageTheme.goldBright, size: 20),
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Dashboard',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: HeritageTheme.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Account Details & AUG Coins Vault',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Main Menu (☰)',
            icon: const Icon(Icons.menu_rounded, color: HeritageTheme.goldBright, size: 24),
            onPressed: widget.onOpenMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF061B16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Royal Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFDF7A), Color(0xFFC7A45B), Color(0xFF7A5822)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: Color(0xFF04120E), size: 36),
            ),
          ),
          const SizedBox(width: 16),
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.store.deliveryName.isNotEmpty ? widget.store.deliveryName : 'Royal Patron',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  widget.store.deliveryPhone,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: HeritageTheme.textMutedDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HeritageTheme.goldBorder, width: 0.6),
                  ),
                  child: Text(
                    'IMPERIAL GOLD PATRON',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.goldBright,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onSignOut != null)
            IconButton(
              tooltip: 'Sign Out',
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              onPressed: widget.onSignOut,
            ),
        ],
      ),
    );
  }

  Widget _buildAugCoinsVaultCard() {
    final coins = widget.store.augCoins;
    final inrValuation = widget.store.coinsToInr(coins);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B2C24),
            Color(0xFF061814),
            Color(0xFF030D0A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeritageTheme.goldBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.18),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vault Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33D4AF37),
                      border: Border.all(color: HeritageTheme.goldBorder, width: 0.8),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: HeritageTheme.goldBright, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUG COINS VAULT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.goldBright,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Athirai Universal Gold Currency',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: HeritageTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Daily Login Reward Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981), width: 0.6),
                ),
                child: Text(
                  '+100 Coins/Day Active',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Balance Display (1 Rupee = 100 AUG Coins)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '🪙 ${_formatCoins(coins)}',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: HeritageTheme.goldBright,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AUG Coins',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HeritageTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'INR Valuation: ₹${inrValuation.toStringAsFixed(2)}  (Ratio: 1 Rupee = 100 AUG Coins)',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF86A79F),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: HeritageTheme.goldBorderSubtle, thickness: 0.6),
          const SizedBox(height: 12),

          // Action Buttons: Buy AUG Coins & Manual Coin Creation
          Row(
            children: [
              // Buy AUG Coins (Step 9)
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onOpenRecharge != null) {
                      widget.onOpenRecharge!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AthiraiRechargeScreen(store: widget.store),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageTheme.goldPrimary,
                    foregroundColor: const Color(0xFF030D0A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    'Buy AUG Coins',
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Manual Coin Generation (Step 7 #5)
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _showManualCoinDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HeritageTheme.goldBright,
                    side: const BorderSide(color: HeritageTheme.goldBorder, width: 0.9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: Text(
                    '+ Manual',
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF061B16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: HeritageTheme.goldBright, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Default Delivery Address',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.textLight,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showEditAddressModal(context),
                icon: const Icon(Icons.edit_outlined, size: 14, color: HeritageTheme.goldBright),
                label: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: HeritageTheme.goldBright,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.store.deliveryName,
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: HeritageTheme.textLight),
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.store.doorNo}, ${widget.store.streetName}, ${widget.store.town}, ${widget.store.city} - ${widget.store.pincode}, ${widget.store.state}',
            style: GoogleFonts.inter(fontSize: 11.5, color: HeritageTheme.textMutedDark, height: 1.4),
          ),
          const SizedBox(height: 2),
          Text(
            'Contact: ${widget.store.deliveryPhone}',
            style: GoogleFonts.inter(fontSize: 11, color: HeritageTheme.textMutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Athirai Services & Purchases',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: HeritageTheme.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _serviceTile(
                icon: Icons.receipt_long_rounded,
                title: 'Order Summary',
                subtitle: '${widget.store.myOrders.length} orders & receipts',
                color: const Color(0xFFD4AF37),
                onTap: () {
                  if (widget.onOpenOrders != null) {
                    widget.onOpenOrders!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthiraiOrderSummaryScreen(
                          store: widget.store,
                          onOpenMenu: widget.onOpenMenu,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _serviceTile(
                icon: Icons.diamond_rounded,
                title: 'Jewellery Atelier',
                subtitle: 'Browse collections',
                color: const Color(0xFF10B981),
                onTap: widget.onOpenCollection,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _serviceTile(
                icon: Icons.payment_rounded,
                title: 'Recharge Vault',
                subtitle: 'Buy AUG Coins via Razorpay',
                color: const Color(0xFF38BDF8),
                onTap: () {
                  if (widget.onOpenRecharge != null) {
                    widget.onOpenRecharge!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AthiraiRechargeScreen(store: widget.store),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _serviceTile(
                icon: Icons.favorite_border_rounded,
                title: 'Royal Wishlist',
                subtitle: '${widget.store.wishlistCount} saved pieces',
                color: const Color(0xFFF43F5E),
                onTap: widget.onOpenMenu,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF061B16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HeritageTheme.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: HeritageTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAddressModal(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.store.deliveryName);
    final phoneCtrl = TextEditingController(text: widget.store.deliveryPhone);
    final doorCtrl = TextEditingController(text: widget.store.doorNo);
    final streetCtrl = TextEditingController(text: widget.store.streetName);
    final townCtrl = TextEditingController(text: widget.store.town);
    final cityCtrl = TextEditingController(text: widget.store.city);
    final pinCtrl = TextEditingController(text: widget.store.pincode);
    final stateCtrl = TextEditingController(text: widget.store.state);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF04120E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: HeritageTheme.goldBorder, width: 1.2),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Delivery Address',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: HeritageTheme.textLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HeritageTheme.goldPrimary),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _addressField('Full Name', nameCtrl),
              const SizedBox(height: 10),
              _addressField('Contact Phone Number', phoneCtrl),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _addressField('Door / Flat No', doorCtrl)),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _addressField('Street Name', streetCtrl)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _addressField('Town / Locality', townCtrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _addressField('City', cityCtrl)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _addressField('Pincode', pinCtrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _addressField('State', stateCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.store.updateDeliveryAddress(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      doorNo: doorCtrl.text.trim(),
                      streetName: streetCtrl.text.trim(),
                      town: townCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                      pincode: pinCtrl.text.trim(),
                      state: stateCtrl.text.trim(),
                    );
                    Navigator.of(ctx).pop();
                    _showAddressSavedDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageTheme.goldPrimary,
                    foregroundColor: const Color(0xFF030D0A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Save Address Details',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSavedDialog(BuildContext context) {
    showDialog(
      context: context,
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
              'Address Saved!',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
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
              'விநியோக முகவரி வெற்றிகரமாக சேமிக்கப்பட்டது.',
              style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.goldBright),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.store.deliveryName} • ${widget.store.deliveryPhone}\n${widget.store.doorNo}, ${widget.store.streetName}, ${widget.store.city} - ${widget.store.pincode}',
              style: GoogleFonts.inter(fontSize: 12.5, color: HeritageTheme.textLight, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageTheme.goldPrimary,
              foregroundColor: const Color(0xFF041814),
            ),
            child: const Text('OK / சரி'),
          ),
        ],
      ),
    );
  }

  Widget _addressField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: HeritageTheme.textLight, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: HeritageTheme.textMutedDark, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF081C17),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: HeritageTheme.goldBorderSubtle, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: HeritageTheme.goldBorder, width: 1.2),
        ),
      ),
    );
  }

  /// Step 7 Point 5: Manual Coin Creation / Generation Dialog
  void _showManualCoinDialog() {
    final coinsCtrl = TextEditingController(text: '50000');
    final descCtrl = TextEditingController(text: 'Festival Patron Bonus');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF061B16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageTheme.goldBorder, width: 1.1),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: HeritageTheme.goldBright, size: 22),
            const SizedBox(width: 8),
            Text(
              'Manual Coin Generation',
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
              'Step 7 Point 5: Manually create and credit AUG Coins into your account vault (1 Rupee = 100 AUG Coins).',
              style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.textMutedDark, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: coinsCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: HeritageTheme.textLight),
              decoration: const InputDecoration(
                labelText: 'AUG Coins to Generate',
                hintText: 'e.g. 50000 (= ₹500)',
                filled: true,
                fillColor: Color(0xFF030D0A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: HeritageTheme.textLight),
              decoration: const InputDecoration(
                labelText: 'Source / Reason',
                filled: true,
                fillColor: Color(0xFF030D0A),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: HeritageTheme.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(coinsCtrl.text) ?? 1000.0;
              Navigator.of(dialogCtx).pop();
              await widget.store.manualCreditAUGCoins(
                coins: amount,
                amountInr: amount / 100.0,
                source: descCtrl.text.trim(),
              );
              if (!mounted) return;
              _showCoinGeneratedSuccessDialog(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageTheme.goldPrimary,
              foregroundColor: const Color(0xFF030D0A),
            ),
            child: const Text('Generate & Credit'),
          ),
        ],
      ),
    );
  }

  void _showCoinGeneratedSuccessDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF061B16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageTheme.goldBorder, width: 1.1),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: HeritageTheme.goldBright, size: 26),
            const SizedBox(width: 8),
            Text(
              'AUG Coins Credited!',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
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
              'AUG நாணயங்கள் கணக்கில் வரவு வைக்கப்பட்டது.',
              style: GoogleFonts.inter(fontSize: 12, color: HeritageTheme.goldBright),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF030D0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HeritageTheme.goldBorderSubtle, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+${_formatCoins(amount)} AUG Coins',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: HeritageTheme.goldBright),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gold Value: ₹${(amount / 100).toStringAsFixed(0)} (1 Rupee = 100 Coins)',
                    style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Vault: ${_formatCoins(widget.store.augCoins)} Coins',
                    style: GoogleFonts.inter(fontSize: 11, color: HeritageTheme.textMutedDark),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageTheme.goldPrimary,
              foregroundColor: const Color(0xFF041814),
            ),
            child: const Text('Done / முடிந்தது'),
          ),
        ],
      ),
    );
  }

  String _formatCoins(num number) {
    final str = number.toInt().toString();
    if (str.length <= 3) return str;
    return str.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
