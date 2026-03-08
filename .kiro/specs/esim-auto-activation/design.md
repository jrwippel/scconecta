# Design Document - eSIM Auto Activation

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Flutter App (SCCONECTA Mobile)                 │  │
│  │                                                          │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │   UI       │  │  Services  │  │   Native   │       │  │
│  │  │  Screens   │  │  Business  │  │   Bridge   │       │  │
│  │  │            │  │   Logic    │  │            │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               │ HTTPS/REST
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                         API LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              API SCCONECTA (Backend)                     │  │
│  │                                                          │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  Purchase  │  │   eSIM     │  │   Notify   │       │  │
│  │  │  Endpoint  │  │  Endpoint  │  │  Endpoint  │       │  │
│  │  │            │  │            │  │            │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                      BUSINESS LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Sistema SCCONECTA (Existing System)              │  │
│  │                                                          │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  Payment   │  │   Order    │  │  Customer  │       │  │
│  │  │ Processing │  │ Management │  │    CRM     │       │  │
│  │  │            │  │            │  │            │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                    EXTERNAL SERVICES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   eSIM       │  │   WhatsApp   │  │   Firebase   │        │
│  │  Operator    │  │   Business   │  │     FCM      │        │
│  │              │  │     API      │  │              │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Design

### 1. Flutter App Components

#### 1.1 Screen Layer

**ESimActivationScreen**
- Displays activation button
- Shows eSIM details (plan, validity)
- Handles installation flow
- Error handling and retry logic

**SetupWizardScreen**
- Step-by-step configuration guide
- Progress tracking (3 steps)
- Platform-specific instructions
- Completion verification

**TravelAssistantScreen**
- Location-based suggestions
- Quick action buttons
- Status dashboard
- Settings management

**DiagnosticScreen** (already exists, enhance)
- Real-time eSIM status
- Line management
- Roaming verification
- Connectivity tests

#### 1.2 Service Layer

**ESimInstallationService**
```dart
class ESimInstallationService {
  // Install eSIM using LPA string
  Future<InstallationResult> installESim(String lpaString);
  
  // Check device compatibility
  Future<bool> isDeviceCompatible();
  
  // Get installation status
  Future<InstallationStatus> getStatus(String iccid);
  
  // Cancel installation
  Future<void> cancelInstallation();
}
```

**ApiService**
```dart
class ApiService {
  // Purchase eSIM
  Future<PurchaseResponse> purchaseESim(PurchaseRequest request);
  
  // Get eSIM details
  Future<ESimDetails> getESimDetails(String activationCode);
  
  // Confirm activation
  Future<void> confirmActivation(String activationCode, DeviceInfo device);
  
  // Get user's eSIMs
  Future<List<ESimProfile>> getUserESims(String userId);
}
```

**DeepLinkService** (already exists, enhance)
```dart
class DeepLinkService {
  // Handle activation links
  void handleActivationLink(Uri uri);
  
  // Extract activation code
  String? extractActivationCode(Uri uri);
  
  // Validate link format
  bool isValidActivationLink(Uri uri);
}
```

**TravelAssistantService**
```dart
class TravelAssistantService {
  // Detect airport location
  Future<bool> isAtAirport();
  
  // Detect country change
  Future<String?> detectCountryChange();
  
  // Send contextual notification
  Future<void> sendTravelNotification(TravelContext context);
  
  // Get travel recommendations
  List<TravelAction> getRecommendations();
}
```

**NotificationService**
```dart
class NotificationService {
  // Send push notification
  Future<void> sendNotification(NotificationData data);
  
  // Schedule notification
  Future<void> scheduleNotification(DateTime when, NotificationData data);
  
  // Handle notification tap
  void handleNotificationTap(String payload);
}
```

#### 1.3 Native Bridge Layer

**Android (MainActivity.kt)**
```kotlin
class ESimManager {
    // Install eSIM via EuiccManager
    fun installESim(lpaString: String): InstallationResult
    
    // Check eSIM support
    fun isESimSupported(): Boolean
    
    // Get installed profiles
    fun getInstalledProfiles(): List<ESimProfile>
    
    // Enable/disable profile
    fun toggleProfile(iccid: String, enable: Boolean): Boolean
    
    // Open system settings
    fun openESimSettings()
    fun openRoamingSettings()
    fun openDataSettings()
}
```

**iOS (AppDelegate.swift)**
```swift
class ESimManager {
    // Install eSIM via CoreTelephony
    func installESim(lpaString: String) -> InstallationResult
    
    // Check eSIM support
    func isESimSupported() -> Bool
    
    // Get installed profiles
    func getInstalledProfiles() -> [ESimProfile]
    
    // Open system settings
    func openESimSettings()
    func openCellularSettings()
}
```

---

## API Design

### Base URL
```
Production: https://api.scconecta.com/v1
Staging: https://api-staging.scconecta.com/v1
```

