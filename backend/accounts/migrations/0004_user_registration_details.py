from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_jewelcategory_metalrate_jewelproduct'),
    ]

    operations = [
        migrations.AddField('user', 'gender', models.CharField(blank=True, default='', max_length=30)),
        migrations.AddField('user', 'date_of_birth', models.DateField(blank=True, null=True)),
        migrations.AddField('user', 'door_no', models.CharField(blank=True, default='', max_length=100)),
        migrations.AddField('user', 'street_name', models.CharField(blank=True, default='', max_length=200)),
        migrations.AddField('user', 'pincode', models.CharField(blank=True, default='', max_length=12)),
        migrations.AddField('user', 'town', models.CharField(blank=True, default='', max_length=100)),
        migrations.AddField('user', 'city', models.CharField(blank=True, default='', max_length=100)),
        migrations.AddField('user', 'district', models.CharField(blank=True, default='', max_length=100)),
        migrations.AddField('user', 'state', models.CharField(blank=True, default='', max_length=100)),
    ]