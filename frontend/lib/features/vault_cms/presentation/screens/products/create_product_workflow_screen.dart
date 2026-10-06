import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/data/models/vault_models.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_inputs.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_status_badge.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_step_indicator.dart';


class CreateProductWorkflowScreen extends StatefulWidget {
  const CreateProductWorkflowScreen({
    super.key,
    required this.apiService,
    this.initialProduct,
    required this.onFinished,
    required this.onCancel,
  });

  final VaultApiService apiService;
  final VaultProduct? initialProduct;
  final ValueChanged<VaultProduct> onFinished;
  final VoidCallback onCancel;

  @override
  State<CreateProductWorkflowScreen> createState() => _CreateProductWorkflowScreenState();
}

class _CreateProductWorkflowScreenState extends State<CreateProductWorkflowScreen> {
  int _currentStep = 1;
  bool _isSaving = false;

  // Step 1: Basic Info
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _descController;
  String _selectedCategory = 'Necklace';
  String _selectedCollection = 'Chola Dynasty';

  // Step 2: Media
  late final TextEditingController _heroImageController;
  late final TextEditingController _lifestyleImageController;

  // Step 3: Material & Craftsmanship
  String _selectedMetal = 'Gold';
  String _selectedPurity = '22K';
  double _weightGrams = 42.5;
  late final TextEditingController _gemstonesController;
  late final TextEditingController _gemstoneTypeController;
  late final TextEditingController _gemstoneWeightController;
  late final TextEditingController _diamondCaratController;
  late final TextEditingController _certificationController;
  late final TextEditingController _hallmarkController;
  late final TextEditingController _craftsmanshipController;
  late final TextEditingController _originController;
  late final TextEditingController _designerController;
  late final TextEditingController _craftingTimeController;

  // Step 4: Pricing
  double _makingChargePercent = 12.0;
  int _stonePrice = 45000;
  int _goldRatePerGram = 7450; // 22K default

  // Step 5: Inventory
  int _stockQuantity = 5;
  int _lowStockThreshold = 2;
  String _warehouse = 'Chennai Flagship Jewel Vault';
  String _status = 'Published';
  String _availability = 'Ready to Ship';

  // Step 6: Variants
  final List<String> _selectedSizes = ['16 Inch (Choker)', '18 Inch (Princess)'];
  final List<String> _selectedFinishes = ['Antique Temple Matte', 'High Polish Gold'];
  bool _customEngravingAvailable = true;

  // Step 7: SEO
  late final TextEditingController _seoTitleController;
  late final TextEditingController _metaDescController;
  late final TextEditingController _urlSlugController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;

    _nameController = TextEditingController(text: p?.name ?? 'Temple Blossom Necklace');
    _skuController = TextEditingController(text: p?.sku ?? 'ATH-NECK-001');
    _shortDescController = TextEditingController(text: p?.shortDescription ?? 'Intricate temple necklace sculpted with divine floral motifs.');
    _descController = TextEditingController(text: p?.description ?? 'Handcrafted by 4th-generation Thanjavur goldsmiths, this museum-grade jewel features temple floral motifs set with natural Burmese rubies and uncut Polki diamonds.');
    _selectedCategory = p?.category ?? 'Necklace';
    _selectedCollection = p?.collection.isNotEmpty == true ? p!.collection : 'Chola Dynasty';

    _heroImageController = TextEditingController(text: p?.imageUrl ?? 'assets/images/athirai_pedestal_necklace.jpg');
    _lifestyleImageController = TextEditingController(text: p?.lifestyleImageUrl ?? 'assets/images/athirai_front_model.jpg');