### Authentication
```
Authorization: Bearer {JWT_TOKEN}
```

### Endpoints

#### 1. Purchase eSIM

**Request:**
```http
POST /api/v1/purchase
Content-Type: application/json
Authorization: Bearer {token}

{
  "user_email": "cliente@email.com",
  "user_name": "João Silva",
  "phone": "+5511999999999",
  "plan_id": "america",
  "start_date": "2026-04-10",
  "end_date": "2026-04-20",
  "payment": {
    "method": "credit_card",
    "card_token": "tok_xxx",
    "installments": 1
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "order_id": "ORD-2026-001234",
    "activation_code": "ABC123XYZ",
    "activation_link": "https://scconecta.com/activate/ABC123XYZ",
    "status": "pending_activation",
    "created_at": "2026-04-08T10:30:00Z"
  },
  "message": "eSIM será enviado por WhatsApp em até 5 minutos"
}
```

#### 2. Get eSIM Details

**Request:**
```http
GET /api/v1/esim/{activation_code}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "activation_code": "ABC123XYZ",
    "lpa_string": "LPA:1$smdp.exemplo.com$ABC123XYZ456",
    "iccid": "8901234567890123456",
    "plan": {
      "id": "america",
      "name": "Plano América",
      "countries": ["USA", "Canada", "Mexico", "Brazil"],
      "data": "unlimited",
      "voice": "unlimited",
      "sms": "unlimited"
    },
    "validity": {
      "start_date": "2026-04-10",
      "end_date": "2026-04-20",
      "days_remaining": 12
    },
    "status": "pending_activation",
    "user": {
      "email": "cliente@email.com",
      "name": "João Silva"
    },
    "created_at": "2026-04-08T10:30:00Z"
  }
}
```

#### 3. Confirm Activation

**Request:**
```http
POST /api/v1/esim/{activation_code}/activate
Content-Type: application/json
Authorization: Bearer {token}

{
  "device_info": {
    "model": "Samsung Galaxy S24",
    "os": "Android",
    "os_version": "14",
    "imei": "123456789012345",
    "manufacturer": "Samsung"
  },
  "activated_at": "2026-04-08T11:00:00Z",
  "location": {
    "country": "BR",
    "city": "São Paulo"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "activation_code": "ABC123XYZ",
    "status": "active",
    "activated_at": "2026-04-08T11:00:00Z",
    "expires_at": "2026-04-20T23:59:59Z"
  },
  "message": "eSIM ativado com sucesso!"
}
```

#### 4. Get User's eSIMs

**Request:**
```http
GET /api/v1/user/esims
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "esims": [
      {
        "activation_code": "ABC123XYZ",
        "plan_name": "Plano América",
        "status": "active",
        "valid_until": "2026-04-20",
        "days_remaining": 12
      },
      {
        "activation_code": "DEF456ABC",
        "plan_name": "Plano Mundo",
        "status": "expired",
        "valid_until": "2026-03-15",
        "days_remaining": 0
      }
    ],
    "total": 2
  }
}
```

---

## Data Models

### ESimProfile
```dart
class ESimProfile {
  final String activationCode;
  final String lpaString;
  final String iccid;
  final PlanDetails plan;
  final ValidityPeriod validity;
  final ESimStatus status;
  final DateTime createdAt;
  final DateTime? activatedAt;
}
```

### PlanDetails
```dart
class PlanDetails {
  final String id;
  final String name;
  final List<String> countries;
  final String dataAllowance;
  final String voiceAllowance;
  final String smsAllowance;
  final double price;
}
```

### InstallationResult
```dart
class InstallationResult {
  final bool success;
  final String? iccid;
  final String? errorMessage;
  final InstallationErrorType? errorType;
}

enum InstallationErrorType {
  deviceNotSupported,
  networkError,
  invalidLPA,
  userCancelled,
  systemError
}
```

### TravelContext
```dart
class TravelContext {
  final bool isAtAirport;
  final String? currentCountry;
  final String? previousCountry;
  final bool hasActiveESim;
  final bool hasActivePersonalLine;
}
```

---

## Sequence Diagrams

### 1. Purchase and Activation Flow

