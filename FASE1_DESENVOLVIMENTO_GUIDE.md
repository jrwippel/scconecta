# 🚀 Guia de Desenvolvimento - Fase 1 (Iniciado)

**Status:** Em Desenvolvimento 🚧  
**Última atualização:** Março 2026  
**Progresso:** 42% (128h de 332h)

---

## ✅ O QUE JÁ ESTÁ PRONTO

### 1. Aprovação e Planejamento (100%)
- ✅ Stakeholders aprovaram R$ 45.000
- ✅ Especificação de APIs criada (aguardando backend)
- ✅ Plano de 11 semanas definido
- ✅ Milestones e pagamentos acordados

### 2. UI/UX Flutter (100%)
- ✅ `esim_activation_screen.dart` - Tela de ativação
- ✅ `esim_setup_wizard_screen.dart` - Wizard de 3 passos
- ✅ `web_redirect_screen.dart` - Simulação de página web
- ✅ Tratamento de erros e loading states
- ✅ Design responsivo e acessível

### 3. Serviços Flutter (100%)
- ✅ `esim_api_service.dart` - Cliente HTTP com mock
- ✅ `native_esim_service.dart` - Bridge Flutter ↔ Nativo
- ✅ `deep_link_service.dart` - Tratamento de deep links
- ✅ Modelos de dados completos

### 4. Android Nativo (70%)
- ✅ `ESimManager.kt` - Gerenciador de eSIM
- ✅ Validação de LPA String
- ✅ BroadcastReceiver para callbacks
- ✅ Integração com MainActivity
- ⏳ Testes em dispositivo real (pendente)

---

## 🎯 PRÓXIMOS PASSOS IMEDIATOS

### PASSO 1: Testar Android em Dispositivo Real

#### Pré-requisitos
- Dispositivo Android com suporte a eSIM (Android 9+)
- Exemplos: Samsung S20+, Pixel 4+, Xiaomi Mi 11+
- LPA String real para testes

#### Como testar

1. **Conectar dispositivo via USB**
```bash
# Verificar se dispositivo está conectado
flutter devices

# Deve aparecer algo como:
# Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30)
# SM G973F (mobile) • 1234567890ABCDEF • android-arm64 • Android 12 (API 31)
```

2. **Executar app no dispositivo**
```bash
# Limpar build anterior
flutter clean

# Instalar no dispositivo
flutter run --release
```

3. **Testar fluxo completo**
- Abrir app
- Clicar em "Simular Link do WhatsApp"
- Inserir código de teste (ex: ABC123)
- Verificar se tela de ativação carrega
- Clicar em "Instalar eSIM Agora"
- **OBSERVAR:** Sistema Android deve abrir dialog nativo de instalação

4. **Verificar logs**
```bash
# Ver logs do Android
flutter logs

# Ou usar adb diretamente
adb logcat | grep -i esim
```

#### Problemas Comuns

**Problema:** "Dispositivo não suporta eSIM"
```kotlin
// Verificar se EuiccManager está habilitado
val euiccManager = getSystemService(Context.EUICC_SERVICE) as? EuiccManager
Log.d("ESim", "isEnabled: ${euiccManager?.isEnabled}")
Log.d("ESim", "EID: ${euiccManager?.eid}")
```

**Problema:** "LPA String inválida"
```kotlin
// Formato correto: LPA:1$servidor$codigo
// Exemplo: LPA:1$smdp.gsma.com$ABC123XYZ456-FULL-CODE
```

**Problema:** "Permissões negadas"
```xml
<!-- Adicionar em AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_EMBEDDED_SUBSCRIPTIONS" />
```

---

### PASSO 2: Obter LPA String Real

#### Opção A: Solicitar ao fornecedor de eSIM
Contatar o fornecedor que a SCCONECTA usa e solicitar:
- 5-10 LPA Strings de teste
- Documentação da API deles
- Ambiente de sandbox

