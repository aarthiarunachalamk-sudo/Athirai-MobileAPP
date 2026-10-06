from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from accounts.models import Organization

User = get_user_model()

class Command(BaseCommand):
    help = 'Seeds sample organizations and test accounts for Athirai SSO & normal auth'

    def handle(self, *args, **options):
        self.stdout.write("Seeding Athirai test data...")

        # 1. Seed sample organizations
        orgs = [
            {
                'name': 'Acme Luxury Enterprise',
                'domain': 'company.com',
                'provider': 'microsoft',
                'authorization_url': '/api/auth/mock-idp/authorize/',
            },
            {
                'name': 'Athirai Global Headquarters',
                'domain': 'athirai.com',
                'provider': 'microsoft',
                'authorization_url': '/api/auth/mock-idp/authorize/',
            },
            {
                'name': 'Contoso Haute Horlogerie',
                'domain': 'contoso.com',
                'provider': 'okta',
                'authorization_url': '/api/auth/mock-idp/authorize/',
            },
        ]

        for org_data in orgs:
            org, created = Organization.objects.update_or_create(
                domain=org_data['domain'],
                defaults=org_data
            )
            action = "Created" if created else "Updated"
            self.stdout.write(f"  {action} organization: {org.name} ({org.domain})")

        # 2. Seed a sample admin / user
        if not User.objects.filter(email='admin@athirai.com').exists():
            admin_user = User.objects.create_superuser(
                email='admin@athirai.com',
                password='adminpassword123',
                full_name='Athirai Administrator',
                mobile_number='+91 98765 00000'
            )
            self.stdout.write("  Created superuser: admin@athirai.com (password: adminpassword123)")

        if not User.objects.filter(email='user@company.com').exists():
            demo_user = User.objects.create_user(
                email='user@company.com',
                full_name='Athirai User',
                mobile_number='+91 98765 43210',
                is_sso_user=True,
                sso_provider='microsoft',
                organization_domain='company.com',
                is_profile_completed=False
            )
            self.stdout.write("  Created demo SSO user: user@company.com")

        # 3. Seed Metal Rates
        from accounts.models import MetalRate, JewelCategory, JewelProduct
        rate, created = MetalRate.objects.get_or_create(
            is_active=True,
            defaults={
                'gold_24k': 7980,
                'gold_22k': 7450,
                'gold_18k': 6100,
                'silver_999': 98.50,
            }
        )
        self.stdout.write(f"  {'Created' if created else 'Verified'} live metal rates (22K: Rs.{rate.gold_22k}/g, 24K: Rs.{rate.gold_24k}/g)")

        # 4. Seed Categories
        categories_data = [
            {'name': 'Necklaces', 'display_order': 1},
            {'name': 'Rings', 'display_order': 2},
            {'name': 'Bangles', 'display_order': 3},
            {'name': 'Chains', 'display_order': 4},
            {'name': 'Earrings', 'display_order': 5},
            {'name': 'Pendants', 'display_order': 6},
            {'name': 'Mangalsutra', 'display_order': 7},
            {'name': 'Temple', 'display_order': 8},
            {'name': 'Coins', 'display_order': 9},
        ]
        cat_map = {}
        for cdata in categories_data:
            cat, _ = JewelCategory.objects.get_or_create(name=cdata['name'], defaults=cdata)
            cat_map[cat.name] = cat
        self.stdout.write(f"  Seeded {len(cat_map)} jewellery categories")

        # 5. Seed Jewels
        jewels_data = [
            {
                'name': 'Athirai Cosmic Temple Necklace',
                'category': cat_map['Necklaces'],
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 44.200,
                'making_charge_percent': 12.00,
                'stone_price': 0,
                'description': 'Handcrafted 22K gold temple necklace adorned with divine motifs.',
                'image_url': 'assets/images/heritage_necklace.png',
                'is_featured': True,
            },
            {
                'name': 'Lakshmi Temple Antique Choker',
                'category': cat_map['Temple'],
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 58.400,
                'making_charge_percent': 14.00,
                'stone_price': 15000,
                'description': 'Intricately handcrafted 22K antique gold choker with Goddess Lakshmi motif.',
                'image_url': 'assets/images/heritage_necklace.png',
                'is_featured': True,
            },
            {
                'name': 'Astral Solitaire Diamond Ring',
                'category': cat_map['Rings'],
                'metal': 'Gold',
                'purity': '18K',
                'weight_grams': 6.800,
                'making_charge_percent': 12.00,
                'stone_price': 225000,
                'description': '2.5 carat VVS1 oval brilliant diamond set in 18K gold band.',
                'image_url': 'assets/images/shop_ring.png',
                'is_featured': True,
            },
            {
                'name': 'Sacred Temple Jhumkas',
                'category': cat_map['Earrings'],
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 24.600,
                'making_charge_percent': 12.00,
                'stone_price': 5000,
                'description': 'Traditional temple dome jhumkas adorned with natural pearls.',
                'image_url': 'assets/images/shop_earrings.png',
                'is_featured': False,
            },
            {
                'name': 'Gajraj Heritage Kada',
                'category': cat_map['Bangles'],
                'metal': 'Gold',
                'purity': '22K',
                'weight_grams': 42.000,
                'making_charge_percent': 13.00,
                'stone_price': 0,
                'description': 'Embossed elephant finials with intricate Nakshi carving.',
                'image_url': 'assets/images/shop_bangle.png',
                'is_featured': True,
            },
            {
                'name': '24K Gold Coin 1g',
                'category': cat_map['Coins'],
                'metal': 'Gold',
                'purity': '24K',
                'weight_grams': 1.000,
                'making_charge_percent': 3.00,
                'stone_price': 0,
                'description': '999 Purity 24K Gold coin in tamper-proof assay certification.',
                'image_url': 'assets/images/shop_gold_coins.png',
                'is_featured': False,
            },
            {
                'name': '999 Fine Silver Coin 10g',
                'category': cat_map['Coins'],
                'metal': 'Silver',
                'purity': '999',
                'weight_grams': 10.000,
                'making_charge_percent': 5.00,
                'stone_price': 0,
                'description': '999 Purity Fine Silver coin with embossed Lakshmi motif.',
                'image_url': 'assets/images/shop_silver_coins.png',
                'is_featured': False,
            },
        ]

        for jdata in jewels_data:
            j, created = JewelProduct.objects.get_or_create(
                name=jdata['name'],
                defaults=jdata
            )
            self.stdout.write(f"  {'Created' if created else 'Verified'} jewel: {j.name} (Dynamic: Rs.{j.dynamic_price:,})")

        self.stdout.write(self.style.SUCCESS("Athirai backend dynamic data seeded successfully!"))
