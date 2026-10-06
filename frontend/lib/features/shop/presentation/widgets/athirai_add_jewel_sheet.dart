import 'package:flutter/material.dart';
import '../../domain/shop_store.dart';
import '../theme/heritage_theme.dart';

/// Modal bottom sheet to dynamically add a new jewellery piece & category to the live catalog.
class AthiraiAddJewelSheet extends StatefulWidget {
  const AthiraiAddJewelSheet({
    super.key,
    required this.store,
    this.onJewelAdded,
  });

  final ShopStore store;
  final ValueChanged<ShopProduct>? onJewelAdded;

  static Future<ShopProduct?> show(
    BuildContext context, {
    required ShopStore store,
    ValueChanged<ShopProduct>? onJewelAdded,
  }) {
    return showModalBottomSheet<ShopProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AthiraiAddJewelSheet(
          store: store,
          onJewelAdded: onJewelAdded,
        ),
      ),
    );
  }

  @override
  State<AthiraiAddJewelSheet> createState() => _AthiraiAddJewelSheetState();
}

class _AthiraiAddJewelSheetState extends State<AthiraiAddJewelSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: '32.50');
  final _makingChargeController = TextEditingController(text: '12');
  final _stonePriceController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  final _newCategoryController = TextEditingController();

  late String _selectedCategory;
  String _selectedPurity = '22K';
  String _selectedMetal = 'Gold';
  bool _isCreatingNewCategory = false;

  int _selectedImagePreset = 0;
  final List<Map<String, String>> _imagePresets = [
    {'name': 'Necklace', 'path': 'assets/images/heritage_necklace.png'},
    {'name': 'Ring', 'path': 'assets/images/shop_ring.png'},
    {'name': 'Bangle', 'path': 'assets/images/shop_bangle.png'},
    {'name': 'Earrings', 'path': 'assets/images/shop_earrings.png'},
    {'name': 'Gold Coins', 'path': 'assets/images/shop_gold_coins.png'},
    {'name': 'Silver Coins', 'path': 'assets/images/shop_silver_coins.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.store.categories.isNotEmpty
        ? widget.store.categories.first.name
        : 'Necklaces';

    _weightController.addListener(() => setState(() {}));
    _makingChargeController.addListener(() => setState(() {}));
    _stonePriceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _makingChargeController.dispose();
    _stonePriceController.dispose();
    _descriptionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // --- Dynamic Calculation Helpers ---
  double get _weight => double.tryParse(_weightController.text) ?? 0.0;
  double get _makingPercent => double.tryParse(_makingChargeController.text) ?? 12.0;
  int get _stonePrice => int.tryParse(_stonePriceController.text) ?? 0;

  double get _ratePerGram {
    final rates = widget.store.rates;
    if (_selectedMetal == 'Silver') return rates.silver999;
    switch (_selectedPurity) {
      case '24K':
        return rates.gold24k.toDouble();
      case '18K':
        return rates.gold18k.toDouble();
      case '22K':
      default:
        return rates.gold22k.toDouble();
    }
  }

  int get _goldComponent => (_weight * _ratePerGram).round();
  int get _makingCharges => (_goldComponent * (_makingPercent / 100.0)).round();
  int get _taxableAmount => _goldComponent + _makingCharges + _stonePrice;
  int get _gst => (_taxableAmount * 0.03).round();
  int get _estimatedTotal => _taxableAmount + _gst;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _isCreatingNewCategory && _newCategoryController.text.trim().isNotEmpty
        ? _newCategoryController.text.trim()
        : _selectedCategory;

    final imagePath = _imagePresets[_selectedImagePreset]['path']!;

    final product = widget.store.addJewel(
      name: _nameController.text.trim(),
      category: categoryName,
      purity: _selectedPurity,
      weightGrams: _weight,
      metal: _selectedMetal,
      makingChargePercent: _makingPercent,
      stonePrice: _stonePrice,
      image: imagePath,
      description: _descriptionController.text.trim(),
    );

    if (widget.onJewelAdded != null) {
      widget.onJewelAdded!(product);
    }

    Navigator.pop(context, product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF073B3F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFD978), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "${product.name}" ($categoryName) at ${rupees(product.price)} to live catalog!',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: HeritageTheme.creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Sheet Header with Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD6C8B8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HeritageTheme.maroon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: HeritageTheme.maroon, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Jewel & Category',
                        style: HeritageTheme.serif(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: HeritageTheme.ebony,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '100% Dynamic Pricing from Live Metal Rates',
                        style: HeritageTheme.sans(
                          fontSize: 11,
                          color: HeritageTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: HeritageTheme.ebony, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8DCCB)),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Jewel Name
                    _buildLabel('Jewel Name / Title'),
                    TextFormField(
                      controller: _nameController,
                      style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: _inputDecoration('e.g. Kalyani Temple Choker'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter jewel name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Category Selection & Add Category Inline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Category'),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isCreatingNewCategory = !_isCreatingNewCategory;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCreatingNewCategory ? Icons.list_rounded : Icons.add_circle_outline_rounded,
                                  size: 14,
                                  color: HeritageTheme.maroon,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isCreatingNewCategory ? 'Pick Existing' : '+ New Category',
                                  style: HeritageTheme.sans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: HeritageTheme.maroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_isCreatingNewCategory) ...[
                      TextFormField(
                        controller: _newCategoryController,
                        style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration('Enter new category (e.g. Chokers, Solitaire)'),
                        validator: (val) {
                          if (_isCreatingNewCategory && (val == null || val.trim().isEmpty)) {
                            return 'Enter new category name';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8DCCB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.store.categories.any((c) => c.name == _selectedCategory)
                                ? _selectedCategory
                                : widget.store.categories.first.name,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: HeritageTheme.ebony),
                            items: widget.store.categories.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.name,
                                child: Text(c.name, style: HeritageTheme.sans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // 3. Metal & Purity Selection
                    _buildLabel('Metal Purity'),
                    Row(
                      children: [
                        _buildPurityOption('22K', 'Gold', '22K (916)'),
                        const SizedBox(width: 8),
                        _buildPurityOption('24K', 'Gold', '24K (999)'),
                        const SizedBox(width: 8),
                        _buildPurityOption('18K', 'Gold', '18K (750)'),
                        const SizedBox(width: 8),
                        _buildPurityOption('999', 'Silver', 'Silver 999'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. Net Weight & Making Charge Row
                    Row(
                      children: [
                        // Net Weight
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Net Weight (grams)'),
                              TextFormField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: _inputDecoration('e.g. 44.20', suffix: 'gm'),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                                    return 'Enter valid weight';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Wastage / Making Charges %
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Making / VA (%)'),
                              TextFormField(
                                controller: _makingChargeController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: _inputDecoration('12', suffix: '%'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Gemstone Price (Optional)
                    _buildLabel('Gemstones / Diamonds Value (Optional ₹)'),
                    TextFormField(
                      controller: _stonePriceController,
                      keyboardType: TextInputType.number,
                      style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: _inputDecoration('0', prefix: '₹ '),
                    ),
                    const SizedBox(height: 16),

                    // 6. Visual Image Preset
                    _buildLabel('Jewel Visual Preset'),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imagePresets.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedImagePreset;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedImagePreset = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? HeritageTheme.maroon : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? HeritageTheme.maroon : const Color(0xFFE8DCCB),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    _imagePresets[index]['path']!,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.diamond_outlined, size: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _imagePresets[index]['name']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : HeritageTheme.ebony,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. Description
                    _buildLabel('Artisan Notes / Description (Optional)'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      style: HeritageTheme.sans(fontSize: 13),
                      decoration: _inputDecoration('Describe craftsmanship, temple motifs, or hallmark details...'),
                    ),
                    const SizedBox(height: 20),

                    // 8. Dynamic Live Price Calculator Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF073B3F), Color(0xFF0F565C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFCCA881), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF073B3F).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'DYNAMIC PRICE BREAKDOWN',
                                style: TextStyle(
                                  color: Color(0xFFCCA881),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Live: ₹${_ratePerGram.toInt()}/g',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildBreakdownRow('Pure Metal Component (${_weight}g × ₹${_ratePerGram.toInt()}):', rupees(_goldComponent)),
                          _buildBreakdownRow('Making Charges ($_makingPercent%):', rupees(_makingCharges)),
                          if (_stonePrice > 0)
                            _buildBreakdownRow('Gemstone / Diamond Value:', rupees(_stonePrice)),
                          _buildBreakdownRow('GST (3% Indian Bullion):', rupees(_gst)),
                          const Divider(height: 18, color: Color(0x40CCA881)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Selling Price:',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                rupees(_estimatedTotal),
                                style: const TextStyle(
                                  color: Color(0xFFFFD978),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 9. Save & Publish Action
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeritageTheme.maroon,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFFFFD978), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Publish Jewel to Catalog (${rupees(_estimatedTotal)})',
                              style: HeritageTheme.sans(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: HeritageTheme.sans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5A483C)),
      ),
    );
  }

  Widget _buildPurityOption(String purity, String metal, String label) {
    final isSelected = _selectedPurity == purity && _selectedMetal == metal;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPurity = purity;
            _selectedMetal = metal;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? HeritageTheme.maroon : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? HeritageTheme.maroon : const Color(0xFFE8DCCB),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : HeritageTheme.ebony,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFDCD2C6), fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? suffix, String? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0A292), fontSize: 13),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: HeritageTheme.maroon, fontWeight: FontWeight.bold),
      prefixText: prefix,
      prefixStyle: const TextStyle(color: HeritageTheme.maroon, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DCCB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8DCCB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HeritageTheme.maroon, width: 1.5),
      ),
    );
  }
}