#### Opção B: Usar serviço de teste
Alguns provedores oferecem eSIMs de teste gratuitos:
- Truphone (https://www.truphone.com/developer/)
- Twilio (https://www.twilio.com/docs/iot/supersim)

#### Opção C: Criar mock mais realista
Enquanto não tem LPA real, melhorar o mock:

```dart
// lib/services/native_esim_service.dart
static Future<InstallationResult> installESim(String lpaString) async {
  // Simular delay de instalação real (10-30 segundos)
  await Future.delayed(const Duration(seconds: 15));
  
  // Simular diferentes resultados baseado no código
  if (lpaString.contains('ERROR')) {
    return InstallationResult(
      success: false,
      errorMessage: 'Erro ao baixar perfil eSIM',
      errorType: InstallationErrorType.networkError,
    );
  }
  
  if (lpaString.contains('CANCEL')) {
    return InstallationResult(
      success: false,
      errorMessage: 'Instalação cancelada pelo usuário',
      errorType: InstallationErrorType.userCancelled,
    );
  }
  
  // Sucesso
  return InstallationResult(
    success: true,
    iccid: '89014103211118510720', // ICCID fake mas realista
  );
}
```

---

### PASSO 3: Implementar iOS (40 horas)

#### 3.1. Criar ESimManager.swift

```bash
# Criar arquivo Swift
touch ios/Runner/ESimManager.swift
```

```swift
// ios/Runner/ESimManager.swift
import Foundation
import CoreTelephony

@available(iOS 12.0, *)
class ESimManager {
    
    static let shared = ESimManager()
    private let planProvisioning = CTCellularPlanProvisioning()
    
    /// Verifica se dispositivo suporta eSIM
    func isDeviceSupported() -> Bool {
        if #available(iOS 12.0, *) {
            return planProvisioning.supportsCellularPlan()
        }
        return false
    }
    
    /// Instala eSIM usando LPA String
    func installESim(lpaString: String, completion: @escaping (Bool, String?, String?) -> Void) {
        guard isDeviceSupported() else {
            completion(false, "Dispositivo não suporta eSIM", "deviceNotSupported")
            return
        }
        
        guard isValidLpaString(lpaString) else {
            completion(false, "LPA String inválida", "invalidLPA")
            return
        }
        
        // Criar CTCellularPlanProvisioningRequest
        let request = CTCellularPlanProvisioningRequest()
        request.address = lpaString
        
        // Instalar
        planProvisioning.addPlan(with: request) { result in
            switch result {
            case .success:
                completion(true, nil, nil)
                
            case .fail:
                completion(false, "Falha na instalação", "installationError")
                
            case .unknown:
                completion(false, "Erro desconhecido", "unknownError")
                
            @unknown default:
                completion(false, "Erro inesperado", "systemError")
            }
        }
    }
    
    /// Valida formato da LPA String
    private func isValidLpaString(_ lpaString: String) -> Bool {
        return lpaString.hasPrefix("LPA:1$") && lpaString.split(separator: "$").count >= 3
    }
}
```

#### 3.2. Atualizar AppDelegate.swift

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let eSimChannel = FlutterMethodChannel(
            name: "com.scconecta/esim",
            binaryMessenger: controller.binaryMessenger
        )
        
        eSimChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "isDeviceSupported":
                if #available(iOS 12.0, *) {
                    let isSupported = ESimManager.shared.isDeviceSupported()
                    result(isSupported)
                } else {
                    result(false)
                }
                
            case "installESim":
                guard let args = call.arguments as? [String: Any],
                      let lpaString = args["lpaString"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENT", 
                                       message: "LPA String é obrigatório", 
                                       details: nil))
                    return
                }
                
                if #available(iOS 12.0, *) {
                    ESimManager.shared.installESim(lpaString: lpaString) { success, errorMessage, errorType in
                        result([
                            "success": success,
                            "iccid": success ? "89014103211118510720" : nil,
                            "errorMessage": errorMessage,
                            "errorType": errorType
                        ])
                    }
                } else {
                    result([
                        "success": false,
                        "errorMessage": "iOS 12 ou superior é necessário",
                        "errorType": "deviceNotSupported"
                    ])
                }
                
            case "openRoamingSettings":
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                result(nil)
                
            case "openLineSettings":
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                result(nil)
                
            case "openGeneralSettings":
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### 3.3. Configurar Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCellularPlanUsageDescription</key>
<string>Precisamos instalar seu eSIM SCCONECTA</string>
```

#### 3.4. Testar no iOS

```bash
# Abrir projeto no Xcode
open ios/Runner.xcworkspace

