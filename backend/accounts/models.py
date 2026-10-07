from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class UserManager(BaseUserManager):
    """Custom manager for Athirai User model where email is the unique identifier."""
    def create_user(self, email=None, mobile_number=None, password=None, **extra_fields):
        if not email and not mobile_number:
            raise ValueError(_('Users must have either an email address or mobile number'))
        
        if email:
            email = self.normalize_email(email)
            
        user = self.model(email=email, mobile_number=mobile_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_profile_completed', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(email=email, password=password, **extra_fields)


class User(AbstractUser):
    """
    Athirai Custom User Model.
    Supports email or mobile number login, SSO federation, and profile status tracking.
    """
    username = None  # Remove default username
    email = models.EmailField(_('email address'), unique=True, null=True, blank=True)
    mobile_number = models.CharField(_('mobile number'), max_length=25, unique=True, null=True, blank=True)
    full_name = models.CharField(_('full name'), max_length=150, blank=True, default='')
    gender = models.CharField(max_length=30, blank=True, default='')
    date_of_birth = models.DateField(null=True, blank=True)
    door_no = models.CharField(max_length=100, blank=True, default='')
    street_name = models.CharField(max_length=200, blank=True, default='')
    pincode = models.CharField(max_length=12, blank=True, default='')
    town = models.CharField(max_length=100, blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='')
    district = models.CharField(max_length=100, blank=True, default='')
    state = models.CharField(max_length=100, blank=True, default='')
    avatar_url = models.URLField(_('avatar url'), max_length=500, blank=True, null=True)
    
    # SSO tracking
    is_sso_user = models.BooleanField(default=False)
    sso_provider = models.CharField(max_length=50, blank=True, default='')
    organization_domain = models.CharField(max_length=100, blank=True, default='')
    
    # First time login / profile completion flow (Screen 9 in reference)
    is_profile_completed = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return self.email or self.mobile_number or f'User {self.id}'


class Organization(models.Model):
    """
    Enterprise SSO Organization configuration.
    Maps company domain (e.g. company.com) to identity provider settings.
    """
    PROVIDER_CHOICES = (
        ('microsoft', 'Microsoft Entra ID / Azure AD'),
        ('google', 'Google Workspace'),
        ('okta', 'Okta Identity Cloud'),
        ('oidc', 'Generic OpenID Connect'),
    )

    name = models.CharField(max_length=200)
    domain = models.CharField(max_length=100, unique=True, db_index=True)
    provider = models.CharField(max_length=50, choices=PROVIDER_CHOICES, default='microsoft')
    client_id = models.CharField(max_length=255, blank=True, default='')
    client_secret = models.CharField(max_length=255, blank=True, default='')
    authorization_url = models.URLField(max_length=500, blank=True, default='')
    token_url = models.URLField(max_length=500, blank=True, default='')
    userinfo_url = models.URLField(max_length=500, blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.domain}) [{self.provider}]"


class SSOState(models.Model):
    """
    Tracks state and PKCE verifier for SSO OAuth2 / OIDC authorization codes.
    """
    state = models.CharField(max_length=128, unique=True, db_index=True)
    email = models.CharField(max_length=255)
    domain = models.CharField(max_length=100)
    provider = models.CharField(max_length=50)
    code_verifier = models.CharField(max_length=128, blank=True, default='')
    is_consumed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"SSOState({self.state[:8]}... for {self.email})"


