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

        self.stdout.write(self.style.SUCCESS("Athirai backend data seeded successfully!"))
