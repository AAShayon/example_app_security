# Enhanced Secure Flutter Application

This project demonstrates advanced security implementations for Flutter applications to protect against various attack vectors including endpoint exposure, data interception, and reverse engineering attempts.

## Enhanced Security Features

### 1. Endpoint Obfuscation
- Dynamic endpoint generation to prevent endpoint discovery
- Time-based endpoint rotation
- Request signature verification
- Encrypted parameter transmission

### 2. Advanced Device Security
- Root/jailbreak detection with multiple verification methods
- Emulator detection
- Debugger attachment detection
- Integrity verification of app binaries

### 3. Network Security
- Certificate pinning to prevent man-in-the-middle attacks
- Secure HTTP client with enhanced validation
- Request/response encryption
- Session-based authentication tokens

### 4. Data Protection
- Secure storage using platform-specific secure storage (Android Keystore, iOS Keychain)
- In-memory data obfuscation
- Encrypted communication channels
- Secure random number generation

### 5. Anti-Tampering
- App integrity verification
- Runtime security checks
- Anti-debugging measures
- Secure session management

## Architecture

```
lib/
├── security/
│   ├── enhanced_security_manager.dart    # Comprehensive security checks
│   ├── enhanced_network_security.dart    # Advanced network security
│   ├── security_manager.dart            # Main security orchestrator
│   ├── device_security.dart             # Device-level security
│   ├── screen_security.dart             # Screen capture protection
│   └── app_integrity.dart               # App integrity checks
├── services/
│   └── api_service.dart                 # Secure API communication
└── main.dart                           # App entry point
```

## Security Implementation Details

### Endpoint Obfuscation
The application implements multiple layers of endpoint protection:
- Endpoints are dynamically generated using time-based tokens
- URL paths are obfuscated and rotated periodically
- Request signatures prevent replay attacks
- All communication is encrypted end-to-end

### Certificate Pinning
Certificate pinning is implemented to prevent man-in-the-middle attacks:
- The app validates server certificates against known fingerprints
- Communication is terminated if certificate validation fails
- Multiple backup validation methods ensure reliability

### Secure Storage
Sensitive data is stored using platform-specific secure storage:
- API keys are stored in Android Keystore or iOS Keychain
- Data is encrypted at rest using platform-native encryption
- Access to secure storage is protected by system-level security

### Runtime Security Checks
The application performs continuous security validation:
- Periodic checks for rooted/jailbroken devices
- Verification of app integrity
- Detection of debugging tools
- Validation of secure environment

## Platform-Specific Security

### Android Security
- Uses EncryptedSharedPreferences for secure data storage
- Implements Android Keystore for encryption key management
- Validates app signature to detect tampering
- Prevents screenshots and screen recording in sensitive areas

### iOS Security
- Uses Keychain Services for secure data storage
- Implements app transport security for network communication
- Validates app integrity using system APIs
- Prevents screen capture in sensitive areas

## Security Headers
All API requests include security headers:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- X-Permitted-Cross-Domain-Policies: none
- Referrer-Policy: no-referrer
- Cache-Control: no-store, no-cache, must-revalidate, proxy-revalidate

## Anti-Reverse Engineering
- Code obfuscation using dart2js in release builds
- String encryption to hide sensitive information
- Control flow obfuscation to complicate analysis
- Debug information removal in production builds

## Session Management
- Time-based session tokens
- Automatic session invalidation
- Secure token storage and retrieval
- Session replay prevention

## Building for Production

To ensure maximum security in production:

1. Enable code obfuscation:
   ```bash
   flutter build apk --obfuscate --split-debug-info=debug_info/
   ```

2. Use release mode for production builds:
   ```bash
   flutter build apk --release
   ```

3. Ensure all security checks are enabled (not skipped in release)

## Testing Security Features

Security features can be tested in debug mode with appropriate flags, but note that:
- Some security checks are disabled in debug mode
- Root/jailbreak detection may not work on development devices
- Certificate pinning should be tested in release mode

## Dependencies

- `dio`: Advanced HTTP client with interceptors
- `flutter_secure_storage`: Platform-specific secure storage
- `crypto`: Cryptographic functions
- `connectivity_plus`: Network connectivity detection
- `package_info_plus`: App package information

## Security Best Practices Implemented

1. **Never store secrets in plain text** - All sensitive data is encrypted at rest
2. **Use platform-specific secure storage** - Android Keystore and iOS Keychain
3. **Implement multiple layers of security** - Defense in depth approach
4. **Obfuscate sensitive data in memory** - Data is obfuscated when not in use
5. **Prevent debugging and tampering** - Debugger and tamper detection
6. **Sanitize error messages** - No sensitive information in error messages
7. **Add security headers to all requests** - Protection against common web vulnerabilities
8. **Implement integrity checks** - Verify app hasn't been modified
9. **Use secure random number generation** - Cryptographically secure random numbers
10. **Encrypt data in transit** - All network communication is secured
11. **Endpoint obfuscation** - Prevents endpoint discovery and scraping
12. **Runtime security validation** - Continuous security monitoring

## API Security

This app uses secure communication patterns:
- All API communication is encrypted using HTTPS
- Requests include authentication tokens
- Endpoints are obfuscated to prevent discovery
- Request signatures prevent replay attacks

## License

This project is licensed under the MIT License - see the LICENSE file for details.