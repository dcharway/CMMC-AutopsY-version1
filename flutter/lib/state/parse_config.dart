/// Back4App / Parse Server credentials for cyberAutopsy.
///
/// The Application ID and Client Key are designed for client-side use and
/// safe to ship in the bundle — they only grant whatever permissions you
/// configure in the Back4App dashboard (Class Level Permissions, ACLs,
/// session expiry, etc.). NEVER embed the Master Key here.
library;

const kParseApplicationId = 'RAPUkI4hCR6Icf58WMWygE2pyzhpTP3VnPOO5j6Z';
const kParseClientKey = 'n2TCNQ856ovpZYVDgN2C87vCJtyXQUzaixl7SLtE';
const kParseServerUrl = 'https://parseapi.back4app.com';

/// Custom string field on `_User` that distinguishes admin RPO accounts
/// from contributor accounts. Set this in the Back4App dashboard to
/// promote a user; the value 'admin' grants admin-console access.
const kRoleFieldName = 'role';
