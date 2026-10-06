import urllib.request
import re

base_url = 'https://infisq.com'
def fetch(path):
    req = urllib.request.Request(base_url + path, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.read().decode('utf-8', errors='ignore')
    except Exception as e:
        return ""

scripts = [
    '/assets/add_new_product-CxOT8d2a.js',
    '/assets/add_product-CpPV9_B-.js',
    '/assets/all_collection-YsFm4_TZ.js',
    '/assets/product_display-CD1qsYgY.js',
    '/assets/CustomerDashboard-D-tr6z5q.js'
]

for s in scripts:
    content = fetch(s)
    print(f"=== {s} ({len(content)} bytes) ===")
    matches = re.findall(r'["\']([^"\'`\n\r]{3,80})["\']', content)
    matches_filtered = [m for m in matches if any(k in m.lower() for k in [
        'upload', 'image', 'photo', 'camera', 'capture', 'file', 'video', '3d', 'ar', 'view', 'rotate', 'angle', 'model', 'lens', 'try'
    ])]
    print("Relevant strings:")
    for item in sorted(set(matches_filtered))[:25]:
        print("  -", item)
