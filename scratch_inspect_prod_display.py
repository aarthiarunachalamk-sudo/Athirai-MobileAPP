import urllib.request
import re

base_url = 'https://infisq.com'
def fetch(path):
    req = urllib.request.Request(base_url + path, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp:
        return resp.read().decode('utf-8', errors='ignore')

content = fetch('/assets/product_display-CD1qsYgY.js')

# Look for image zoom, gallery, angles, 3d, view, rotation, etc.
# Find all JSX element structures around images
img_parts = re.findall(r'(\.jsx[s]?\([^)]*image[^)]*\))', content)
print("Image JSX elements found:", len(img_parts))
for p in img_parts[:5]:
    print("--- Image JSX ---")
    print(p[:300])

# Find thumbnail / gallery code
gallery_matches = re.findall(r'(\w+\.map\(\s*\([^)]*\)\s*=>\s*[^)]*image[^)]*\))', content)
print("\nGallery maps found:", len(gallery_matches))
for g in gallery_matches[:3]:
    print("--- Gallery Map ---")
    print(g[:300])

# Look for mouse move / zoom / touch / 360 rotation
events = re.findall(r'(on(?:Mouse[A-Z]\w+|Touch[A-Z]\w+|Click|Pointer[A-Z]\w+):[^\,\}]+)', content)
print("\nEvent handlers in product display:", set(events))
