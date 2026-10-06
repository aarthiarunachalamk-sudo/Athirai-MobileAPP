import re
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Organization

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'mobile_number',
            'full_name',
            'gender',
            'date_of_birth',
            'door_no',
            'street_name',
            'pincode',
            'town',
            'city',
            'district',
            'state',
            'avatar_url',
            'is_sso_user',
            'sso_provider',
            'organization_domain',
            'is_profile_completed',
            'created_at',
        ]
        read_only_fields = ['id', 'is_sso_user', 'sso_provider', 'organization_domain', 'created_at']


class LoginRequestSerializer(serializers.Serializer):
    """
    Accepts email or mobile number from the Athirai main login screen.
    """
    identifier = serializers.CharField(max_length=255, required=True)
    password = serializers.CharField(max_length=128, required=False, allow_blank=True, default='')

    def validate_identifier(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Please enter your email or mobile number.")

        email_pattern = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
        phone_pattern = r'^\+?[0-9\s\-()]{7,20}$'

        is_email = bool(re.match(email_pattern, value))
        is_phone = bool(re.match(phone_pattern, value))

        if not is_email and not is_phone:
            raise serializers.ValidationError("Please enter a valid email address or mobile number.")

        return value


class RegisterRequestSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(max_length=128, required=True, min_length=6)
    confirm_password = serializers.CharField(max_length=128, required=False, write_only=True)
    full_name = serializers.CharField(max_length=150, required=False, default='')
    first_name = serializers.CharField(max_length=150, required=False, default='')
    last_name = serializers.CharField(max_length=150, required=False, default='')
    mobile_number = serializers.CharField(max_length=25, required=False, allow_blank=True, default='')
    gender = serializers.CharField(max_length=30, required=False, allow_blank=True, default='')
    date_of_birth = serializers.DateField(required=False, allow_null=True)
    door_no = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')
    street_name = serializers.CharField(max_length=200, required=False, allow_blank=True, default='')
    pincode = serializers.CharField(max_length=12, required=False, allow_blank=True, default='')
    town = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')
    city = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')
    district = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')
    state = serializers.CharField(max_length=100, required=False, allow_blank=True, default='')

    def validate(self, attrs):
        confirmation = attrs.pop('confirm_password', None)
        if confirmation is not None and confirmation != attrs['password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("An account with this email already exists.")
        return value.lower()


class SSODiscoverRequestSerializer(serializers.Serializer):
    """
    Endpoint: POST /api/auth/sso/discover/
    Input: {"email": "name@company.com"}
    """
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        val = value.strip().lower()
        if '@' not in val:
            raise serializers.ValidationError("Enter a valid email address.")
        return val


class SSOCallbackRequestSerializer(serializers.Serializer):
    """
    Endpoint: POST /api/auth/sso/callback/
    Receives authorization code & state after IdP redirect.
    """
    code = serializers.CharField(required=True)
    state = serializers.CharField(required=True)


class ProfileUpdateRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['full_name', 'mobile_number', 'avatar_url', 'is_profile_completed']

    def validate_full_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Full name is required.")
        return value.strip()


class SelfieRecordSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import SelfieRecord
        model = SelfieRecord
        fields = [
            'id',
            'session_id',
            'selfie_url',
            'selfie_public_id',
            'avatar_url',
            'avatar_public_id',
            'storage_type',
            'is_latest',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class MetalRateSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import MetalRate
        model = MetalRate
        fields = ['id', 'gold_24k', 'gold_22k', 'gold_18k', 'silver_999', 'is_active', 'updated_at']
        read_only_fields = ['id', 'updated_at']


class JewelCategorySerializer(serializers.ModelSerializer):
    jewel_count = serializers.IntegerField(source='jewels.count', read_only=True)

    class Meta:
        from .models import JewelCategory
        model = JewelCategory
        fields = ['id', 'name', 'slug', 'image_url', 'display_order', 'jewel_count', 'created_at']
        read_only_fields = ['id', 'slug', 'created_at']


class JewelCollectionSerializer(serializers.ModelSerializer):
    product_count = serializers.IntegerField(source='products.count', read_only=True)

    class Meta:
        from .models import JewelCollection
        model = JewelCollection
        fields = ['id', 'name', 'slug', 'description', 'cover_image_url', 'banner_image_url', 'is_featured', 'product_count', 'created_at']
        read_only_fields = ['id', 'slug', 'created_at']


class JewelVariantSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import JewelVariant
        model = JewelVariant
        fields = ['id', 'product', 'metal', 'size', 'stone', 'sku', 'price', 'stock', 'weight_grams', 'image_url']
        read_only_fields = ['id']


class JewelProductSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    collection_name = serializers.CharField(source='collection.name', read_only=True)
    dynamic_price = serializers.IntegerField(read_only=True)
    price_breakdown = serializers.SerializerMethodField()
    variants = JewelVariantSerializer(many=True, read_only=True)

    class Meta:
        from .models import JewelProduct
        model = JewelProduct
        fields = [
            'id',
            'name',
            'category',
            'category_name',
            'collection',
            'collection_name',
            'sku',
            'short_description',
            'description',
            'metal',
            'purity',
            'weight_grams',
            'making_charge_percent',
            'stone_price',
            'gemstones',
            'gemstone_type',
            'gemstone_weight',
            'diamond_carat',
            'certification',
            'hallmark',
            'craftsmanship',
            'origin',
            'designer',
            'crafting_time',
            'stock_quantity',
            'low_stock_threshold',
            'warehouse',
            'status',
            'availability',
            'seo_title',
            'meta_description',
            'url_slug',
            'tags',
            'image_url',
            'lifestyle_image_url',
            'is_featured',
            'base_price_override',
            'dynamic_price',
            'price_breakdown',
            'variants',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_price_breakdown(self, obj):
        return obj.calculate_price_breakdown()


class JewelOrderSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import JewelOrder
        model = JewelOrder
        fields = '__all__'


class JewelCustomerSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import JewelCustomer
        model = JewelCustomer
        fields = '__all__'


class JewelVaultItemSerializer(serializers.ModelSerializer):
    class Meta:
        from .models import JewelVaultItem
        model = JewelVaultItem
        fields = '__all__'


class ForgotPasswordRequestSerializer(serializers.Serializer):
    identifier = serializers.CharField(max_length=255, required=True)


class ResetPasswordConfirmSerializer(serializers.Serializer):
    identifier = serializers.CharField(max_length=255, required=True)
    otp = serializers.CharField(max_length=10, required=True)
    new_password = serializers.CharField(min_length=6, max_length=128, required=True)

