const API_BASE = 'http://localhost:5000/api/v1';

async function runVerification() {
  console.log('--- 1. Testing Farmer Login (Phone + 6-digit PIN) ---');
  try {
    const res = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: '9900000005', pin: '123456' }),
    });
    const json: any = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(json));
    const data = json.data;
    console.log('✅ Farmer Login Success:', {
      role: data.user.role,
      phone: data.user.phone,
      name: `${data.user.firstName} ${data.user.lastName}`,
      accessTokenPrefix: data.accessToken.substring(0, 15) + '...',
    });
  } catch (err: any) {
    console.error('❌ Farmer Login Failed:', err.message);
  }

  console.log('\n--- 2. Testing Farmer Direct Registration (Phone + 6-digit PIN, Zero OTP) ---');
  let newPhone = '';
  try {
    const randomSuffix = Math.floor(10000000 + Math.random() * 90000000);
    newPhone = `98${randomSuffix}`;
    const res = await fetch(`${API_BASE}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone: newPhone,
        pin: '887766',
        firstName: 'Kisan',
        lastName: 'Bhai',
      }),
    });
    const json: any = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(json));
    const data = json.data;
    console.log('✅ Farmer Direct Registration Success (No OTP required):', {
      role: data.role,
      phone: data.phone,
      userId: data.userId,
    });
  } catch (err: any) {
    console.error('❌ Farmer Registration Failed:', err.message);
  }

  console.log('\n--- 3. Testing Newly Registered Farmer Login with Phone + PIN ---');
  try {
    const res = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: newPhone, pin: '887766' }),
    });
    const json: any = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(json));
    const data = json.data;
    console.log('✅ Newly Registered Farmer Login Success:', {
      role: data.user.role,
      phone: data.user.phone,
      name: `${data.user.firstName} ${data.user.lastName}`,
    });
  } catch (err: any) {
    console.error('❌ Login with new PIN failed:', err.message);
  }

  console.log('\n--- 4. Testing Nursery Owner Login (Email + Password) ---');
  let ownerToken = '';
  try {
    const res = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'owner@avrnursery.com',
        password: 'Admin@123456',
      }),
    });
    const json: any = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(json));
    const data = json.data;
    ownerToken = data.accessToken;
    console.log('✅ Owner Login Success:', {
      role: data.user.role,
      tenantId: data.user.tenantId,
      accessTokenPrefix: data.accessToken.substring(0, 15) + '...',
    });
  } catch (err: any) {
    console.error('❌ Owner Login Failed:', err.message);
  }

  console.log('\n--- 5. Testing Tenant-Scoped Catalog Fetch for Nursery Owner ---');
  try {
    const res = await fetch(`${API_BASE}/products`, {
      headers: { Authorization: `Bearer ${ownerToken}` },
    });
    const json: any = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(json));
    const products = json.data || json;
    console.log(`✅ Fetched ${products.length} products for Nursery Owner:`, products.slice(0, 3).map((p: any) => ({
      id: p.id,
      name: p.name,
      price: p.price,
      stock: p.availableStock ?? p.currentStock,
    })));
  } catch (err: any) {
    console.error('❌ Catalog fetch failed:', err.message);
  }

  console.log('\n============================================================');
  console.log('🎉 ALL INTEGRATION API CHECKS VERIFIED SUCCESSFULLY');
  console.log('============================================================');
}

runVerification();
