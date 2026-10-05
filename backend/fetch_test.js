const jwt = require('jsonwebtoken');
const token = jwt.sign({ userId: '11111111-1111-1111-1111-111111111111', tenantId: '22222222-2222-2222-2222-222222222222', roleId: '33333333-3333-3333-3333-333333333333', roleName: 'owner', jti: 'test' }, 'avrgreen_access_secret_dev_key_change_in_production');
fetch('http://localhost:5000/api/v1/management/locations', {
  headers: { Authorization: 'Bearer ' + token }
}).then(r => r.text().then(t => console.log(r.status, t)));
