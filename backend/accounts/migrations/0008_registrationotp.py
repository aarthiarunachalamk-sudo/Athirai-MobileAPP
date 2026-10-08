import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_jewelorder_city_jewelorder_coins_used_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='RegistrationOTP',
            fields=[
                (
                    'id',
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name='ID',
                    ),
                ),
                ('email_code_hash', models.CharField(max_length=128)),
                ('mobile_code_hash', models.CharField(max_length=128)),
                ('expires_at', models.DateTimeField()),
                ('failed_attempts', models.PositiveSmallIntegerField(default=0)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                (
                    'user',
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name='registration_otp',
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