# Ou executar direto
flutter run -d iphone
```

---

### PASSO 4: Remover Simulações de Teste

Quando as APIs estiverem prontas e você tiver LPA Strings reais:

#### 4.1. Remover forçamento de compatibilidade

```dart
// lib/screens/esim_activation_screen.dart
// ANTES (linha 39):
final supported = true; // FORÇADO PARA TESTES

// DEPOIS:
final supported = await NativeESimService.isDeviceSupported();
```

#### 4.2. Remover simulação de instalação

```dart
// lib/screens/esim_activation_screen.dart
// ANTES (linhas 60-67):
final result = InstallationResult(
  success: true,
  iccid: '8901234567890123456',
);

// DEPOIS:
final result = await NativeESimService.installESim(
  _esimDetails!.lpaString,
);
```

#### 4.3. Ativar API real

```dart
// lib/services/esim_api_service.dart
// ANTES:
static const bool useMockData = true;

// DEPOIS:
static const bool useMockData = false;
static const String baseUrl = 'https://api.scconecta.com/v1';
```

---

### PASSO 5: Configurar Deep Links Universais

#### 5.1. Android - App Links

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity android:name=".MainActivity">
    <!-- Deep Links -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <data
            android:scheme="https"
            android:host="scconecta.com"
            android:pathPrefix="/activate" />
    </intent-filter>
</activity>
```

Criar arquivo no servidor:
```json
// https://scconecta.com/.well-known/assetlinks.json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.scconecta_app",
    "sha256_cert_fingerprints": [
      "SHA256_DO_SEU_CERTIFICADO"
    ]
  }
}]
```

#### 5.2. iOS - Universal Links

```xml
<!-- ios/Runner/Info.plist -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:scconecta.com</string>
</array>
```

Criar arquivo no servidor:
```json
// https://scconecta.com/.well-known/apple-app-site-association
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAM_ID.com.example.scconecta_app",
      "paths": ["/activate/*"]
    }]
  }
}
```

---

## 🧪 TESTES ESSENCIAIS

### Teste 1: Verificação de Compatibilidade
```dart
// Testar em diferentes dispositivos
final supported = await NativeESimService.isDeviceSupported();
print('Suporta eSIM: $supported');
```

### Teste 2: Instalação com LPA Real
```dart
// Usar LPA String real
final result = await NativeESimService.installESim(
  'LPA:1$smdp.gsma.com$ABC123XYZ456-FULL-CODE'
);
print('Sucesso: ${result.success}');
print('ICCID: ${result.iccid}');
```

### Teste 3: Fluxo Completo
1. Abrir link: `https://scconecta.com/activate/ABC123`
2. App deve abrir automaticamente
3. Tela de ativação deve carregar
4. Instalar eSIM
5. Wizard deve aparecer
6. Completar 3 passos

### Teste 4: Tratamento de Erros
- Código inválido
- Rede offline
- Usuário cancela instalação
- Dispositivo incompatível

---

## 📱 DISPOSITIVOS PARA TESTES

### Android (Mínimo 5 dispositivos)
- ✅ Samsung Galaxy S20+ (Android 11+)
- ✅ Google Pixel 4 (Android 10+)
- ✅ Xiaomi Mi 11 (Android 11+)
- ✅ Motorola Edge+ (Android 10+)
- ✅ OnePlus 8 Pro (Android 11+)

### iOS (Mínimo 3 dispositivos)
- ✅ iPhone XS (iOS 14+)
- ✅ iPhone 11 Pro (iOS 15+)
- ✅ iPhone 13 (iOS 16+)