    _selectedMetal = p?.metal ?? 'Gold';
    _selectedPurity = p?.purity ?? '22K';
    _weightGrams = p?.weightGrams ?? 42.5;
    _gemstonesController = TextEditingController(text: p?.gemstones ?? 'Burmese Rubies, Zambian Emeralds & Basra Pearls');
    _gemstoneTypeController = TextEditingController(text: p?.gemstoneType ?? 'Natural Unheated Gems');
    _gemstoneWeightController = TextEditingController(text: p?.gemstoneWeight ?? '8.40 Carats');
    _diamondCaratController = TextEditingController(text: p?.diamondCarat ?? '1.20 ct Polki Uncut Diamonds');
    _certificationController = TextEditingController(text: p?.certification ?? 'IGI Certified Heritage Grade A+');
    _hallmarkController = TextEditingController(text: p?.hallmark ?? 'BIS 916 Hallmarked Pure 22 Karat Gold');
    _craftsmanshipController = TextEditingController(text: p?.craftsmanship ?? 'Handcrafted Chola Nakshi & Jadau filigree');
    _originController = TextEditingController(text: p?.origin ?? 'Thanjavur, Tamil Nadu Heritage Atelier');
    _designerController = TextEditingController(text: p?.designer ?? 'Master Artisan K. Ramanathan');
    _craftingTimeController = TextEditingController(text: p?.craftingTime ?? '120 Hours of Master Goldsmithing');

    _makingChargePercent = p?.makingChargePercent ?? 12.0;
    _stonePrice = p?.stonePrice ?? 45000;

    _stockQuantity = p?.stockQuantity ?? 5;
    _lowStockThreshold = p?.lowStockThreshold ?? 2;
    _warehouse = p?.warehouse ?? 'Chennai Flagship Jewel Vault';
    _status = p?.status ?? 'Published';
    _availability = p?.availability ?? 'Ready to Ship';

    _seoTitleController = TextEditingController(text: p?.seoTitle.isNotEmpty == true ? p!.seoTitle : '${_nameController.text} | Athirai Heritage Jewels');
    _metaDescController = TextEditingController(text: p?.metaDescription.isNotEmpty == true ? p!.metaDescription : _shortDescController.text);
    _urlSlugController = TextEditingController(text: p?.urlSlug.isNotEmpty == true ? p!.urlSlug : 'temple-blossom-necklace');
    _tagsController = TextEditingController(text: p?.tags ?? 'temple, bridal, 22k gold, necklace, royal');

