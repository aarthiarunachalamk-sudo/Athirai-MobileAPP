"""
End-to-end integration test verifying full dynamic data flow with Django backend
Covering Steps 5 through 11 and dynamic catalogues:
1. Dynamic Live Metal Rates (GET /api/rates/)
2. Dynamic Jewellery Categories (GET /api/categories/)
3. Dynamic Jewellery Catalogue & Price List (GET /api/jewels/, GET /api/price-list/)
4. Dynamic User Registration (POST /api/auth/register/)
5. Dynamic User Login (POST /api/auth/login/)
6. Profile Dashboard & Address Update (GET /api/auth/me/, PUT /api/auth/profile/)
7. AUG Coins Wallet & 1 Rupee = 100 Coins ratio (GET /api/wallet/, POST /api/wallet/claim-daily/)
8. Manual AUG Coin Credit / Generation (POST /api/wallet/manual-credit/)
9. Recharge AUG Coins (POST /api/recharge/verify/)
10. Place Order Strictly with AUG Coins (POST /api/orders/create/)
11. View Order Summary (GET /api/orders/my-orders/)
12. Download Official BIS Hallmarked PDF Receipt (GET /api/orders/<order_id>/receipt/)
"""
import urllib.request
import json
import time
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

BASE_URL = 'http://127.0.0.1:8000'

def request(method, path, data=None, token=None):
    url = f"{BASE_URL}{path}"
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    if token:
        headers['Authorization'] = f"Bearer {token}"
    body = json.dumps(data).encode('utf-8') if data is not None else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req) as resp:
        content_type = resp.headers.get('Content-Type', '')
        if 'application/pdf' in content_type:
            return resp.status, resp.read()
        return resp.status, json.loads(resp.read().decode('utf-8'))