---

## 🚨 BLOQUEADORES ATUAIS

### 1. APIs do Backend (CRÍTICO)
**Status:** Não iniciadas  
**Impacto:** Médio (podemos continuar com mock)  
**Ação:** Acompanhar semanalmente

**O que fazer enquanto espera:**
- Continuar desenvolvimento nativo
- Melhorar UI/UX
- Criar testes automatizados
- Documentar código

### 2. LPA String Real (ALTO)
**Status:** Não temos  
**Impacto:** Alto (não podemos testar instalação real)  
**Ação:** Solicitar ao fornecedor

**Alternativas:**
- Usar serviços de teste (Truphone, Twilio)
- Melhorar simulação
- Focar em outras partes do app

### 3. Dispositivos com eSIM (ALTO)
**Status:** Necessário para testes  
**Impacto:** Alto  
**Ação:** Conseguir emprestado ou comprar

**Opções:**
- Pedir emprestado de amigos/família
- Comprar usado (mais barato)
- Usar serviço de device farm (AWS Device Farm, Firebase Test Lab)

---

## 💡 DICAS IMPORTANTES

### 1. Desenvolvimento Paralelo
Enquanto aguarda APIs, você pode:
- ✅ Implementar iOS
- ✅ Melhorar UI/UX
- ✅ Criar testes unitários
- ✅ Documentar código
- ✅ Preparar deep links

### 2. Testes sem LPA Real
Use simulações realistas:
```dart
// Simular delay de 15 segundos
await Future.delayed(Duration(seconds: 15));

// Simular diferentes cenários
if (testCase == 'success') return success;
if (testCase == 'error') return error;
if (testCase == 'cancel') return cancelled;
```

### 3. Logs Detalhados
Adicione logs em todos os pontos críticos:
```kotlin
// Android
Log.d("ESim", "Iniciando instalação: $lpaString")
Log.d("ESim", "Resultado: $resultCode")
```

```swift
// iOS
print("ESim: Iniciando instalação: \(lpaString)")
print("ESim: Resultado: \(result)")
```

### 4. Tratamento de Erros
Sempre trate todos os casos:
- Sucesso
- Erro de rede
- Usuário cancelou
- Dispositivo incompatível
- LPA inválida
- Timeout

---

## 📊 PROGRESSO ATUAL

```
Total: 332 horas
Concluído: 128 horas (42%)
Restante: 204 horas (58%)

UI/UX:           ████████████████████ 100% (60h)
Serviços:        ████████████████████ 100% (40h)
Android:         ██████████████░░░░░░  70% (28h)
iOS:             ░░░░░░░░░░░░░░░░░░░░   0% (0h)
API Integration: ░░░░░░░░░░░░░░░░░░░░   0% (0h)
Deep Links:      ░░░░░░░░░░░░░░░░░░░░   0% (0h)
Testes:          ░░░░░░░░░░░░░░░░░░░░   0% (0h)
Deploy:          ░░░░░░░░░░░░░░░░░░░░   0% (0h)
```

---

## 🎯 META DESTA SEMANA

- [ ] Testar Android em dispositivo real
- [ ] Obter LPA String real (ou melhorar mock)
- [ ] Iniciar implementação iOS (20%)
- [ ] Documentar problemas encontrados

**Horas previstas:** 40h  
**Progresso esperado:** 42% → 55%

---

## 📞 SUPORTE

**Dúvidas sobre Android:**
- Documentação: https://developer.android.com/reference/android/telephony/euicc/EuiccManager
- Stack Overflow: [android] [esim]

**Dúvidas sobre iOS:**
- Documentação: https://developer.apple.com/documentation/coretelephony
- Stack Overflow: [ios] [esim]

**Dúvidas sobre Flutter:**
- Documentação: https://flutter.dev/docs
- Discord: Flutter Community

---

**Última atualização:** Março 2026  
**Próxima revisão:** Fim desta semana  
**Responsável:** [Seu nome]
