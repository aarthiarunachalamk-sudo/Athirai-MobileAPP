from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from accounts.models import (
    Organization,
    MetalRate,
    JewelCategory,
    JewelCollection,
    JewelProduct,
    JewelVariant,
    JewelOrder,
    JewelCustomer,
    JewelVaultItem,
)

User = get_user_model()

class Command(BaseCommand):
    help = 'Seeds luxury collections, products, variants, orders, customers, and vault items for Athirai'

    def handle(self, *args, **options):
        self.stdout.write("Seeding Athirai luxury vault CMS data...")

        # 1. Seed Organizations
        orgs = [
            {'name': 'Athirai Global Royal Vault', 'domain': 'athirai.com', 'provider': 'microsoft', 'authorization_url': '/api/auth/mock-idp/authorize/'},
            {'name': 'Acme Luxury Enterprise', 'domain': 'company.com', 'provider': 'microsoft', 'authorization_url': '/api/auth/mock-idp/authorize/'},
        ]
        for org_data in orgs:
            Organization.objects.update_or_create(domain=org_data['domain'], defaults=org_data)

        # 2. Seed Admin & Patron User
        if not User.objects.filter(email='admin@athirai.com').exists():
            User.objects.create_superuser(
                email='admin@athirai.com',
                password='adminpassword123',
                full_name='Ananya Sharma',
                mobile_number='+91 98765 00000'
            )
            self.stdout.write("  Created superuser: admin@athirai.com / Ananya Sharma")

        patron = User.objects.filter(email='ananya.sharma@athirai.com').first()
        if not patron:
            existing_phone = User.objects.filter(mobile_number='+91 98765 43210').first()
            phone = '+91 98765 99887' if existing_phone else '+91 98765 43210'
            User.objects.create_user(
                email='ananya.sharma@athirai.com',
                password='password123',
                full_name='Ananya Sharma',
                mobile_number=phone,
                is_profile_completed=True
            )
            self.stdout.write(f"  Created patron user: ananya.sharma@athirai.com ({phone})")

        # 3. Seed Live Metal Rates matching Web Video (22K Gold Rs. 14,250, Silver 999 Rs. 275)
        rate = MetalRate.objects.filter(is_active=True).first()
        if not rate:
            rate = MetalRate.objects.create(
                is_active=True,
                gold_24k=15500,
                gold_22k=14250,
                gold_18k=11600,
                silver_999=275.00,
            )
        else:
            rate.gold_24k = 15500
            rate.gold_22k = 14250
            rate.gold_18k = 11600
            rate.silver_999 = 275.00
            rate.save()
        self.stdout.write(f"  Live Metal Rates: 22K=Rs.{rate.gold_22k}, Silver 999=Rs.{rate.silver_999}")

        # 4. Seed Collections matching Megamenu Catalog
        collections_data = [
            {
                'name': 'Gold Jewellery',
                'description': 'Pure 22K & 24K gold ornaments, bangles, necklaces, and heirlooms.',
                'cover_image_url': 'assets/images/heritage_necklace.png',
                'banner_image_url': 'assets/images/heritage_home.png',
                'is_featured': True,
            },
            {
                'name': 'Silver Jewellery',
                'description': '999 fine silver anklets, rings, bracelets, and sacred temple articles.',
                'cover_image_url': 'assets/images/shop_silver_coins.png',
                'banner_image_url': 'assets/images/shop_silver_coins.png',
                'is_featured': True,
            },
            {
                'name': 'Coins & Bars',
                'description': 'Certified gold & silver bullion, minted coins, and investment bars.',
                'cover_image_url': 'assets/images/shop_gold_coins.png',
                'banner_image_url': 'assets/images/shop_gold_coins.png',
                'is_featured': True,
            },
            {
                'name': 'Daily Wear',
                'description': 'Lightweight elegance, minimal geometry, and versatile daily jewels.',
                'cover_image_url': 'assets/images/shop_ring.png',
                'banner_image_url': 'assets/images/shop_bangle.png',
                'is_featured': True,
            },
            {
                'name': 'Wedding Jewellery',
                'description': 'Regal bridal sets, antique temple carvings, and Kundan polki masterpieces.',
                'cover_image_url': 'assets/images/shop_necklace.png',
                'banner_image_url': 'assets/images/athirai_vault_mannequin.jpg',
                'is_featured': True,
            },
            {
                'name': 'Gifting Collection',
                'description': 'Curated tokens of fortune for milestones, birthdays, and anniversaries.',
                'cover_image_url': 'assets/images/athirai_hero_sphere_necklace.jpg',
                'banner_image_url': 'assets/images/athirai_temple_arch_chandelier.jpg',
                'is_featured': True,
            },
            {
                'name': 'Mangalsutra',
                'description': 'Sacred black bead chains, traditional thali filigree, and contemporary solitaires.',
                'cover_image_url': 'assets/images/heritage_necklace.png',
                'banner_image_url': 'assets/images/heritage_onboarding.png',
                'is_featured': True,
            },
            {
                'name': 'Other Jewellery',
                'description': 'Nose pins, toe rings, cufflinks, brooches, and bespoke accessories.',
                'cover_image_url': 'assets/images/athirai_pedestal_necklace.jpg',
                'banner_image_url': 'assets/images/heritage_home.png',
                'is_featured': True,
            },
            {
                'name': 'Heritage Collection',
                'description': 'Masterpieces inspired by ancient sanctums and enduring dynastic regalia.',
                'cover_image_url': 'assets/images/heritage_necklace.png',
                'banner_image_url': 'assets/images/heritage_home.png',
                'is_featured': True,
            },
            {
                'name': 'Temple Collection',
                'description': 'Sacred filigree, nakshi carvings, and celestial iconography forged in 22K gold.',
                'cover_image_url': 'assets/images/athirai_hero_sphere_necklace.jpg',
                'banner_image_url': 'assets/images/athirai_temple_arch_chandelier.jpg',
                'is_featured': True,
            },
            {
                'name': 'Chola Dynasty',
                'description': 'Monumental grandeur and timeless silhouettes honoring the Imperial Chola golden era.',
                'cover_image_url': 'assets/images/athirai_pedestal_necklace.jpg',
                'banner_image_url': 'assets/images/heritage_onboarding.png',
                'is_featured': True,
            },
            {
                'name': 'Royal Collection',
                'description': 'High-jewelry solitaires, Columbian emeralds, and ceremonial bridal adornments.',
                'cover_image_url': 'assets/images/shop_necklace.png',
                'banner_image_url': 'assets/images/athirai_vault_mannequin.jpg',
                'is_featured': True,
            },
            {
                'name': 'Contemporary Collection',
                'description': 'Subtle luxury, modern geometry, and fluid diamond settings for daily elegance.',
                'cover_image_url': 'assets/images/shop_ring.png',
                'banner_image_url': 'assets/images/shop_bangle.png',
                'is_featured': False,
            },
        ]
        col_map = {}
        for cdata in collections_data:
            c, _ = JewelCollection.objects.update_or_create(name=cdata['name'], defaults=cdata)
            col_map[c.name] = c
        self.stdout.write(f"  Seeded {len(col_map)} luxury collections")

        # 5. Seed Categories
        categories_data = [
            {'name': 'Necklaces', 'display_order': 1},
            {'name': 'Rings', 'display_order': 2},
            {'name': 'Bangles', 'display_order': 3},
            {'name': 'Earrings', 'display_order': 4},
            {'name': 'Pendants', 'display_order': 5},
            {'name': 'Chains', 'display_order': 6},
            {'name': 'Coins', 'display_order': 7},
            {'name': 'Mangalsutra', 'display_order': 8},
            {'name': 'Bracelets', 'display_order': 9},
            {'name': 'Anklets', 'display_order': 10},
            {'name': 'Bridal Sets', 'display_order': 11},
            {'name': 'Daily Wear', 'display_order': 12},
            {'name': 'Gold Jewellery', 'display_order': 13},
            {'name': 'Silver Jewellery', 'display_order': 14},
            {'name': 'Gifting', 'display_order': 15},
            {'name': 'Other', 'display_order': 16},
        ]
        cat_map = {}
        for cdata in categories_data:
            cat, _ = JewelCategory.objects.update_or_create(name=cdata['name'], defaults=cdata)
            cat_map[cat.name] = cat
        self.stdout.write(f"  Seeded {len(cat_map)} categories")

        # 6. Seed Dynamic Jewellery Pieces matching Reference Image
        products_data = [
            {
                'name': 'Temple Blossom Necklace',
                'category': cat_map['Necklaces'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-HNK-042',
                'short_description': '22K Gold • Emerald • Pearls. Handcrafted temple filigree necklace.',
                'description': 'An ode to timeless heritage craftsmanship. Forged in 22K antique gold, the Temple Blossom Necklace features a hand-chiseled central lotus medallion encrusted with deep Columbian emeralds and draped in natural Basra pearls.',
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 48.500,
                'making_charge_percent': 14.00,
                'stone_price': 45000,
                'base_price_override': 365000,
                'gemstones': 'Emerald 4.32 ct, Basra Natural Pearls',
                'gemstone_type': 'Emerald',
                'gemstone_weight': '4.32 ct',
                'diamond_carat': '1.20 ct',
                'certification': 'IGI Certified & BIS Hallmark 916',
                'hallmark': 'BIS 916 Hallmark',
                'craftsmanship': 'Handcrafted Temple Filigree',
                'origin': 'Thanjavur Royal Guild',
                'designer': 'Master Artisan Arumugam',
                'crafting_time': '120 Hours',
                'stock_quantity': 8,
                'low_stock_threshold': 3,
                'warehouse': 'Chennai Vault 01',
                'status': 'Published',
                'availability': 'In Stock',
                'seo_title': 'Temple Blossom Necklace | Athirai Timeless Jewels',
                'meta_description': 'Shop the iconic Temple Blossom Necklace in 22K hallmarked gold with natural emeralds and Basra pearls.',
                'url_slug': 'temple-blossom-necklace',
                'tags': 'Heritage, Temple, 22K Gold, Emerald, Basra Pearl',
                'image_url': 'assets/images/athirai_pedestal_necklace.jpg',
                'lifestyle_image_url': 'assets/images/athirai_hero_sphere_necklace.jpg',
                'is_featured': True,
            },
            {
                'name': 'Chola Dynasty Necklace',
                'category': cat_map['Necklaces'],
                'collection': col_map['Chola Dynasty'],
                'sku': 'ATH-CD-108',
                'short_description': 'Imperial Chola regalia necklace in 22K hallmarked antique gold.',
                'description': 'Inspired by the bronze sculptures and temple corridors of the Imperial Chola dynasty. Features alternating royal emblems and uncut polki diamonds.',
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 38.200,
                'making_charge_percent': 13.50,
                'stone_price': 35000,
                'base_price_override': 285000,
                'gemstones': 'Uncut Polki Diamonds, Burmese Rubies',
                'gemstone_type': 'Ruby',
                'gemstone_weight': '3.10 ct',
                'diamond_carat': '1.50 ct',
                'certification': 'BIS 916 & GIA Certified',
                'hallmark': 'BIS 916 Hallmark',
                'craftsmanship': 'Imperial Nakshi Carving',
                'origin': 'Kanchipuram Guild',
                'designer': 'Master Shankaran',
                'crafting_time': '95 Hours',
                'stock_quantity': 5,
                'low_stock_threshold': 2,
                'warehouse': 'Madurai Vault 02',
                'status': 'Published',
                'availability': 'In Stock',
                'seo_title': 'Chola Dynasty Necklace | Athirai Royal Jewels',
                'meta_description': 'Experience the grandeur of the Chola Dynasty Necklace in 22K antique gold.',
                'url_slug': 'chola-dynasty-necklace',
                'tags': 'Chola, Dynasty, 22K Gold, Polki, Heritage',
                'image_url': 'assets/images/heritage_necklace.png',
                'lifestyle_image_url': 'assets/images/athirai_temple_arch_chandelier.jpg',
                'is_featured': True,
            },
            {
                'name': 'Lotus Grace Necklace',
                'category': cat_map['Necklaces'],
                'collection': col_map['Temple Collection'],
                'sku': 'ATH-LG-091',
                'short_description': 'Grand 22K gold temple necklace with blooming lotus motifs.',
                'description': 'A monumental ceremonial statement piece reflecting sacred purity. Hundreds of micro-granulated gold beads create an opulent cascade around glowing ruby drops.',
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 54.000,
                'making_charge_percent': 15.00,
                'stone_price': 50000,
                'base_price_override': 410000,
                'gemstones': 'Pigeon Blood Rubies, Zambian Emeralds',
                'gemstone_type': 'Ruby',
                'gemstone_weight': '5.20 ct',
                'diamond_carat': '0.80 ct',
                'certification': 'IGI Certified & Hallmark',
                'hallmark': 'BIS 916 Hallmark',
                'craftsmanship': 'Temple Repousse & Chasing',
                'origin': 'Thanjavur Royal Guild',
                'designer': 'Meenakshi Ammal',
                'crafting_time': '140 Hours',
                'stock_quantity': 3,
                'low_stock_threshold': 2,
                'warehouse': 'Chennai Vault 01',
                'status': 'Published',
                'availability': 'Low Stock',
                'seo_title': 'Lotus Grace Necklace | Athirai Temple Jewels',
                'meta_description': 'Discover the regal Lotus Grace Necklace in 22K gold with rubies and emeralds.',
                'url_slug': 'lotus-grace-necklace',
                'tags': 'Lotus, Grace, Temple, Rubies, 22K Gold',
                'image_url': 'assets/images/shop_necklace.png',
                'lifestyle_image_url': 'assets/images/athirai_vault_mannequin.jpg',
                'is_featured': True,
            },
            {
                'name': 'Heritage Emerald Ring',
                'category': cat_map['Rings'],
                'collection': col_map['Royal Collection'],
                'sku': 'ATH-RNG-055',
                'short_description': '18K Gold cocktail ring with 3.5 ct oval emerald and brilliant diamonds.',
                'description': 'A rare Zambian emerald cushion cut crowned with double halos of micro-pave diamonds on an 18K antique brushed gold band.',
                'metal': 'Gold',
                'purity': '18K',
                'weight_grams': 12.400,
                'making_charge_percent': 12.00,
                'stone_price': 85000,
                'base_price_override': 145000,
                'gemstones': 'Zambian Emerald 3.5 ct, VVS Diamonds',
                'gemstone_type': 'Emerald',
                'gemstone_weight': '3.50 ct',
                'diamond_carat': '0.95 ct',
                'certification': 'GIA Certified Gemstone',
                'hallmark': 'BIS 750 Hallmark',
                'craftsmanship': 'Micro-Pave Setting',
                'origin': 'Mumbai Haute Atelier',
                'designer': 'Vikram Rathore',
                'crafting_time': '48 Hours',
                'stock_quantity': 10,
                'low_stock_threshold': 3,
                'warehouse': 'Chennai Vault 01',
                'status': 'Published',
                'availability': 'In Stock',
                'seo_title': 'Heritage Emerald Ring | Athirai Royal Vault',
                'meta_description': 'Zambian emerald cocktail ring set in 18K gold and diamonds.',
                'url_slug': 'heritage-emerald-ring',
                'tags': 'Ring, Emerald, 18K Gold, Solitaire, Diamond',
                'image_url': 'assets/images/shop_ring.png',
                'lifestyle_image_url': 'assets/images/athirai_profile_avatar.png',
                'is_featured': True,
            },
            {
                'name': 'Royal Kundan Earrings',
                'category': cat_map['Earrings'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-ERN-204',
                'short_description': 'Traditional 22K kundan jhumkas with emerald drops and pearls.',
                'description': 'Heirloom chandbali earrings featuring pure 24K gold foil setting, natural uncut diamonds, and dangling south sea pearls.',
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 24.800,
                'making_charge_percent': 14.00,
                'stone_price': 40000,
                'base_price_override': 185000,
                'gemstones': 'Kundan Glass, South Sea Pearls, Emeralds',
                'gemstone_type': 'Pearl',
                'gemstone_weight': '6.00 ct',
                'diamond_carat': '0.50 ct',
                'certification': 'BIS 916 Hallmark',
                'hallmark': 'BIS 916 Hallmark',
                'craftsmanship': 'Jadau & Meenakari',
                'origin': 'Jaipur Royal Workshop',
                'designer': 'Gopal Das',
                'crafting_time': '60 Hours',
                'stock_quantity': 6,
                'low_stock_threshold': 2,
                'warehouse': 'Chennai Vault 01',
                'status': 'Published',
                'availability': 'In Stock',
                'seo_title': 'Royal Kundan Earrings | Athirai Jewels',
                'meta_description': 'Shop artisanal 22K Royal Kundan Earrings with pearls and emeralds.',
                'url_slug': 'royal-kundan-earrings',
                'tags': 'Earrings, Kundan, Jhumka, 22K Gold, Pearl',
                'image_url': 'assets/images/shop_earrings.png',
                'lifestyle_image_url': 'assets/images/athirai_royal_model_girl.png',
                'is_featured': True,
            },
            {
                'name': 'Gajraj Heritage Kada',
                'category': cat_map['Bangles'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-BNG-312',
                'short_description': 'Solid 22K gold bangle with embossed elephant finials and ruby eyes.',
                'description': 'A majestic bangle celebrating the temple elephants of Madurai. Sculpted with high relief nakshi work and screw lock clasp.',
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 36.400,
                'making_charge_percent': 13.00,
                'stone_price': 15000,
                'base_price_override': 240000,
                'gemstones': 'Burmese Rubies',
                'gemstone_type': 'Ruby',
                'gemstone_weight': '1.20 ct',
                'diamond_carat': '0.0 ct',
                'certification': 'BIS 916 Hallmark',
                'hallmark': 'BIS 916 Hallmark',
                'craftsmanship': 'Nakshi Hand-Chased Finials',
                'origin': 'Madurai Temple Guild',
                'designer': 'Master Arumugam',
                'crafting_time': '75 Hours',
                'stock_quantity': 4,
                'low_stock_threshold': 2,
                'warehouse': 'Chennai Vault 01',
                'status': 'Published',
                'availability': 'In Stock',
                'seo_title': 'Gajraj Heritage Kada | Athirai Gold Bangles',
                'meta_description': 'Handcrafted solid 22K gold kada with elephant finials.',
                'url_slug': 'gajraj-heritage-kada',
                'tags': 'Bangles, Kada, 22K Gold, Elephant, Nakshi',
                'image_url': 'assets/images/shop_bangle.png',
                'lifestyle_image_url': 'assets/images/athirai_pedestal_necklace.jpg',
                'is_featured': True,
            },
            # ── Certified Coins from Video Recording ────────────────────────
            {
                'name': '50 gm Silver Bar',
                'category': cat_map['Coins'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-SLV-BAR-50G',
                'short_description': '50.0000 g INCL. 3% GST • Silver 999 Limited Bar',
                'description': 'Certified 50g Fine Silver 999 Investment Bar stamped with sacred Lakshmi motif and BIS hallmark.',
                'metal': 'Silver',
                'purity': 'Silver 999',
                'weight_grams': 50.000,
                'making_charge_percent': 5.00,
                'stone_price': 0,
                'base_price_override': 14729,
                'certification': 'BIS Hallmarked Silver 999',
                'hallmark': 'BIS 999 Silver',
                'craftsmanship': 'Minted Investment Bullion Bar',
                'origin': 'Athirai Royal Mint',
                'stock_quantity': 25,
                'status': 'Published',
                'availability': 'In Stock',
                'tags': 'Silver, Coins, Bar, 50g, 999, Limited',
                'image_url': 'assets/images/athirai_gold_lotus_1791280119191.jpg',
                'is_featured': True,
            },
            {
                'name': '2 gm Silver Coin',
                'category': cat_map['Coins'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-SLV-COIN-02G',
                'short_description': '10.0000 g INCL. 3% GST • Silver 999 Bestseller Coin',
                'description': 'Certified fine Silver 999 collector coin with traditional peacock and temple filigree medallion.',
                'metal': 'Silver',
                'purity': 'Silver 999',
                'weight_grams': 10.000,
                'making_charge_percent': 6.00,
                'stone_price': 0,
                'base_price_override': 2974,
                'certification': 'BIS Hallmarked Silver 999',
                'hallmark': 'BIS 999 Silver',
                'craftsmanship': 'Temple Medallion Minting',
                'origin': 'Athirai Royal Mint',
                'stock_quantity': 50,
                'status': 'Published',
                'availability': 'In Stock',
                'tags': 'Silver, Coins, 2g, 10g, 999, Bestseller',
                'image_url': 'assets/images/athirai_emerald_crest_1791280010754.jpg',
                'is_featured': True,
            },
            {
                'name': '50 mg Silver Coin',
                'category': cat_map['Coins'],
                'collection': col_map['Heritage Collection'],
                'sku': 'ATH-SLV-COIN-50M',
                'short_description': '50.0000 g INCL. 3% GST • Silver 999 Limited Coin',
                'description': 'Certified fine Silver 999 coin featuring divine Lakshmi medallion and auspicious Kalash motif.',
                'metal': 'Silver',
                'purity': 'Silver 999',
                'weight_grams': 50.000,
                'making_charge_percent': 5.00,
                'stone_price': 0,
                'base_price_override': 14729,
                'certification': 'BIS Hallmarked Silver 999',
                'hallmark': 'BIS 999 Silver',
                'craftsmanship': 'Lakshmi Deity Medallion',
                'origin': 'Athirai Royal Mint',
                'stock_quantity': 30,
                'status': 'Published',
                'availability': 'In Stock',
                'tags': 'Silver, Coins, 50g, 999, Limited',
                'image_url': 'assets/images/athirai_gold_lotus_1791280119191.jpg',
                'is_featured': True,
            },
            {
                'name': '50 mg Gold Coin',
                'category': cat_map['Coins'],
                'collection': col_map['Temple Collection'],
                'sku': 'ATH-GLD-COIN-50M',
                'short_description': '10.0000 g INCL. 3% GST • Gold 999 Sacred Deity Coin',
                'description': 'Certified 24K 999 Pure Gold Coin struck with Lord Ganesha & Lakshmi divine blessings.',
                'metal': 'Gold',
                'purity': 'Gold 999',
                'weight_grams': 10.000,
                'making_charge_percent': 6.00,
                'stone_price': 0,
                'base_price_override': 2974,
                'certification': 'BIS Hallmarked 24K 999 Gold',
                'hallmark': 'BIS 999 Gold',
                'craftsmanship': 'Temple Deity Minting',
                'origin': 'Athirai Royal Mint',
                'stock_quantity': 40,
                'status': 'Published',
                'availability': 'In Stock',
                'tags': 'Gold, Coins, 50mg, 10g, 999, Gold Coins, Bestseller',
                'image_url': 'assets/images/athirai_login_temple_glow_1791285812754.jpg',
                'is_featured': True,
            },
        ]

        for pdata in products_data:
            p, created = JewelProduct.objects.update_or_create(
                name=pdata['name'],
                defaults=pdata
            )
            # Create sample variants for Temple Blossom Necklace
            if p.name == 'Temple Blossom Necklace':
                JewelVariant.objects.update_or_create(
                    product=p, metal='22K Gold', size='18 Inch',
                    defaults={'sku': 'ATH-HNK-042-22K', 'price': 365000, 'stock': 5, 'weight_grams': 48.5, 'stone': 'Emerald'}
                )
                JewelVariant.objects.update_or_create(
                    product=p, metal='18K Gold', size='18 Inch',
                    defaults={'sku': 'ATH-HNK-042-18K', 'price': 320000, 'stock': 3, 'weight_grams': 42.0, 'stone': 'Emerald'}
                )
                JewelVariant.objects.update_or_create(
                    product=p, metal='950 Platinum', size='18 Inch',
                    defaults={'sku': 'ATH-HNK-042-PLT', 'price': 390000, 'stock': 2, 'weight_grams': 55.0, 'stone': 'Emerald & Diamond'}
                )
            self.stdout.write(f"  {'Created' if created else 'Updated'} product: {p.name} (Rs. {p.dynamic_price:,})")

        # 7. Seed Orders
        orders_data = [
            {'order_id': 'ORD-2026-8921', 'customer_name': 'Ananya Sharma', 'customer_email': 'ananya.sharma@athirai.com', 'customer_phone': '+91 98765 43210', 'product_name': 'Temple Blossom Necklace', 'total_amount': 365000, 'status': 'Confirmed'},
            {'order_id': 'ORD-2026-8919', 'customer_name': 'Rohan Verma', 'customer_email': 'rohan.verma@luxury.in', 'customer_phone': '+91 98765 11223', 'product_name': 'Chola Dynasty Necklace', 'total_amount': 285000, 'status': 'Shipped'},
            {'order_id': 'ORD-2026-8914', 'customer_name': 'Priyanka Nair', 'customer_email': 'priyanka.nair@heritage.org', 'customer_phone': '+91 98765 44556', 'product_name': 'Heritage Emerald Ring', 'total_amount': 145000, 'status': 'Crafting'},
            {'order_id': 'ORD-2026-8902', 'customer_name': 'Meera Sundaram', 'customer_email': 'meera.s@regal.in', 'customer_phone': '+91 98765 77889', 'product_name': 'Royal Kundan Earrings', 'total_amount': 185000, 'status': 'Delivered'},
        ]
        for odata in orders_data:
            JewelOrder.objects.update_or_create(order_id=odata['order_id'], defaults=odata)
        self.stdout.write("  Seeded sample customer orders")

        # 8. Seed VIP Customers
        customers_data = [
            {'name': 'Ananya Sharma', 'email': 'ananya.sharma@athirai.com', 'phone': '+91 98765 43210', 'customer_type': 'Royal VIP', 'total_orders': 4, 'total_spent': 1240000},
            {'name': 'Rohan Verma', 'email': 'rohan.verma@luxury.in', 'phone': '+91 98765 11223', 'customer_type': 'Privilege', 'total_orders': 2, 'total_spent': 570000},
            {'name': 'Priyanka Nair', 'email': 'priyanka.nair@heritage.org', 'phone': '+91 98765 44556', 'customer_type': 'Privilege', 'total_orders': 2, 'total_spent': 330000},
            {'name': 'Meera Sundaram', 'email': 'meera.s@regal.in', 'phone': '+91 98765 77889', 'customer_type': 'Member', 'total_orders': 1, 'total_spent': 185000},
        ]
        for cdata in customers_data:
            JewelCustomer.objects.update_or_create(email=cdata['email'], defaults=cdata)
        self.stdout.write("  Seeded VIP patrons")

        # 9. Seed Jewel Vault Items
        vault_items = [
            {'category_type': 'Necklace', 'title': 'Temple Blossom Necklace', 'price': 365000, 'metal_purity': '22K Gold', 'image_url': 'assets/images/athirai_pedestal_necklace.jpg'},
            {'category_type': 'Ring', 'title': 'Heritage Emerald Ring', 'price': 145000, 'metal_purity': '18K Gold', 'image_url': 'assets/images/shop_ring.png'},
            {'category_type': 'Earrings', 'title': 'Royal Kundan Earrings', 'price': 185000, 'metal_purity': '22K Gold', 'image_url': 'assets/images/shop_earrings.png'},
            {'category_type': 'Bangle', 'title': 'Gajraj Heritage Kada', 'price': 240000, 'metal_purity': '22K Gold', 'image_url': 'assets/images/shop_bangle.png'},
        ]
        for vdata in vault_items:
            JewelVaultItem.objects.update_or_create(title=vdata['title'], defaults=vdata)
        self.stdout.write("  Seeded constellation Jewel Vault items")

        self.stdout.write(self.style.SUCCESS("Athirai Luxury Vault CMS backend data populated successfully!"))