class SelfieRecord(models.Model):
    """
    Tracks all captured selfie uploads and their synthesized AI avatars.
    Preserves all uploaded selfies and marks the newest one as is_latest.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='selfies', null=True, blank=True)
    session_id = models.CharField(max_length=128, blank=True, default='')
    selfie_url = models.URLField(max_length=1000)
    selfie_public_id = models.CharField(max_length=255, blank=True, default='')
    avatar_url = models.URLField(max_length=1000, blank=True, default='')
    avatar_public_id = models.CharField(max_length=255, blank=True, default='')
    storage_type = models.CharField(max_length=50, default='cloudinary')  # 'cloudinary' or 'local'
    is_latest = models.BooleanField(default=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        ident = self.user.email if self.user else f"Session {self.session_id}"
        return f"Selfie ({ident}) - latest={self.is_latest} ({self.created_at})"


class MetalRate(models.Model):
    """
    Live Daily Metal Rates in INR per gram.
    Supports 24K pure gold, 22K standard hallmark gold, 18K diamond gold, and 999 pure silver.
    """
    gold_24k = models.IntegerField(default=7980, help_text="Rate in INR per gram for 24K (999 pure gold)")
    gold_22k = models.IntegerField(default=7450, help_text="Rate in INR per gram for 22K (916 hallmark gold)")
    gold_18k = models.IntegerField(default=6100, help_text="Rate in INR per gram for 18K (750 gold)")
    silver_999 = models.DecimalField(max_digits=6, decimal_places=2, default=98.50, help_text="Rate in INR per gram for 999 fine silver")
    is_active = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"MetalRate(22K: ₹{self.gold_22k}/g, 24K: ₹{self.gold_24k}/g, Silver: ₹{self.silver_999}/g)"


class JewelCategory(models.Model):
    """
    Dynamic jewellery categories (e.g. Necklaces, Rings, Bangles, Coins, Temple, Chokers).
    """
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True, blank=True)
    image_url = models.CharField(max_length=500, blank=True, default='')
    display_order = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = "Jewel Categories"
        ordering = ['display_order', 'name']

    def save(self, *args, **kwargs):
        if not self.slug:
            from django.utils.text import slugify
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class JewelCollection(models.Model):
    """
    Luxury collections (e.g. Heritage Collection, Temple Collection, Chola Dynasty).
    """
    name = models.CharField(max_length=150, unique=True)
    slug = models.SlugField(max_length=150, unique=True, blank=True)
    description = models.TextField(blank=True, default='')
    cover_image_url = models.CharField(max_length=500, blank=True, default='')
    banner_image_url = models.CharField(max_length=500, blank=True, default='')
    is_featured = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['name']

    def save(self, *args, **kwargs):
        if not self.slug:
            from django.utils.text import slugify
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class JewelProduct(models.Model):
    """
    Dynamic luxury jewellery piece with net weight, purity, making charges, and dynamic price calculation.
    """
    PURITY_CHOICES = (
        ('24K', '24K (999 Fine Gold)'),
        ('22K', '22K (BIS 916 Hallmark)'),
        ('18K', '18K (750 Diamond Gold)'),
        ('999', '999 Fine Silver'),
        ('950', '950 Platinum'),
    )
    METAL_CHOICES = (
        ('Gold', 'Gold'),
        ('Silver', 'Silver'),
        ('Platinum', 'Platinum'),
    )
    STATUS_CHOICES = (
        ('Published', 'Published'),
        ('Draft', 'Draft'),
        ('Archived', 'Archived'),
    )
    AVAILABILITY_CHOICES = (
        ('In Stock', 'In Stock'),
        ('Low Stock', 'Low Stock'),
        ('Out of Stock', 'Out of Stock'),
        ('Made to Order', 'Made to Order'),
        ('Pre Order', 'Pre Order'),
    )

    name = models.CharField(max_length=200)
    category = models.ForeignKey(JewelCategory, on_delete=models.CASCADE, related_name='jewels')
    collection = models.ForeignKey(JewelCollection, on_delete=models.SET_NULL, null=True, blank=True, related_name='products')
    sku = models.CharField(max_length=50, blank=True, default='')
    short_description = models.CharField(max_length=300, blank=True, default='')
    description = models.TextField(blank=True, default='')

    metal = models.CharField(max_length=20, choices=METAL_CHOICES, default='Gold')
    purity = models.CharField(max_length=10, choices=PURITY_CHOICES, default='22K')
    weight_grams = models.DecimalField(max_digits=8, decimal_places=3, help_text="Net weight in grams", default=25.0)
    making_charge_percent = models.DecimalField(max_digits=5, decimal_places=2, default=12.00, help_text="Wastage / Making charge percentage")
    stone_price = models.IntegerField(default=0, help_text="Gemstone / Diamond value in INR")

    gemstones = models.CharField(max_length=255, blank=True, default='Emerald 4.32 ct, Natural Pearls')
    gemstone_type = models.CharField(max_length=100, blank=True, default='Emerald')
    gemstone_weight = models.CharField(max_length=100, blank=True, default='4.32 ct')
    diamond_carat = models.CharField(max_length=100, blank=True, default='1.20 ct')
    certification = models.CharField(max_length=100, blank=True, default='IGI & BIS Certified')
    hallmark = models.CharField(max_length=100, blank=True, default='BIS 916 Hallmark')
    craftsmanship = models.CharField(max_length=150, blank=True, default='Handcrafted Temple Filigree')
    origin = models.CharField(max_length=150, blank=True, default='Thanjavur Royal Guild')
    designer = models.CharField(max_length=150, blank=True, default='Master Artisan Arumugam')
    crafting_time = models.CharField(max_length=100, blank=True, default='120 Hours')

    stock_quantity = models.IntegerField(default=12)
    low_stock_threshold = models.IntegerField(default=3)
    warehouse = models.CharField(max_length=100, blank=True, default='Chennai Vault 01')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Published')
    availability = models.CharField(max_length=30, choices=AVAILABILITY_CHOICES, default='In Stock')

    seo_title = models.CharField(max_length=200, blank=True, default='')
    meta_description = models.TextField(blank=True, default='')
    url_slug = models.CharField(max_length=200, blank=True, default='')
    tags = models.CharField(max_length=255, blank=True, default='Heritage, Temple, 22K Gold, Emerald')

    image_url = models.CharField(max_length=500, blank=True, default='')
    lifestyle_image_url = models.CharField(max_length=500, blank=True, default='')
    is_featured = models.BooleanField(default=False)
    base_price_override = models.IntegerField(null=True, blank=True, help_text="Explicit price override if specified")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def calculate_price_breakdown(self, rates=None):
        if self.base_price_override and self.base_price_override > 0:
            return {
                'jewel_id': self.id,
                'name': self.name,
                'category': self.category.name if self.category else 'Jewellery',
                'metal': self.metal,
                'purity': self.purity,
                'weight_grams': float(self.weight_grams),
                'metal_rate_per_gram': 7450.0,
                'metal_value': round(float(self.weight_grams) * 7450.0, 2),
                'making_charge_percent': float(self.making_charge_percent),
                'making_charges': 25000.0,
                'stone_price': self.stone_price,
                'taxable_amount': round(self.base_price_override * 0.97, 2),
                'gst_amount': round(self.base_price_override * 0.03, 2),
                'final_price': self.base_price_override,
            }

        if not rates:
            rates = MetalRate.objects.filter(is_active=True).first()
            if not rates:
                rates = MetalRate(gold_24k=7980, gold_22k=7450, gold_18k=6100, silver_999=98.50)

        rate_per_gram = 0.0
        if self.metal == 'Silver':
            rate_per_gram = float(rates.silver_999)
        elif self.purity == '24K':
            rate_per_gram = float(rates.gold_24k)
        elif self.purity == '18K':
            rate_per_gram = float(rates.gold_18k)
        elif self.metal == 'Platinum' or self.purity == '950':
            rate_per_gram = 4200.0
        else:
            rate_per_gram = float(rates.gold_22k)

        weight = float(self.weight_grams)
        metal_value = weight * rate_per_gram
        making_charges = metal_value * (float(self.making_charge_percent) / 100.0)
        stone_val = float(self.stone_price)
        taxable_amount = metal_value + making_charges + stone_val
        gst = taxable_amount * 0.03  # 3% GST
        final_price = round(taxable_amount + gst)

        return {
            'jewel_id': self.id,
            'name': self.name,
            'category': self.category.name if self.category else 'Jewellery',
            'metal': self.metal,
            'purity': self.purity,
            'weight_grams': weight,
            'metal_rate_per_gram': rate_per_gram,
            'metal_value': round(metal_value, 2),
            'making_charge_percent': float(self.making_charge_percent),
            'making_charges': round(making_charges, 2),
            'stone_price': self.stone_price,
            'taxable_amount': round(taxable_amount, 2),
            'gst_amount': round(gst, 2),
            'final_price': final_price,
        }

    @property
    def dynamic_price(self):
        return self.calculate_price_breakdown()['final_price']

    def __str__(self):
        return f"{self.name} ({self.purity} • {self.weight_grams}g)"


class JewelVariant(models.Model):
    """Product variants (different metal purities, chain lengths, gemstone variants)."""
    product = models.ForeignKey(JewelProduct, on_delete=models.CASCADE, related_name='variants')
    metal = models.CharField(max_length=50, default='22K Gold')
    size = models.CharField(max_length=50, default='Standard / 18 Inch')
    stone = models.CharField(max_length=100, default='Emerald')
    sku = models.CharField(max_length=50, blank=True, default='')
    price = models.IntegerField(default=365000)
    stock = models.IntegerField(default=5)
    weight_grams = models.DecimalField(max_digits=8, decimal_places=3, default=45.0)
    image_url = models.CharField(max_length=500, blank=True, default='')

    def __str__(self):
        return f"{self.product.name} - {self.metal} / {self.size}"


class JewelOrder(models.Model):
    """Customer orders tracked within the luxury vault CMS."""
    STATUS_CHOICES = (
        ('Pending', 'Pending'),
        ('Confirmed', 'Confirmed'),
        ('Crafting', 'Crafting'),
        ('Packed', 'Packed'),
        ('Shipped', 'Shipped'),
        ('Delivered', 'Delivered'),
        ('Cancelled', 'Cancelled'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders', null=True, blank=True)
    order_id = models.CharField(max_length=50, unique=True)
    invoice_number = models.CharField(max_length=100, blank=True, default='')
    customer_name = models.CharField(max_length=150)
    customer_email = models.EmailField(blank=True, default='')
    customer_phone = models.CharField(max_length=30, blank=True, default='')

    # Step 8: Delivery Address
    delivery_name = models.CharField(max_length=150, blank=True, default='')
    delivery_phone = models.CharField(max_length=30, blank=True, default='')
    door_no = models.CharField(max_length=100, blank=True, default='')
    street_name = models.CharField(max_length=200, blank=True, default='')
    town = models.CharField(max_length=100, blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='')
    pincode = models.CharField(max_length=20, blank=True, default='')
    state = models.CharField(max_length=100, blank=True, default='')
    delivery_address = models.TextField(blank=True, default='')

    # Product & Purchase Details
    product_name = models.CharField(max_length=200)
    product_image = models.CharField(max_length=500, blank=True, default='')
    metal_purity = models.CharField(max_length=50, blank=True, default='22K Gold')
    weight_grams = models.DecimalField(max_digits=8, decimal_places=3, default=10.0)
    quantity = models.IntegerField(default=1)

    total_amount = models.IntegerField(help_text="Total value in INR")
    coins_used = models.DecimalField(max_digits=15, decimal_places=2, default=0.0, help_text="Total AUG Coins paid for order")
    payment_method = models.CharField(max_length=50, default='AUG Coins')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Confirmed')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Order {self.order_id} - {self.customer_name} ({self.status})"


class JewelCustomer(models.Model):
    """VIP Client directory for high-jewelry patrons."""
    TIER_CHOICES = (
        ('Royal VIP', 'Royal VIP Patron'),
        ('Privilege', 'Privilege Member'),
        ('Member', 'Heritage Member'),
    )
    name = models.CharField(max_length=150)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=30, blank=True, default='')
    customer_type = models.CharField(max_length=30, choices=TIER_CHOICES, default='Privilege')
    total_orders = models.IntegerField(default=1)
    total_spent = models.IntegerField(default=365000)
    last_purchase_date = models.DateField(auto_now_add=True)

    class Meta:
        ordering = ['-total_spent']

    def __str__(self):
        return f"{self.name} ({self.customer_type})"


class JewelVaultItem(models.Model):
    """Curated pieces in the user's constellation Jewel Vault."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='vault_items', null=True, blank=True)
    category_type = models.CharField(max_length=50, default='Necklace')  # Necklace, Ring, Earrings, Bangle, Bracelet
    title = models.CharField(max_length=150)
    image_url = models.CharField(max_length=500, blank=True, default='')
    price = models.IntegerField(default=365000)
    metal_purity = models.CharField(max_length=50, default='22K Gold')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Vault Item: {self.title} ({self.category_type})"


