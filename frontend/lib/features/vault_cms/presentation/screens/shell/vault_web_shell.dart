import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';

import '../analytics/vault_analytics_screen.dart';
import '../categories/vault_categories_screen.dart';
import '../collections/vault_collections_screen.dart';
import '../customers/vault_customers_screen.dart';
import '../dashboard/vault_dashboard_screen.dart';
import '../inventory/vault_inventory_screen.dart';
import '../orders/vault_orders_screen.dart';
import '../products/create_product_workflow_screen.dart';
import '../products/product_detail_screen.dart';
import '../products/products_list_screen.dart';
import '../settings/vault_settings_screen.dart';
import '../vault/jewel_vault_constellation_screen.dart';

class VaultWebShell extends StatefulWidget {
  const VaultWebShell({
    super.key,
    required this.apiService,
    this.initialPageIndex = 0,
    required this.onSwitchToClientExperience,
    required this.onSignOut,
  });

  final VaultApiService apiService;
  final int initialPageIndex;
  final VoidCallback onSwitchToClientExperience;
  final VoidCallback onSignOut;

  @override
  State<VaultWebShell> createState() => _VaultWebShellState();
}

class _VaultWebShellState extends State<VaultWebShell> {
  late int _selectedPageIndex;
  bool _isSidebarCollapsed = false;

  // Sub-navigation overlays for Product Detail and Workflow
  VaultProduct? _viewingProduct;
  VaultProduct? _editingProduct;
  bool _isInWorkflow = false;