```
User          App          API          System       Operator
 │             │            │             │             │
 │─Select Plan─>│            │             │             │
 │             │            │             │             │
 │─Fill Data──>│            │             │             │
 │             │            │             │             │
 │─Pay────────>│            │             │             │
 │             │            │             │             │
 │             │─Purchase──>│             │             │
 │             │            │             │             │
 │             │            │─Process────>│             │
 │             │            │             │             │
 │             │            │             │─Request────>│
 │             │            │             │   eSIM      │
 │             │            │             │             │
 │             │            │             │<─LPA String─│
 │             │            │             │             │
 │             │            │<─Order ID───│             │
 │             │            │             │             │
 │             │<─Success───│             │             │
 │             │            │             │             │
 │<─Confirmed──│            │             │             │
 │             │            │             │             │
 │             │            │             │─Send────────>│
 │             │            │             │ WhatsApp    │
 │<────────────────────────────────────────Link─────────│
 │             │            │             │             │
 │─Click Link─>│            │             │             │
 │             │            │             │             │
 │             │─Get eSIM──>│             │             │
 │             │   Details  │             │             │
 │             │            │             │             │
 │             │<─LPA String│             │             │
 │             │            │             │             │
 │<─Show UI────│            │             │             │
 │             │            │             │             │
 │─Install────>│            │             │             │
 │             │            │             │             │
 │             │─Native API─>│            │             │
 │             │  (Install) │             │             │
 │             │            │             │             │
 │             │<─Success───│             │             │
 │             │            │             │             │
 │             │─Confirm───>│             │             │
 │             │ Activation │             │             │
 │             │            │             │             │
 │<─eSIM Active│            │             │             │
```

### 2. Travel Assistant Flow

```
User          App       Location    Notification
 │             │         Service      Service
 │             │            │             │
 │             │─Monitor───>│             │
 │             │ Location   │             │
 │             │            │             │
 │             │<─Airport───│             │
 │             │  Detected  │             │
 │             │            │             │
 │             │─Send──────────────────>│
 │             │ Notification            │
 │             │                         │
 │<────────────────────────Notification──│
 │ "Desativar linha pessoal?"            │
 │                                       │
 │─Tap Notification────────────────────>│
 │                                       │
 │             │<─Handle Tap─────────────│
 │             │                         │
 │<─Open Settings─│                     │
 │  (System)      │                     │
 │                │                     │
 │─Disable Line──>│                     │
 │                │                     │
 │                │─Verify──────────────>│
 │                │ Status              │
 │                │                     │
 │<─Confirmation──│                     │
```

---

## Security Considerations

### 1. Data Protection
- All API communication over HTTPS/TLS 1.3
- JWT tokens with 24h expiration
- Refresh token mechanism
- LPA strings never stored permanently
- Sensitive data encrypted at rest

### 2. Authentication
- Firebase Authentication for user management
- JWT tokens for API authentication
- Biometric authentication option
- Session management

### 3. Authorization
- User can only access their own eSIMs
- API validates ownership before returning data
- Rate limiting on endpoints
- CORS properly configured

### 4. Privacy
- LGPD compliance
- Minimal data collection
- User consent for location tracking
- Data retention policies
- Right to deletion

---

## Performance Considerations

### 1. App Performance
- Lazy loading of screens
- Image caching
- API response caching (5 minutes)
- Background sync for status updates
- Optimized native bridge calls

### 2. API Performance
- Response time < 500ms (p95)
- CDN for static assets
- Database indexing
- Connection pooling
- Caching layer (Redis)

### 3. Network Optimization
- Retry logic with exponential backoff
- Request deduplication
- Compression (gzip)
- Pagination for lists
- Incremental updates

---

## Error Handling

### 1. App-Level Errors
```dart
enum AppError {
  networkError,
  deviceNotSupported,
  invalidActivationCode,
  installationFailed,
  permissionDenied,
  locationUnavailable
}
```

### 2. API-Level Errors
```json
{
  "success": false,
  "error": {
    "code": "ESIM_NOT_FOUND",
    "message": "eSIM não encontrado",
    "details": "O código de ativação ABC123 não existe ou expirou"
  }
}
```

### 3. Error Recovery
- Automatic retry for network errors (3 attempts)
- User-friendly error messages
- Fallback to manual instructions
- Support contact option
- Error logging for debugging

---

## Testing Strategy

### 1. Unit Tests
- Service layer logic
- Data model validation
- Utility functions
- Error handling

### 2. Integration Tests
- API communication
- Native bridge calls
- Deep link handling
- Notification flow

### 3. E2E Tests
- Complete purchase flow
- Installation process
- Wizard completion
- Travel assistant triggers

### 4. Device Testing
- Multiple Android versions (10-15)
- Multiple iOS versions (14-18)
- Different manufacturers
- eSIM-capable devices only

---

## Deployment Strategy

### 1. Phased Rollout
- Internal testing (1 week)
- Beta group (50 users, 2 weeks)
- Gradual rollout (10% → 50% → 100%)
- Monitoring and feedback

### 2. Feature Flags
- Enable/disable features remotely
- A/B testing capabilities
- Gradual feature rollout
- Emergency kill switch

### 3. Monitoring
- Crashlytics for crash reporting
- Firebase Analytics for usage
- API monitoring (response times, errors)
- User feedback collection

---

## Future Enhancements

### Phase 2 (Post-MVP)
- Multi-language support (EN, ES)
- eSIM renewal in-app
- Family plans management
- Referral program
- In-app chat support

### Phase 3 (Advanced)
- AI-powered travel recommendations
- Automatic plan suggestions
- Usage analytics dashboard
- Integration with travel apps
- Loyalty program
