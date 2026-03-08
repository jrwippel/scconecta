# 📱 Como Usar QR Code Real de eSIM

**Guia completo para testar com LPA String real extraída de QR Code**

---

## 🎯 O Que Você Tem

Você recebeu um **QR Code de eSIM** que contém uma **LPA String real**!

O QR Code é apenas uma representação visual da LPA String. Quando escaneado, ele revela algo como:

```
LPA:1$smdp.operadora.com$ABC123XYZ456-FULL-ACTIVATION-CODE
```

---

## 📋 Passo 1: Extrair a LPA String do QR Code

### Método 1: Site Online (Mais Rápido) ⚡

1. **Acesse:** https://webqr.com/

2. **Faça upload da imagem do QR Code** ou aponte a câmera

3. **Copie o texto** que aparecer - será algo como:
   ```
   LPA:1$smdp.operadora.com$ABC123XYZ456
   ```

### Método 2: Google Lens (Android) 📱

1. Abra **Google Fotos** ou **Google Lens**
2. Selecione a imagem do QR Code
3. Toque no ícone do Lens
4. Copie o texto que aparecer

### Método 3: Câmera do iPhone (iOS) 📱

1. Abra o app **Câmera**
2. Aponte para o QR Code
3. Toque na notificação que aparecer
4. Copie o texto da LPA String

### Método 4: Script Python 🐍

Se você salvou a imagem do QR Code:

```bash
# Instalar dependências
pip install opencv-python pyzbar pillow

# Executar script
python extrair_lpa_qrcode.py qrcode_esim.png
```

---

## 🔧 Passo 2: Configurar no App

Você tem **3 opções** para usar a LPA String real:

### Opção A: Substituir no Mock (Teste Rápido) ⚡

**Melhor para:** Testar rapidamente sem modificar muito código

1. **Abra o arquivo:**
   ```
   lib/services/mock_api_service.dart
   ```

2. **Encontre a linha 40:**
   ```dart
   'lpa_string': 'LPA:1\$test.scconecta.com\$TEST-$activationCode',
   ```

3. **Substitua pela LPA real:**
   ```dart
   'lpa_string': 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE',
   ```

4. **Salve e execute:**
   ```bash
   flutter run
   ```

5. **Teste:**
   - Clicar em "Simular Link do WhatsApp"
   - Clicar em "Instalar eSIM Agora"
   - **IMPORTANTE:** Agora vai tentar instalar de verdade!

### Opção B: Criar Código de Ativação Específico (Recomendado) ✅

**Melhor para:** Testar com código específico

1. **Abra o arquivo:**
   ```
   lib/services/mock_api_service.dart
   ```

2. **Modifique o método `getESimDetails`:**
   ```dart
   static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
     await Future.delayed(_networkDelay);

     // Detecta código específico para LPA real
     String lpaString;
     if (activationCode == 'REAL123') {
       // LPA String REAL do QR Code
       lpaString = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';
     } else {
       // LPA String de teste (simulação)
       lpaString = 'LPA:1\$test.scconecta.com\$TEST-$activationCode';
     }

     return {
       'success': true,
       'data': {
         'activation_code': activationCode,
         'lpa_string': lpaString,
         // ... resto do código
       }
     };
   }
   ```

3. **Teste:**
   - Modificar `deep_link_service.dart` para usar código 'REAL123'
   - Ou criar botão específico na landing page

### Opção C: Desativar Mock e Usar API Real (Produção) 🚀

**Melhor para:** Quando as APIs estiverem prontas

1. **Abra o arquivo:**
   ```
   lib/services/esim_api_service.dart
   ```

2. **Desative o mock:**
   ```dart
   static const bool useMockData = false;
   static const String baseUrl = 'https://api.scconecta.com/v1';
   ```

3. **Configure autenticação:**
   ```dart
   static String? _authToken = 'SEU_TOKEN_JWT_AQUI';
   ```

4. **A API deve retornar a LPA real**

---

## ⚠️ IMPORTANTE: Detecção de LPA Real

O sistema detecta automaticamente se a LPA é de teste ou real:

### LPA de Teste (Simulação)
```dart
// Será SIMULADA (não instala de verdade)
'LPA:1$test.scconecta.com$TEST-ABC123'
'LPA:1$qualquer.servidor.com$TEST-XYZ'
'LPA:1$qualquer.servidor.com$DEMO-123'
'LPA:1$qualquer.servidor.com$FAKE-456'
```

### LPA Real (Instalação Real)
```dart
// Será INSTALADA DE VERDADE
'LPA:1$smdp.operadora.com$ABC123XYZ456'
'LPA:1$prod.esim.com$REAL-CODE-HERE'
```

**Regra:** Se a LPA contém `test.scconecta.com` OU palavras `TEST`, `DEMO`, `FAKE` → Simulação  
**Caso contrário:** Instalação real

---

## 📱 Passo 3: Testar em Dispositivo Real

### Pré-requisitos

- ✅ Dispositivo Android com eSIM (Android 9+)
  - Samsung Galaxy S20+, Pixel 4+, Xiaomi Mi 11+
- ✅ Ou iPhone com eSIM (iOS 12+)
  - iPhone XS ou superior
- ✅ Conexão com internet
- ✅ LPA String real configurada

### Executar no Dispositivo

```bash
# Android
flutter run --release

# iOS
flutter run --release -d iphone
```

### Fluxo de Teste

1. **Abrir app**

2. **Clicar em "Simular Link do WhatsApp"**

3. **Clicar em "Instalar eSIM Agora"**

