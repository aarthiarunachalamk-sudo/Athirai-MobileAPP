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


class JewelProduct(models.Model):
    """
    Dynamic jewellery piece with net weight, purity, making charges, and dynamic price calculation.
    """
    PURITY_CHOICES = (
        ('24K', '24K (999 Fine Gold)'),
        ('22K', '22K (BIS 916 Hallmark)'),
        ('18K', '18K (750 Diamond Gold)'),
        ('999', '999 Fine Silver'),
    )
    METAL_CHOICES = (
        ('Gold', 'Gold'),
        ('Silver', 'Silver'),
        ('Platinum', 'Platinum'),
    )

    name = models.CharField(max_length=200)
    category = models.ForeignKey(JewelCategory, on_delete=models.CASCADE, related_name='jewels')
    metal = models.CharField(max_length=20, choices=METAL_CHOICES, default='Gold')
    purity = models.CharField(max_length=10, choices=PURITY_CHOICES, default='22K')
    weight_grams = models.DecimalField(max_digits=8, decimal_places=3, help_text="Net weight in grams")
    making_charge_percent = models.DecimalField(max_digits=5, decimal_places=2, default=12.00, help_text="Wastage / Making charge percentage")
    stone_price = models.IntegerField(default=0, help_text="Gemstone / Diamond value in INR")
    description = models.TextField(blank=True, default='')
    image_url = models.CharField(max_length=500, blank=True, default='')
    is_featured = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def calculate_price_breakdown(self, rates=None):
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
            'category': self.category.name,
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