    _fetchLiveRates();
  }

  Future<void> _fetchLiveRates() async {
    final rates = await widget.apiService.getMetalRates();
    if (mounted) {
      setState(() {
        if (_selectedPurity.contains('24')) {
          _goldRatePerGram = rates.gold24k;
        } else if (_selectedPurity.contains('18')) {
          _goldRatePerGram = rates.gold18k;
        } else {
          _goldRatePerGram = rates.gold22k;
        }
      });
    }
  }

  int get _calculatedMetalCost => (_weightGrams * _goldRatePerGram).round();
  int get _calculatedMakingCharges => (_calculatedMetalCost * (_makingChargePercent / 100)).round();
  int get _calculatedSubtotal => _calculatedMetalCost + _calculatedMakingCharges + _stonePrice;
  int get _calculatedGst => (_calculatedSubtotal * 0.03).round();
  int get _calculatedTotalPrice => _calculatedSubtotal + _calculatedGst;

  void _nextStep() {
    if (_currentStep < 9) {
      setState(() => _currentStep++);
    } else {
      _saveProduct();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveProduct() async {
    setState(() => _isSaving = true);

    final productToSave = VaultProduct(
      id: widget.initialProduct?.id ?? 0,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      collection: _selectedCollection,
      sku: _skuController.text.trim(),
      metal: _selectedMetal,
      purity: _selectedPurity,
      weightGrams: _weightGrams,
      makingChargePercent: _makingChargePercent,
      stonePrice: _stonePrice,
      gemstones: _gemstonesController.text.trim(),
      gemstoneType: _gemstoneTypeController.text.trim(),
      gemstoneWeight: _gemstoneWeightController.text.trim(),
      diamondCarat: _diamondCaratController.text.trim(),
      certification: _certificationController.text.trim(),
      hallmark: _hallmarkController.text.trim(),
      craftsmanship: _craftsmanshipController.text.trim(),
      origin: _originController.text.trim(),
      designer: _designerController.text.trim(),
      craftingTime: _craftingTimeController.text.trim(),
      stockQuantity: _stockQuantity,
      lowStockThreshold: _lowStockThreshold,
      warehouse: _warehouse,
      status: _status,
      availability: _availability,
      seoTitle: _seoTitleController.text.trim(),
      metaDescription: _metaDescController.text.trim(),
      urlSlug: _urlSlugController.text.trim(),
      tags: _tagsController.text.trim(),
      shortDescription: _shortDescController.text.trim(),
      description: _descController.text.trim(),
      imageUrl: _heroImageController.text.trim(),
      lifestyleImageUrl: _lifestyleImageController.text.trim(),
      calculatedTotalPrice: _calculatedTotalPrice,
      calculatedMetalCost: _calculatedMetalCost,
      calculatedMakingCharges: _calculatedMakingCharges,
      calculatedGst: _calculatedGst,
    );

    VaultProduct saved;
    if (widget.initialProduct != null && widget.initialProduct!.id > 0) {
      saved = await widget.apiService.updateProduct(productToSave);
    } else {
      saved = await widget.apiService.createProduct(productToSave);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      widget.onFinished(saved);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _heroImageController.dispose();
    _lifestyleImageController.dispose();
    _gemstonesController.dispose();
    _gemstoneTypeController.dispose();
    _gemstoneWeightController.dispose();
    _diamondCaratController.dispose();
    _certificationController.dispose();
    _hallmarkController.dispose();
    _craftsmanshipController.dispose();
    _originController.dispose();
    _designerController.dispose();
    _craftingTimeController.dispose();
    _seoTitleController.dispose();
    _metaDescController.dispose();
    _urlSlugController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CRAFTSMANSHIP WORKFLOW',
                    style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 2.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.initialProduct == null ? 'Design New Heritage Masterpiece' : 'Edit Piece Specifications',
                    style: VaultTokens.headlineDisplay(fontSize: 28),
                  ),
                ],
              ),
              LuxuryCapsuleButton(
                label: 'Cancel Workflow',
                icon: Icons.close,
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── 9-Step Timeline Indicator ──────────────────────────────────────
          LuxuryStepIndicator(
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
          ),
          const SizedBox(height: 28),

          // ── Active Step Card ───────────────────────────────────────────────
          LuxuryGlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 20,
            child: _buildStepContent(),
          ),
          const SizedBox(height: 24),

          // ── Bottom Navigation Controls ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 1)
                LuxuryCapsuleButton(
                  label: '← Back Step',
                  onPressed: _prevStep,
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  if (_currentStep < 9)
                    LuxuryCapsuleButton(
                      label: 'Save as Draft',
                      icon: Icons.save_outlined,
                      onPressed: () {
                        setState(() => _status = 'Draft');
                        _saveProduct();
                      },
                    ),
                  const SizedBox(width: 14),
                  LuxuryGoldPillButton(
                    label: _currentStep == 9
                        ? (_isSaving ? 'PUBLISHING TO VAULT...' : 'PUBLISH TO VAULT')
                        : 'NEXT: STEP ${_currentStep + 1} →',
                    icon: _currentStep == 9 ? Icons.check_circle : Icons.arrow_forward,
                    isLoading: _isSaving,
                    onPressed: _nextStep,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1BasicInfo();
      case 2:
        return _buildStep2Media();
      case 3:
        return _buildStep3Specifications();
      case 4:
        return _buildStep4Pricing();
      case 5:
        return _buildStep5Inventory();
      case 6:
        return _buildStep6Variants();
      case 7:
        return _buildStep7SEO();
      case 8:
        return _buildStep8Preview();
      case 9:
        return _buildStep9Publish();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Basic Information ─────────────────────────────────────────────
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('01 / BASIC INFORMATION', 'Define the identity, naming, and collection lineage of this jewel.'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: LuxuryTextField(
                label: 'MASTERPIECE NAME',
                controller: _nameController,
                hintText: 'e.g. Temple Blossom Necklace',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LuxuryTextField(
                      label: 'SKU CODE',
                      controller: _skuController,
                      hintText: 'ATH-NECK-001',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: VaultTokens.champagneGold),
                      tooltip: 'Auto-generate SKU',
                      onPressed: () {
                        final prefix = _selectedCategory.substring(0, 4).toUpperCase();
                        final random = (100 + DateTime.now().millisecond % 900);
                        _skuController.text = 'ATH-$prefix-$random';
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'JEWELLERY CATEGORY',
                value: _selectedCategory,
                items: ['Necklace', 'Rings', 'Bangles', 'Earrings', 'Bridal Sets', 'Gold Coins']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'HERITAGE COLLECTION',
                value: _selectedCollection,
                items: ['Chola Dynasty', 'Temple Blossoms', 'Navratna Heritage', 'Bridal Elegance', 'Celestial Polki']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCollection = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'SHORT EDITORIAL TAGLINE',
          controller: _shortDescController,
          hintText: 'A sentence summarizing the aesthetic inspiration for patrons.',
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'COMPLETE CRAFTSMANSHIP NARRATIVE',
          controller: _descController,
          maxLines: 4,
          hintText: 'Describe the heritage techniques, historical inspiration, gemstone sourcing, and goldsmith lineage...',
        ),
      ],
    );
  }

  // ── Step 2: Media & Imagery ───────────────────────────────────────────────
  Widget _buildStep2Media() {
    final presetImages = [
      {'name': 'Pedestal Temple Blossom', 'path': 'assets/images/athirai_pedestal_necklace.jpg'},
      {'name': 'Orbital Sphere Choker', 'path': 'assets/images/athirai_hero_sphere_necklace.jpg'},
      {'name': 'Lotus Grace Ring', 'path': 'assets/images/shop_ring.png'},
      {'name': 'Royal Mayura Bangles', 'path': 'assets/images/shop_bangle.png'},
      {'name': 'Celestial Chandbali', 'path': 'assets/images/shop_earrings.png'},
      {'name': 'Bridal Kasu Mala', 'path': 'assets/images/heritage_necklace.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('02 / MEDIA & PEDESTAL IMAGERY', 'Attach museum-grade studio photos, 360 pedestal views, and model lifestyle shots.'),
        const SizedBox(height: 24),
        LuxuryTextField(
          label: 'PRIMARY PEDESTAL IMAGE PATH / URL',
          controller: _heroImageController,
          hintText: 'assets/images/athirai_pedestal_necklace.jpg',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Text('Quick Select High-Resolution Atelier Assets:', style: VaultTokens.bodyText(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetImages.map((img) {
            return ActionChip(
              backgroundColor: const Color(0x33061A14),
              side: const BorderSide(color: VaultTokens.borderGoldMuted),
              label: Text(img['name']!, style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.champagneGold)),
              onPressed: () {
                setState(() => _heroImageController.text = img['path']!);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'ROYAL MODEL / LIFESTYLE IMAGE PATH / URL',
          controller: _lifestyleImageController,
          hintText: 'assets/images/athirai_front_model.jpg',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Text('LIVE ATELIER IMAGE PREVIEW:', style: VaultTokens.brandLabel(fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                  color: const Color(0xFF061A14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    _heroImageController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: VaultTokens.mutedGold, size: 36),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                  color: const Color(0xFF061A14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    _lifestyleImageController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.person_outline, color: VaultTokens.mutedGold, size: 36),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Material & Specifications ─────────────────────────────────────
  Widget _buildStep3Specifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('03 / MATERIAL & CRAFTSMANSHIP', 'Specify the precious metals, purity standards, gemstones, and artisan provenance.'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'PRECIOUS METAL',
                value: _selectedMetal,
                items: ['Gold', 'Rose Gold', 'Platinum', 'Silver']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMetal = val);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'PURITY STANDARD',
                value: _selectedPurity,
                items: ['24K Pure Gold (999)', '22K Traditional (916)', '18K Fine (750)', '925 Sterling Silver']
                    .map((p) => DropdownMenuItem(value: p.split(' ')[0], child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPurity = val;
                      _fetchLiveRates();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryTextField(
                label: 'GOLD WEIGHT (GRAMS)',
                initialValue: _weightGrams.toString(),
                keyboardType: TextInputType.number,
                suffixText: 'g',
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => _weightGrams = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: LuxuryTextField(
                label: 'PRECIOUS GEMSTONES EMBEDDED',
                controller: _gemstonesController,
                hintText: 'e.g. Burmese Rubies, Zambian Emeralds & Basra Pearls',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryTextField(
                label: 'POLKI / DIAMOND CARATS',
                controller: _diamondCaratController,
                hintText: '1.20 ct Polki Uncut',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: LuxuryTextField(
                label: 'HALLMARK CERTIFICATION',
                controller: _hallmarkController,
                hintText: 'BIS 916 Hallmarked Pure 22K',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryTextField(
                label: 'GEMOLOGICAL INSTITUTE',
                controller: _certificationController,
                hintText: 'IGI Certified Heritage Grade A+',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: LuxuryTextField(
                label: 'ATELIER ORIGIN',
                controller: _originController,
                hintText: 'Thanjavur, Tamil Nadu Heritage Atelier',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryTextField(
                label: 'MASTER GOLDSMITH / DESIGNER',
                controller: _designerController,
                hintText: 'Master Artisan K. Ramanathan',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryTextField(
                label: 'CRAFTING TIME',
                controller: _craftingTimeController,
                hintText: '120 Hours of Master Craftsmanship',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 4: Dynamic Bullion Pricing ───────────────────────────────────────
  Widget _buildStep4Pricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('04 / DYNAMIC PRICING & BULLION ENGINE', 'Pricing is computed dynamically using live Chennai bullion rates, weight, and craftsmanship.'),
        const SizedBox(height: 24),

        // Live Rate Indicator Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x400B2925),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VaultTokens.borderGoldBright.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: VaultTokens.champagneGold, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTIVE BULLION RATE APPLIED', style: VaultTokens.brandLabel(fontSize: 10)),
                      Text(
                        '₹$_goldRatePerGram per gram ($_selectedPurity Gold)',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: VaultTokens.warmIvory),
                      ),
                    ],
                  ),
                ],
              ),
              LuxuryStatusBadge(status: 'Auto Sync Active'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MAKING CHARGES (%)', style: VaultTokens.brandLabel(fontSize: 11)),
                      Text('${_makingChargePercent.toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                    ],
                  ),
                  Slider(
                    value: _makingChargePercent,
                    min: 5.0,
                    max: 30.0,
                    divisions: 50,
                    activeColor: VaultTokens.champagneGold,
                    inactiveColor: const Color(0xFF0C2C24),
                    onChanged: (val) => setState(() => _makingChargePercent = val),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: LuxuryTextField(
                label: 'PRECIOUS GEMSTONE VALUE (₹)',
                initialValue: _stonePrice.toString(),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null) setState(() => _stonePrice = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Real-Time Transparent Price Breakdown Table
        Text('TRANSPARENT CLIENT PRICING BREAKDOWN:', style: VaultTokens.brandLabel(fontSize: 10.5, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x55061A14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
          ),
          child: Column(
            children: [
              _buildPriceRow('Metal Cost (${_weightGrams}g @ ₹$_goldRatePerGram/g)', '₹$_calculatedMetalCost'),
              _buildPriceRow('Handcrafting & Filigree (${_makingChargePercent.toStringAsFixed(1)}%)', '₹$_calculatedMakingCharges'),
              _buildPriceRow('Embedded Gemstones & Basra Pearls', '₹$_stonePrice'),
              _buildPriceRow('Government GST (3%)', '₹$_calculatedGst'),
              const Divider(color: VaultTokens.borderGoldMuted, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL ESTIMATED VAULT VALUE:', style: VaultTokens.brandLabel(fontSize: 12, letterSpacing: 1.5)),
                  Text(
                    '₹$_calculatedTotalPrice  (₹${(_calculatedTotalPrice / 100000).toStringAsFixed(2)} Lakhs)',
                    style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: VaultTokens.champagneGold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: VaultTokens.sageLight)),
          Text(value, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
        ],
      ),
    );
  }

  // ── Step 5: Inventory & Logistics ─────────────────────────────────────────
  Widget _buildStep5Inventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('05 / INVENTORY & VAULT LOGISTICS', 'Manage available physical pieces, reserve safety stock, and assign vault location.'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: LuxuryCounterInput(
                label: 'PIECES IN STOCK',
                value: _stockQuantity,
                onChanged: (val) => setState(() => _stockQuantity = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryCounterInput(
                label: 'LOW STOCK THRESHOLD ALERT',
                value: _lowStockThreshold,
                onChanged: (val) => setState(() => _lowStockThreshold = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'VAULT WAREHOUSE LOCATION',
                value: _warehouse,
                items: [
                  'Chennai Flagship Jewel Vault',
                  'Bangalore Luxury Vault',
                  'Hyderabad Heritage Vault',
                  'Mumbai Flagship Vault',
                ].map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _warehouse = val);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'AVAILABILITY STATUS',
                value: _availability,
                items: ['Ready to Ship', 'Crafting in Atelier', 'Bespoke Order Only', 'Exhibition Display']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _availability = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 6: Variants & Customization ──────────────────────────────────────
  Widget _buildStep6Variants() {
    final availableSizes = ['14 Inch (Collar)', '16 Inch (Choker)', '18 Inch (Princess)', '20 Inch (Matinee)', '24 Inch (Opera)'];
    final availableFinishes = ['Antique Temple Matte', 'High Polish Gold', 'Dual Tone Gold & Silver', 'Rose Gold Infused'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('06 / SIZES, FINISHES & VARIANTS', 'Define customizable sizing and atelier finishes available to VIP patrons.'),
        const SizedBox(height: 24),
        Text('AVAILABLE LENGTHS / SIZES:', style: VaultTokens.brandLabel(fontSize: 10.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSizes.map((size) {
            final isSel = _selectedSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isSel,
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _selectedSizes.add(size);
                  } else {
                    _selectedSizes.remove(size);
                  }
                });
              },
              selectedColor: const Color(0x66C7A45B),
              backgroundColor: const Color(0x33061A14),
              labelStyle: GoogleFonts.inter(fontSize: 12, color: isSel ? VaultTokens.champagneGold : VaultTokens.sageLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('GOLD FINISHES:', style: VaultTokens.brandLabel(fontSize: 10.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableFinishes.map((f) {
            final isSel = _selectedFinishes.contains(f);
            return FilterChip(
              label: Text(f),
              selected: isSel,
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    _selectedFinishes.add(f);
                  } else {
                    _selectedFinishes.remove(f);
                  }
                });
              },
              selectedColor: const Color(0x66C7A45B),
              backgroundColor: const Color(0x33061A14),
              labelStyle: GoogleFonts.inter(fontSize: 12, color: isSel ? VaultTokens.champagneGold : VaultTokens.sageLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSel ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: _customEngravingAvailable,
          onChanged: (val) => setState(() => _customEngravingAvailable = val),
          title: Text('Complimentary Royal Custom Engraving', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
          subtitle: Text('Allow patrons to add bespoke Tamil Sanskrit or Devanagari seal inscriptions.', style: VaultTokens.bodyText(fontSize: 12)),
          activeColor: VaultTokens.champagneGold,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // ── Step 7: SEO & Discoverability ─────────────────────────────────────────
  Widget _buildStep7SEO() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('07 / SEARCH & SEO DISCOVERABILITY', 'Optimize piece metadata for luxury client discovery and private search catalogs.'),
        const SizedBox(height: 24),
        LuxuryTextField(
          label: 'PAGE META TITLE',
          controller: _seoTitleController,
          hintText: 'Temple Blossom Necklace | Athirai Timeless Jewels',
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'URL SLUG',
          controller: _urlSlugController,
          hintText: 'temple-blossom-necklace',
          prefixIcon: Icons.link,
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'META DESCRIPTION',
          controller: _metaDescController,
          maxLines: 3,
          hintText: 'Discover the Temple Blossom Necklace handcrafted with pure 22K gold, Burmese rubies and Polki diamonds...',
        ),
        const SizedBox(height: 20),
        LuxuryTextField(
          label: 'SEARCH TAGS (COMMA SEPARATED)',
          controller: _tagsController,
          hintText: 'temple, bridal, 22k gold, chola dynasty, necklace, rubies',
        ),
      ],
    );
  }

  // ── Step 8: Interactive Luxury Preview ────────────────────────────────────
  Widget _buildStep8Preview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('08 / INTERACTIVE CLIENT PREVIEW', 'Review the exact presentation how VIP patrons will encounter this masterpiece in their Jewel Vault.'),
        const SizedBox(height: 24),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: LuxuryGlassCard(
              padding: const EdgeInsets.all(0),
              borderRadius: 24,
              borderColor: VaultTokens.borderGoldBright,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.asset(
                            _heroImageController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF061A14),
                              child: const Icon(Icons.diamond, size: 64, color: VaultTokens.antiqueGold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: LuxuryStatusBadge(status: 'Certified Masterpiece'),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: VaultTokens.borderGoldMuted),
                            ),
                            child: Text('$_selectedMetal $_selectedPurity', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: VaultTokens.champagneGold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedCollection.toUpperCase(), style: VaultTokens.brandLabel(fontSize: 10, letterSpacing: 2.0)),
                        const SizedBox(height: 6),
                        Text(_nameController.text, style: VaultTokens.headlineDisplay(fontSize: 26)),
                        const SizedBox(height: 8),
                        Text(_shortDescController.text, style: VaultTokens.bodyText(fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ESTIMATED VAULT PRICE', style: VaultTokens.brandLabel(fontSize: 9.5)),
                                Text('₹$_calculatedTotalPrice', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: VaultTokens.champagneGold)),
                              ],
                            ),
                            LuxuryGoldPillButton(
                              label: 'REQUEST PIECE',
                              height: 40,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 9: Review & Publish ──────────────────────────────────────────────
  Widget _buildStep9Publish() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('09 / FINAL VERIFICATION & PUBLISH', 'Confirm all specifications before synchronizing with the central Django database.'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x40061A14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VaultTokens.borderGoldMuted),
          ),
          child: Column(
            children: [
              _buildChecklistRow('Masterpiece Title & SKU Code', '${_nameController.text} (${_skuController.text})', true),
              _buildChecklistRow('Category & Royal Collection', '$_selectedCategory • $_selectedCollection', true),
              _buildChecklistRow('Metal Specifications', '$_selectedMetal $_selectedPurity • ${_weightGrams}g', true),
              _buildChecklistRow('Certification & Hallmark', '${_hallmarkController.text} • ${_certificationController.text}', true),
              _buildChecklistRow('Dynamic Pricing Breakdown', '₹$_calculatedTotalPrice (incl. GST & Making Charges)', true),
              _buildChecklistRow('Inventory Allocation', '$_stockQuantity units assigned to $_warehouse', true),
              _buildChecklistRow('Atelier Artisan Lineage', '${_designerController.text} (${_craftingTimeController.text})', true),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: LuxuryDropdown<String>(
                label: 'PUBLICATION STATUS',
                value: _status,
                items: ['Published', 'Draft', 'Archived']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistRow(String title, String detail, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(checked ? Icons.check_circle : Icons.circle_outlined, color: checked ? const Color(0xFF66BB6A) : VaultTokens.sageMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: VaultTokens.warmIvory)),
                Text(detail, style: GoogleFonts.inter(fontSize: 11.5, color: VaultTokens.sageMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String subtitle, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: VaultTokens.brandLabel(fontSize: 11, letterSpacing: 2.0)),
        const SizedBox(height: 4),
        Text(title, style: VaultTokens.titleSerif(fontSize: 18)),
      ],
    );
  }
}