class UserWallet(models.Model):
    """
    Customer AUG Coin & Rewards Wallet.
    Tracks AUG coins, daily login rewards, and gold redemption balance.
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='wallet')
    balance_coins = models.DecimalField(max_digits=12, decimal_places=2, default=5.0)
    last_daily_login_reward_date = models.DateField(null=True, blank=True)
    total_coins_earned = models.DecimalField(max_digits=12, decimal_places=2, default=5.0)
    total_spent_inr = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def claim_daily_reward(self, coins=1.0):
        """
        Customer login paninadhum avangalukku one credit reward earn aagum.
        Claims 1 credit reward if not claimed today.
        """
        from django.utils import timezone
        today = timezone.now().date()
        if self.last_daily_login_reward_date == today:
            return False, float(self.balance_coins)

        new_bal = float(self.balance_coins) + float(coins)
        self.balance_coins = new_bal
        self.total_coins_earned = float(self.total_coins_earned) + float(coins)
        self.last_daily_login_reward_date = today
        self.save()

        WalletTransaction.objects.create(
            user=self.user,
            type='reward',
            reward_type='daily_login',
            direction='credit',
            amount_paid=0.0,
            coins_credited=coins,
            payment_method='reward',
            source='Daily Login Bonus'
        )
        return True, new_bal

    def manual_credit(self, amount_inr, coins, source='Manual Coin Generation'):
        """
        Step 7 Point 5: Manual Coin Creation / Coins உருவாக்குதல்.
        """
        new_bal = float(self.balance_coins) + float(coins)
        self.balance_coins = new_bal
        self.total_coins_earned = float(self.total_coins_earned) + float(coins)
        if amount_inr > 0:
            self.total_spent_inr = float(self.total_spent_inr) + float(amount_inr)
        self.save()

        WalletTransaction.objects.create(
            user=self.user,
            type='admin_credit',
            direction='credit',
            amount_paid=amount_inr,
            coins_credited=coins,
            payment_method='manual_generation',
            source=source
        )
        return new_bal

    def __str__(self):
        return f"{self.user} Wallet: {self.balance_coins} AUG Coins"


class WalletTransaction(models.Model):
    """
    Transactions for Wallet Recharge, Rewards, and Gold Purchase via AUG Coins.
    Directly compatible with infisq.com /wallet/ and /rewards/ APIs.
    """
    DIRECTION_CHOICES = (
        ('credit', '+ CREDIT'),
        ('debit', '− DEBIT'),
    )
    TYPE_CHOICES = (
        ('reward', 'Reward'),
        ('recharge', 'Recharge'),
        ('debit', 'Debit'),
        ('purchase', 'Gold Purchase'),
        ('admin_credit', 'Admin Credit'),
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='wallet_transactions')
    type = models.CharField(max_length=30, choices=TYPE_CHOICES, default='recharge')
    reward_type = models.CharField(max_length=50, blank=True, default='')
    direction = models.CharField(max_length=10, choices=DIRECTION_CHOICES, default='credit')
    amount_paid = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    coins_credited = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    payment_method = models.CharField(max_length=30, default='wallet')
    order_id = models.CharField(max_length=100, blank=True, default='')
    source = models.CharField(max_length=150, blank=True, default='Athirai Royal Vault')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user} | {self.direction} | {self.coins_credited} Coins ({self.type})"

