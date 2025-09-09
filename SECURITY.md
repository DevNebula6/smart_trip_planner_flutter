# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅ |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in Smart Trip Planner Flutter, please report it responsibly.

### How to Report

1. **Do NOT create a public GitHub issue** for security vulnerabilities
2. Email the maintainers directly at: [devnebula6@gmail.com]
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Suggested fix (if available)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity (24 hours for critical, 30 days for medium/low)

### Security Measures

Our application implements several security measures:

#### Data Protection
- API keys stored securely using environment variables
- Local data encrypted using Hive's built-in encryption
- No sensitive data transmitted in plain text
- Secure HTTP communication with proper certificate validation

#### API Security
- API key rotation support
- Rate limiting awareness
- Input validation and sanitization
- Error handling that doesn't expose sensitive information

#### Authentication
- Secure session management
- Token-based authentication patterns ready for production
- Profile data protection with local storage encryption

### Security Best Practices for Contributors

#### API Key Management
```dart
// ✅ Good: Use environment variables
final apiKey = dotenv.env['GEMINI_API_KEY']!;

// ❌ Bad: Never hardcode API keys
final apiKey = 'AIzaSyC...'; // DON'T DO THIS
```

#### Input Validation
```dart
// ✅ Good: Validate user input
if (userPrompt.trim().isEmpty || userPrompt.length > 1000) {
  return Left(ValidationFailure('Invalid prompt'));
}

// ❌ Bad: Direct API calls without validation
await geminiService.generateResponse(userPrompt);
```

#### Error Handling
```dart
// ✅ Good: Generic error messages to users
return Left(ServerFailure('Unable to generate itinerary'));

// ❌ Bad: Exposing internal errors
return Left(ServerFailure('API key invalid: ${response.error}'));
```

### Dependency Security

We regularly audit our dependencies for security vulnerabilities:

- **Automated scanning**: Dependabot alerts enabled
- **Regular updates**: Dependencies updated monthly
- **Vulnerability monitoring**: Security advisories tracked
- **Minimal dependencies**: Only essential packages included

### Data Privacy

- **Local Storage**: All personal data stored locally using Hive encryption
- **API Communication**: Only necessary data sent to AI services
- **No Tracking**: No third-party analytics or tracking services
- **Data Retention**: 90-day automatic cleanup of old conversations

### Security Testing

Our security testing includes:

- **Static Analysis**: Code scanning for security vulnerabilities
- **Dependency Scanning**: Regular dependency vulnerability checks
- **Input Validation Testing**: Fuzzing and injection testing
- **API Security Testing**: Authentication and authorization testing

### Disclosure Policy

After a security issue is resolved:

1. We will publish a security advisory
2. Credit will be given to the reporter (if desired)
3. Timeline and impact will be documented
4. Fix will be included in the next release

Thank you for helping keep Smart Trip Planner Flutter secure! 🔒
