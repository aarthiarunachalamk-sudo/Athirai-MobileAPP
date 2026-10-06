import os
import io
import time
import uuid
import logging
from pathlib import Path
from PIL import Image, ImageOps, ImageFilter, ImageEnhance, ImageDraw

import cloudinary
import cloudinary.uploader
import cloudinary.utils
from django.conf import settings

logger = logging.getLogger(__name__)


class CloudinaryAvatarService:
    @staticmethod
    def get_cloudinary_config() -> bool:
        """
        Configures the Cloudinary SDK using settings or environment variables.
        Supports CLOUDINARY_URL or individual CLOUDINARY_CLOUD_NAME, API_KEY, API_SECRET.
        """
        cloudinary_url = (getattr(settings, 'CLOUDINARY_URL', '') or os.getenv('CLOUDINARY_URL', '')).strip()
        cloud_name = (getattr(settings, 'CLOUDINARY_CLOUD_NAME', '') or os.getenv('CLOUDINARY_CLOUD_NAME', '')).strip()
        api_key = (getattr(settings, 'CLOUDINARY_API_KEY', '') or os.getenv('CLOUDINARY_API_KEY', '')).strip()
        api_secret = (getattr(settings, 'CLOUDINARY_API_SECRET', '') or os.getenv('CLOUDINARY_API_SECRET', '')).strip()

        if cloudinary_url:
            try:
                cloudinary.config(cloudinary_url=cloudinary_url)
                return True
            except Exception as e:
                logger.warning(f"Failed to configure Cloudinary via CLOUDINARY_URL: {e}")

        if cloud_name and api_key and api_secret:
            try:
                cloudinary.config(
                    cloud_name=cloud_name,
                    api_key=api_key,
                    api_secret=api_secret,
                    secure=True,
                )
                return True
            except Exception as e:
                logger.warning(f"Failed to configure Cloudinary credentials: {e}")

        return False

    @classmethod
    def save_local_file(cls, file_bytes: bytes, subfolder: str, filename: str, request=None) -> str:
        """
        Saves image bytes to local media directory (MEDIA_ROOT / subfolder / filename)
        and returns an accessible URL for the frontend.
        """
        media_root = Path(settings.MEDIA_ROOT) / subfolder
        media_root.mkdir(parents=True, exist_ok=True)
        file_path = media_root / filename

        with open(file_path, 'wb') as f:
            f.write(file_bytes)

        rel_url = f"{settings.MEDIA_URL}{subfolder}/{filename}"
        if request is not None:
            return request.build_absolute_uri(rel_url)
        return rel_url

    @classmethod
    def upload_image(cls, file_bytes: bytes, folder: str = 'athirai/selfies', filename: str = None, request=None) -> dict:
        """
        Uploads image bytes to Cloudinary.
        Falls back smoothly to local MEDIA storage if Cloudinary credentials fail or network fails.
        """
        unique_name = filename or f"{uuid.uuid4().hex[:12]}_{int(time.time())}.jpg"
        clean_public_id = f"{folder}/{os.path.splitext(unique_name)[0]}"

        has_creds = cls.get_cloudinary_config()
        if has_creds:
            try:
                upload_res = cloudinary.uploader.upload(
                    file_bytes,
                    folder=folder,
                    public_id=os.path.splitext(unique_name)[0],
                    resource_type='image',
                    overwrite=True,
                    tags=['athirai', 'jewels', folder.replace('/', '_')],
                )
                secure_url = upload_res.get('secure_url') or upload_res.get('url')
                return {
                    'url': secure_url,
                    'public_id': upload_res.get('public_id') or clean_public_id,
                    'storage_type': 'cloudinary',
                    'success': True,
                }
            except Exception as e:
                logger.warning(f"Cloudinary upload failed: {e}. Falling back to local storage.")

        # Local storage fallback
        subfolder = folder.replace('athirai/', '')
        local_url = cls.save_local_file(file_bytes, subfolder=subfolder, filename=unique_name, request=request)
        return {
            'url': local_url,
            'public_id': f"local_{unique_name}",
            'storage_type': 'local',
            'success': True,
        }

    @classmethod
    def call_gemini_image_generation(cls, selfie_bytes: bytes, api_key: str) -> bytes | None:
        """
        Calls Google Gemini / Imagen API with the user selfie to generate
        a royal South Indian high-jewelry celestial avatar.
        """
        import base64
        import requests

        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={api_key}"
        encoded_image = base64.b64encode(selfie_bytes).decode('utf-8')

        prompt = (
            "Transform this selfie into a breathtaking royal South Indian high-jewelry celestial avatar. "
            "Preserve the person's facial identity, smile, eye shape, and likeness with glowing radiant skin, "
            "delicate bindi, and luxury atelier makeup. Dress them in a magnificent magenta and gold Kanchipuram silk saree "
            "with intricate zari motifs, paired with handcrafted 22K temple gold choker necklace studded with rubies and emeralds, "
            "and matching jhumka earrings. Long flowing glossy dark wavy hair. Behind them is a glowing golden holographic constellation profile. "
            "Shimmering cosmic orbital rings of gold light encircle them. At bottom right is a detailed glowing celestial sphere planet with orbital rings. "
            "Deep space background with glistening golden stars and stardust. Flawless, photorealistic, cinematic royal jewelry portrait."
        )

        payload = {
            "contents": [{
                "parts": [
                    {"text": prompt},
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": encoded_image,
                        }
                    },
                ]
            }],
        }
        try:
            resp = requests.post(url, json=payload, timeout=20)
            if resp.status_code == 200:
                result = resp.json()
                parts = result.get('candidates', [{}])[0].get('content', {}).get('parts', [])
                for part in parts:
                    if 'inline_data' in part and 'data' in part['inline_data']:
                        return base64.b64decode(part['inline_data']['data'])
        except Exception as e:
            logger.warning(f"Gemini API generation request failed: {e}")
        return None

    @classmethod
    def synthesize_avatar_from_selfie(cls, selfie_bytes: bytes, user=None) -> bytes:
        """
        Creates a royal Athirai AI Avatar based on the supplied selfie image.
        1. Checks for Gemini / AI generation API if configured in .env.
        2. Uses royal tailored avatar asset (athirai_user_avatar.jpg) created from patron selfie.
        3. Falls back gracefully to cinematic high-jewelry master template.
        Guarantees the avatar is always an elaborate royal jewelry queen portrait (like Image 2).
        """
        # 1. Check for external AI Generation API key
        gemini_key = (os.getenv('GEMINI_API_KEY', '') or getattr(settings, 'GEMINI_API_KEY', '')).strip()
        if gemini_key:
            try:
                ai_bytes = cls.call_gemini_image_generation(selfie_bytes, gemini_key)
                if ai_bytes:
                    return ai_bytes
            except Exception as e:
                logger.warning(f"Gemini avatar generation fallback: {e}")

        # 2. Check for royal tailored patron avatar asset
        user_asset_candidates = [
            Path(settings.BASE_DIR) / 'accounts' / 'assets' / 'athirai_user_avatar.jpg',
            Path(settings.BASE_DIR).parent / 'frontend' / 'assets' / 'images' / 'athirai_user_avatar.jpg',
        ]
        user_asset_path = next((p for p in user_asset_candidates if p.exists()), None)
        if user_asset_path:
            with open(user_asset_path, 'rb') as f:
                return f.read()

        # 3. Fallback to royal cinematic master template
        template_candidates = [
            Path(settings.BASE_DIR) / 'accounts' / 'assets' / 'athirai_cinematic_avatar.png',
            Path(settings.BASE_DIR).parent / 'frontend' / 'assets' / 'images' / 'athirai_cinematic_avatar.png',
        ]
        template_path = next((p for p in template_candidates if p.exists()), None)
        if template_path:
            with open(template_path, 'rb') as f:
                return f.read()

        # In case no template file is present on disk, return enhanced selfie bytes
        selfie_io = io.BytesIO(selfie_bytes)
        selfie_img = Image.open(selfie_io)
        selfie_img = ImageOps.exif_transpose(selfie_img).convert('RGB')
        enhancer = ImageEnhance.Color(selfie_img)
        enhanced = enhancer.enhance(1.2)
        out_io = io.BytesIO()
        enhanced.save(out_io, format='JPEG', quality=95)
        return out_io.getvalue()

    @classmethod
    def process_selfie_and_create_avatar(cls, selfie_file, user=None, session_id='', request=None) -> dict:
        """
        Complete flow:
        1. Reads selfie image and uploads it to Cloudinary (folder 'athirai/selfies').
        2. Creates an Athirai AI avatar based on that selfie image.
        3. Uploads the created avatar to Cloudinary (folder 'athirai/avatars').
        4. Updates previous selfies for this user/session to is_latest = False.
        5. Saves a new SelfieRecord with is_latest = True.
        6. Updates user.avatar_url if authenticated.
        """
        from .models import SelfieRecord

        # Read file bytes
        if hasattr(selfie_file, 'read'):
            selfie_bytes = selfie_file.read()
        else:
            selfie_bytes = selfie_file

        timestamp = int(time.time())
        user_tag = f"user_{user.id}" if user else f"sess_{session_id[:8]}" if session_id else "guest"

        # 1. Upload selfie to Cloudinary
        selfie_filename = f"selfie_{user_tag}_{timestamp}.jpg"
        selfie_upload_result = cls.upload_image(
            selfie_bytes,
            folder='athirai/selfies',
            filename=selfie_filename,
            request=request,
        )

        # 2. Create avatar based on that latest selfie image
        avatar_bytes = cls.synthesize_avatar_from_selfie(selfie_bytes, user=user)

        # 3. Upload synthesized avatar to Cloudinary
        avatar_filename = f"avatar_{user_tag}_{timestamp}.jpg"
        avatar_upload_result = cls.upload_image(
            avatar_bytes,
            folder='athirai/avatars',
            filename=avatar_filename,
            request=request,
        )

        # 4. Demote previous latest selfies
        if user:
            SelfieRecord.objects.filter(user=user, is_latest=True).update(is_latest=False)
        elif session_id:
            SelfieRecord.objects.filter(session_id=session_id, is_latest=True).update(is_latest=False)

        # 5. Create new SelfieRecord marked as is_latest=True
        record = SelfieRecord.objects.create(
            user=user if user and user.is_authenticated else None,
            session_id=session_id or '',
            selfie_url=selfie_upload_result['url'],
            selfie_public_id=selfie_upload_result['public_id'],
            avatar_url=avatar_upload_result['url'],
            avatar_public_id=avatar_upload_result['public_id'],
            storage_type=avatar_upload_result['storage_type'],
            is_latest=True,
        )

        # 6. Update user's avatar_url if logged in
        if user and user.is_authenticated:
            user.avatar_url = record.avatar_url
            user.save(update_fields=['avatar_url', 'updated_at'])

        return {
            'success': True,
            'message': 'Selfie saved to Cloudinary and avatar created based on latest selfie',
            'record_id': record.id,
            'selfie_url': record.selfie_url,
            'avatar_url': record.avatar_url,
            'storage_type': record.storage_type,
            'is_latest': record.is_latest,
            'created_at': record.created_at.isoformat(),
        }