  VaultMetalRates _metalRates = const VaultMetalRates();

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.initialPageIndex;
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    final r = await widget.apiService.getMetalRates();
    if (mounted) setState(() => _metalRates = r);
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      _viewingProduct = null;
      _editingProduct = null;
      _isInWorkflow = (index == 2);
    });
  }

  void _openProductDetail(VaultProduct product) {
    setState(() {
      _viewingProduct = product;
      _editingProduct = null;
      _isInWorkflow = false;
    });
  }

  void _openEditProduct(VaultProduct product) {
    setState(() {
      _editingProduct = product;
      _viewingProduct = null;
      _isInWorkflow = true;
    });
  }

  void _openCreateNewWorkflow() {
    setState(() {
      _editingProduct = null;
      _viewingProduct = null;
      _isInWorkflow = true;
      _selectedPageIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultTokens.surfaceBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient Canvas
          Container(
            decoration: const BoxDecoration(
              gradient: VaultTokens.emeraldCanvasGradient,
            ),
          ),

          // Main Responsive Shell Layout
          Row(
            children: [
              // ── Collapsible Luxury Sidebar ─────────────────────────────────
              _buildSidebar(),

              // ── Main Content Area ──────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    _buildTopHeaderBar(),
                    Expanded(
                      child: _buildMainBody(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final sidebarWidth = _isSidebarCollapsed ? 76.0 : 256.0;

    final navItems = [
      {'index': 0, 'label': 'Experience Dashboard', 'icon': Icons.dashboard_outlined},
      {'index': 1, 'label': 'Masterpiece Catalog', 'icon': Icons.diamond_outlined},
      {'index': 2, 'label': 'Design New Jewel', 'icon': Icons.add_circle_outline},
      {'index': 3, 'label': 'Royal Collections', 'icon': Icons.temple_hindu_outlined},
      {'index': 4, 'label': 'Ornament Categories', 'icon': Icons.category_outlined},
      {'index': 5, 'label': 'Vault Inventory', 'icon': Icons.inventory_2_outlined},
      {'index': 6, 'label': 'Bespoke Orders', 'icon': Icons.shopping_bag_outlined},
      {'index': 7, 'label': 'VIP Patrons', 'icon': Icons.people_outline},
      {'index': 8, 'label': 'Constellation Vault', 'icon': Icons.all_inclusive},
      {'index': 9, 'label': 'Sales Analytics', 'icon': Icons.insights_outlined},
      {'index': 10, 'label': 'Atelier Settings', 'icon': Icons.settings_outlined},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: const Color(0x8004120E),
        border: const Border(
          right: BorderSide(color: VaultTokens.borderGoldMuted, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Crest Header
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/athirai_emerald_crest.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.diamond, color: VaultTokens.antiqueGold, size: 30),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATHIRAI',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: VaultTokens.warmIvory,
                        ),
                      ),
                      Text(
                        'JEWEL VAULT CMS',
                        style: VaultTokens.brandLabel(fontSize: 8.5, letterSpacing: 1.5, color: VaultTokens.champagneGold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: VaultTokens.borderGoldMuted, height: 1),

          // Navigation Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final itemIdx = item['index'] as int;
                final isSelected = !_isInWorkflow && _viewingProduct == null && _selectedPageIndex == itemIdx;
                final icon = item['icon'] as IconData;
                final label = item['label'] as String;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => _navigateToPage(itemIdx),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0x400C2E25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? VaultTokens.champagneGold : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: isSelected ? VaultTokens.champagneGold : VaultTokens.sageMuted,
                          ),
                          if (!_isSidebarCollapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? VaultTokens.warmIvory : VaultTokens.sageLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Collapse Toggle & Sign Out
          const Divider(color: VaultTokens.borderGoldMuted, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: VaultTokens.sageLight,
                  ),
                  onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  tooltip: _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                ),
                if (!_isSidebarCollapsed)
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFE57373), size: 18),
                    onPressed: widget.onSignOut,
                    tooltip: 'Sign Out',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0x6604120E),
        border: Border(
          bottom: BorderSide(color: VaultTokens.borderGoldMuted, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Live Gold Ticker Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x400A2520),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VaultTokens.borderGoldMuted),
            ),
            child: Row(
              children: [
                const Icon(Icons.fiber_manual_record, color: Color(0xFF66BB6A), size: 10),
                const SizedBox(width: 8),
                Text(
                  '22K GOLD: ₹${_metalRates.gold22k}/g  •  24K: ₹${_metalRates.gold24k}/g  •  SILVER: ₹${_metalRates.silver999}/g',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: VaultTokens.champagneGold),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Switch to Client Experience Mode Button
          LuxuryCapsuleButton(
            label: 'Open Mobile Client App',
            icon: Icons.phone_iphone,
            onPressed: widget.onSwitchToClientExperience,
          ),
          const SizedBox(width: 14),

          // User Profile Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x400C2C24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VaultTokens.borderGoldMuted),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/athirai_profile_avatar.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 20, color: VaultTokens.antiqueGold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ananya Sharma',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBody() {
    // If user is currently editing or creating in workflow:
    if (_isInWorkflow) {
      return CreateProductWorkflowScreen(
        apiService: widget.apiService,
        initialProduct: _editingProduct,
        onFinished: (saved) {
          setState(() {
            _isInWorkflow = false;
            _editingProduct = null;
            _viewingProduct = saved;
          });
        },
        onCancel: () {
          setState(() {
            _isInWorkflow = false;
            _editingProduct = null;
          });
        },
      );
    }

    // If user clicked a product to inspect full details:
    if (_viewingProduct != null) {
      return ProductDetailScreen(
        product: _viewingProduct!,
        onBack: () => setState(() => _viewingProduct = null),
        onEdit: (p) => _openEditProduct(p),
        onAcquireOrder: (p) async {
          await widget.apiService.createOrder({
            'product_name': p.name,
            'total_amount': p.calculatedTotalPrice,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF092620),
                content: Text('Order commissioned for ${p.name}', style: const TextStyle(color: VaultTokens.champagneGold)),
              ),
            );
          }
        },

      );
    }

    // Standard sidebar tab pages
    switch (_selectedPageIndex) {
      case 0:
        return VaultDashboardScreen(
          apiService: widget.apiService,
          onNavigateTo: _navigateToPage,
        );
      case 1:
        return ProductsListScreen(
          apiService: widget.apiService,
          onCreateNew: _openCreateNewWorkflow,
          onSelectProduct: _openProductDetail,
          onEditProduct: _openEditProduct,
        );
      case 2:
        return CreateProductWorkflowScreen(
          apiService: widget.apiService,
          onFinished: (saved) {
            setState(() {
              _isInWorkflow = false;
              _viewingProduct = saved;
            });
          },
          onCancel: () => _navigateToPage(1),
        );
      case 3:
        return VaultCollectionsScreen(
          apiService: widget.apiService,
          onOpenCollection: (colName) => _navigateToPage(1),
        );
      case 4:
        return VaultCategoriesScreen(
          onSelectCategory: (catName) => _navigateToPage(1),
        );
      case 5:
        return VaultInventoryScreen(
          apiService: widget.apiService,
        );
      case 6:
        return VaultOrdersScreen(
          apiService: widget.apiService,
        );
      case 7:
        return VaultCustomersScreen(
          apiService: widget.apiService,
        );
      case 8:
        return JewelVaultConstellationScreen(
          apiService: widget.apiService,
          onSelectProduct: _openProductDetail,
        );
      case 9:
        return VaultAnalyticsScreen(
          apiService: widget.apiService,
        );
      case 10:
        return VaultSettingsScreen(
          apiService: widget.apiService,
        );
      default:
        return VaultDashboardScreen(
          apiService: widget.apiService,
          onNavigateTo: _navigateToPage,
        );
    }
  }
}