4. **IMPORTANTE:** Sistema operacional vai abrir dialog nativo
   - Android: Dialog do EuiccManager
   - iOS: Tela de instalação de plano celular

5. **Confirmar instalação no dialog**

6. **Aguardar download** (30-60 segundos)

7. **Verificar instalação:**
   - Android: Configurações > Conexões > Gerenciador de Chips
   - iOS: Ajustes > Celular

8. **Completar wizard no app**

---

## 🎯 Exemplo Completo

### Código Modificado

```dart
// lib/services/mock_api_service.dart

static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
  await Future.delayed(_networkDelay);

  // ========================================
  // COLE SUA LPA STRING REAL AQUI
  // ========================================
  const LPA_REAL = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';
  
  return {
    'success': true,
    'data': {
      'activation_code': activationCode,
      'lpa_string': LPA_REAL, // ← Usando LPA real
      'iccid': '8901234567890123456',
      'plan': {
        'id': 'america',
        'name': 'Plano América',
        'countries': ['USA', 'Canada', 'Mexico', 'Brasil'],
        'data': 'Ilimitado',
        'voice': 'Ilimitado',
      },
      'validity': {
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'days_remaining': 30,
      },
      'status': 'pending_activation',
      'user': {
        'email': 'demo@scconecta.com',
        'name': 'Usuário Demo',
      },
    }
  };
}
```

### Executar

```bash
# 1. Salvar arquivo
# 2. Conectar dispositivo com eSIM
# 3. Executar
flutter run --release

# 4. Testar instalação
```

---

## 🐛 Troubleshooting

### Problema 1: "Dispositivo não suporta eSIM"

**Causa:** Dispositivo não tem eSIM ou Android < 9 / iOS < 12

**Solução:**
- Verificar se dispositivo realmente tem eSIM
- Verificar versão do sistema operacional
- Testar em outro dispositivo

### Problema 2: "LPA String inválida"

**Causa:** LPA String extraída incorretamente

**Solução:**
- Verificar formato: `LPA:1$servidor$codigo`
- Verificar se não tem espaços ou quebras de linha
- Extrair novamente do QR Code

### Problema 3: "Erro ao baixar perfil"

**Causa:** Problema de rede ou LPA expirada

**Solução:**
- Verificar conexão com internet
- Tentar com WiFi e dados móveis
- Verificar se LPA não expirou
- Solicitar nova LPA

### Problema 4: Dialog nativo não aparece

**Causa:** LPA está sendo detectada como teste

**Solução:**
- Verificar se LPA não contém `test.scconecta.com`
- Verificar se LPA não contém `TEST`, `DEMO`, `FAKE`
- Ver logs: `flutter logs`

### Problema 5: "Permissões negadas"

**Causa:** App não tem permissões necessárias

**Solução Android:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_EMBEDDED_SUBSCRIPTIONS" />
```

**Solução iOS:**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCellularPlanUsageDescription</key>
<string>Precisamos instalar seu eSIM SCCONECTA</string>
```

---

## 📊 Comparação: Teste vs Real

| Aspecto | LPA Teste | LPA Real (QR Code) |
|---------|-----------|-------------------|
| Instalação | Simulada (3s) | Real (30-60s) |
| Dialog Nativo | Não aparece | Aparece |
| ICCID | Fake gerado | Real da operadora |
| Dispositivo | Qualquer | Precisa eSIM |
| Internet | Não precisa | Precisa |
| Configurações | Não aparece | Aparece em Ajustes |
| Operadora | Não conecta | Conecta de verdade |

---

## ✅ Checklist de Teste

### Antes de Testar
- [ ] LPA String extraída do QR Code
- [ ] LPA String configurada no código
- [ ] Dispositivo com eSIM disponível
- [ ] Conexão com internet ativa
- [ ] App compilado em modo release

### Durante o Teste
- [ ] App abre sem erros
- [ ] Tela de ativação carrega
- [ ] LPA String está correta
- [ ] Clicar em "Instalar eSIM Agora"
- [ ] Dialog nativo aparece
- [ ] Confirmar instalação
- [ ] Aguardar download completo

### Após Instalação
- [ ] eSIM aparece em Configurações
- [ ] Wizard aparece no app
- [ ] Completar 3 passos do wizard
- [ ] Verificar conectividade
- [ ] Testar dados móveis

---

## 🎉 Sucesso!

Se tudo funcionou:
- ✅ eSIM foi instalado de verdade
- ✅ Aparece em Configurações do sistema
- ✅ Pode ativar e usar
- ✅ Código está funcionando perfeitamente

**Parabéns! Você testou com LPA real! 🚀**

---

## 📞 Suporte

Se tiver problemas:

1. **Ver logs:**
   ```bash
   flutter logs
   ```

2. **Ver logs nativos:**
   ```bash
   # Android
   adb logcat | grep -i esim
   
   # iOS
   # Ver no Xcode Console
   ```

3. **Documentar problema:**
   - Dispositivo usado
   - Versão do sistema
   - LPA String (primeiros caracteres)
   - Mensagem de erro
   - Logs completos

---

**Última atualização:** Março 2026  
**Status:** ✅ Pronto para testar com LPA real  
**Testado em:** Emulador (simulação) + Dispositivos reais (pendente)

---

## 🚀 Próximos Passos

1. **Agora:** Extrair LPA do QR Code
2. **Hoje:** Configurar no código
3. **Hoje:** Testar em dispositivo real
4. **Amanhã:** Validar instalação
5. **Esta semana:** Documentar resultados

**Boa sorte com o teste! 🎉**
