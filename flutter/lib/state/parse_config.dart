/// Back4App / Parse Server credentials for cyberAutopsy.
///
/// SAFE TO SHIP IN THE CLIENT BUNDLE:
///   - Application ID
///   - Client Key (mobile / desktop transports)
///   - JavaScript Key (web transport)
///   - .NET Key (.NET clients)
///
/// MUST NEVER BE EMBEDDED IN THIS BUNDLE — keep these in Back4App Cloud
/// Code, server-side scripts, or your secrets manager:
///   - REST API Key
///   - Webhook Key
///   - File Key
///   - Master Key
///
/// If any of those four leak (chat transcripts, screenshots, git history),
/// rotate them in the Back4App dashboard: App → Security & Keys → Change.
library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Main app identifier — the same value across every transport.
const kParseApplicationId = 'RAPUkI4hCR6Icf58WMWygE2pyzhpTP3VnPOO5j6Z';

/// Used by the native Parse SDKs (Android, iOS, macOS, Linux, Windows).
const kParseClientKey = 'n2TCNQ856ovpZYVDgN2C87vCJtyXQUzaixl7SLtE';

/// Used by browser-based clients. Flutter Web hits Back4App over HTTP from
/// a JS context, so we send this header instead of the Client Key.
const kParseJavaScriptKey = 'unCJjZCWWVF9Mxa10YCMuOZhWI1vjmlaywUzm0r2';

/// Standard Back4App Parse Server endpoint.
const kParseServerUrl = 'https://parseapi.back4app.com';

/// Picks the appropriate key for the current platform.
String parseClientKeyForPlatform() =>
    kIsWeb ? kParseJavaScriptKey : kParseClientKey;

/// Custom string field on `_User` that distinguishes admin RPO accounts
/// from contributor accounts. Set this in the Back4App dashboard to
/// promote a user; the value 'admin' grants admin-console access.
const kRoleFieldName = 'role';