def main():
    print("==================================================================")
    print("  ATHIRAI DJANGO BACKEND FULL DYNAMIC DATA INTEGRATION TEST")
    print("==================================================================")

    # 1. Live Rates
    status, rates = request('GET', '/api/rates/')
    print(f"\n[1] Dynamic Live Metal Rates (Status {status}):")
    print(f"    Gold 24K: ₹{rates['rates']['gold_24k']}/g | 22K: ₹{rates['rates']['gold_22k']}/g | Silver: ₹{rates['rates']['silver_999']}/g")
    assert status == 200 and rates['rates']['gold_22k'] > 0

    # 2. Categories
    status, cats = request('GET', '/api/categories/')
    print(f"\n[2] Dynamic Categories (Status {status}):")
    print(f"    Total categories: {cats['count']} (e.g., {[c['name'] for c in cats['categories'][:4]]})")
    assert status == 200 and cats['count'] > 0

    # 3. Dynamic Catalogue & Price List
    status, jewels = request('GET', '/api/jewels/')
    print(f"\n[3] Dynamic Jewels Catalogue (Status {status}):")
    print(f"    Total items: {jewels['count']} (First: '{jewels['jewels'][0]['name']}' - ₹{jewels['jewels'][0].get('dynamic_price')})")
    assert status == 200 and jewels['count'] > 0

    # 4. User Registration (Step 5)
    ts = int(time.time())
    reg_email = f"patron_{ts}@athirai.luxury"
    reg_phone = f"+9198{ts % 100000000:08d}"
    reg_payload = {
        'email': reg_email,
        'mobile_number': reg_phone,
        'password': 'Password123!',
        'confirm_password': 'Password123!',
        'first_name': 'Sundar',
        'last_name': 'Rajan',
        'full_name': 'Sundar Rajan',
        'gender': 'Male',
        'door_no': '45-B',
        'street_name': 'Temple Tower Road',
        'town': 'T Nagar',
        'city': 'Chennai',
        'district': 'Chennai',
        'state': 'Tamil Nadu',
        'pincode': '600017'
    }
    status, reg_res = request('POST', '/api/auth/register/', reg_payload)
    print(f"\n[4] User Registration (Step 5) (Status {status}):")
    print(f"    User: {reg_res['user']['email']} | Name: {reg_res['user']['full_name']}")
    tokens = reg_res['tokens']
    access_token = tokens['access']
    assert status == 201

    # 5. User Login (Step 5)
    status, login_res = request('POST', '/api/auth/login/', {'identifier': reg_phone, 'password': 'Password123!'})
    print(f"\n[5] User Login via Mobile Phone (Step 5) (Status {status}):")
    print(f"    Authenticated user: {login_res['user']['full_name']} ({login_res['user']['mobile_number']})")
    assert status == 200

    # 6. Profile Dashboard & Address Update (Step 6)
    status, me_res = request('GET', '/api/auth/me/', token=access_token)
    print(f"\n[6] Profile Dashboard Access (Step 6) (Status {status}):")
    print(f"    Vault initial coins: {me_res['user'].get('balance_coins')} | City: {me_res['user'].get('city')}")
    assert status == 200

    # Update address
    status, prof_update = request('PUT', '/api/auth/profile/', {
        'full_name': 'Sundar Rajan (Royal Patron)',
        'door_no': 'Villa 10',
        'street_name': 'Royal Enclave, Poes Garden',
        'town': 'Poes Garden',
        'city': 'Chennai',
        'pincode': '600086',
        'state': 'Tamil Nadu'
    }, token=access_token)
    print(f"    Profile & Address updated dynamically: {prof_update['user']['door_no']} {prof_update['user']['street_name']}, {prof_update['user']['city']}")
    assert status == 200

    # 7. Wallet & Daily Login Reward Claim (Step 7)
    status, wallet_res = request('GET', '/api/wallet/', token=access_token)
    print(f"\n[7] Wallet Balance (Step 7) (Status {status}):")
    initial_coins = float(wallet_res['balance_coins'])
    print(f"    Current balance: {initial_coins} AUG Coins")

    # Claim daily 1 reward (100 coins)
    status, claim_res = request('POST', '/api/wallet/claim-daily/', {}, token=access_token)
    print(f"    Daily Reward Claimed: {claim_res.get('claimed')} | New balance: {claim_res.get('balance_coins')} coins")
    assert status == 200

    # 8. Manual Coin Generation / Credit (Step 7 #5)
    status, credit_res = request('POST', '/api/wallet/manual-credit/', {'coins': 500000.0, 'amount_inr': 5000.0, 'source': 'Patron Vault Deposit'}, token=access_token)
    print(f"\n[8] Manual Coin Credit (Step 7 Point 5) (Status {status}):")
    print(f"    Credited 500,000 Coins. New Vault Balance: {credit_res['balance_coins']:,} coins")
    assert status == 200 and credit_res['balance_coins'] >= 500000

    # 9. Recharge AUG Coins (Step 9)
    status, rech_res = request('POST', '/api/recharge/verify/', {'amount': 1000.0, 'coins': 100000.0, 'payment_method': 'razorpay'}, token=access_token)
    print(f"\n[9] Recharge Coins via Razorpay (Step 9) (Status {status}):")
    print(f"    New Vault Balance: {rech_res['new_balance']:,} coins")
    assert status == 200

    # 10. Place Order strictly using AUG Coins (Step 8)
    order_payload = {
        'product_name': 'Temple Blossom Necklace',
        'total_amount': 3776,
        'quantity': 1,
        'metal_purity': '22K Gold (916 BIS)',
        'weight_grams': 44.0,
        'delivery_name': 'Sundar Rajan',
        'delivery_phone': reg_phone,
        'door_no': 'Villa 10',
        'street_name': 'Royal Enclave',
        'city': 'Chennai',
        'pincode': '600086',
        'state': 'Tamil Nadu'
    }
    status, order_res = request('POST', '/api/orders/create/', order_payload, token=access_token)
    print(f"\n[10] Place Order with AUG Coins (Step 8) (Status {status}):")
    order_id = order_res['order']['order_id']
    coins_used = float(order_res['order']['coins_used'])
    rem_coins = float(order_res['remaining_coins'])
    print(f"     Order ID: {order_id} | Coins Used: {coins_used:,.0f} | Remaining: {rem_coins:,.0f}")
    assert status == 201

    # 11. View Order Summary (Step 10)
    status, my_orders = request('GET', '/api/orders/my-orders/', token=access_token)
    print(f"\n[11] View Order Summary (Step 10) (Status {status}):")
    print(f"     Total orders for user: {my_orders['count']} | Latest: {my_orders['orders'][0]['order_id']}")
    assert status == 200 and my_orders['count'] > 0

    # 12. Download Official BIS Hallmarked PDF Receipt (Step 11)
    status, pdf_bytes = request('GET', f"/api/orders/{order_id}/receipt/", token=access_token)
    print(f"\n[12] Download Receipt PDF (Step 11) (Status {status}):")
    print(f"     PDF downloaded successfully! Size: {len(pdf_bytes)} bytes, starts with: {pdf_bytes[:4]}")
    assert status == 200 and pdf_bytes[:4] == b'%PDF'

    print("\n==================================================================")
    print("  ALL 12 DYNAMIC DJANGO BACKEND FLOWS VALIDATED 100% SUCCESSFULLY!")
    print("==================================================================")

if __name__ == '__main__':
    main()
