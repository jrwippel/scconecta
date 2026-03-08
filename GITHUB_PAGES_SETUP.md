# 🌐 GitHub Pages - Página de Ativação de eSIM

**Simule o site real da SCCONECTA para testar o fluxo completo!**

---

## 🎯 O Que Foi Criado

Duas páginas HTML hospedadas no GitHub Pages:

1. **`index.html`** - Página principal
2. **`activate.html`** - Página de ativação (a que você vai usar)

---

## 🚀 Como Configurar GitHub Pages

### Passo 1: Fazer Commit e Push

```bash
# Adicionar arquivos
git add docs/

# Commit
git commit -m "feat: adiciona páginas GitHub Pages para teste de eSIM"

# Push
git push origin main
```

### Passo 2: Ativar GitHub Pages

1. Ir no seu repositório no GitHub
2. Clicar em **Settings**
3. No menu lateral, clicar em **Pages**
4. Em **Source**, selecionar:
   - Branch: `main`
   - Folder: `/docs`
5. Clicar em **Save**

### Passo 3: Aguardar Deploy

- GitHub vai fazer deploy automaticamente
- Aguarde 1-2 minutos
- Sua página estará disponível em:
  ```
  https://SEU-USUARIO.github.io/SEU-REPOSITORIO/
  ```

---

## 📱 Como Usar para Testar

### Teste 1: Link Simples

```
https://SEU-USUARIO.github.io/SEU-REPOSITORIO/activate.html?code=TESTE-REAL
```

**O que acontece:**
1. Abre a página no navegador
2. Mostra código: `TESTE-REAL`
3. Clica em "Instalar eSIM Agora"
4. Tenta abrir app: `scconecta://activate?code=TESTE-REAL`
5. Se app não instalado, redireciona para loja

### Teste 2: Link com Código Personalizado

```
https://SEU-USUARIO.github.io/SEU-REPOSITORIO/activate.html?code=ABC123
```

Você pode usar qualquer código!

### Teste 3: Enviar via WhatsApp

1. Copiar link:
   ```
   https://SEU-USUARIO.github.io/SEU-REPOSITORIO/activate.html?code=TESTE-REAL
   ```

2. Enviar para seu próprio WhatsApp

3. Abrir no celular

4. Clicar no botão

5. App deve abrir automaticamente!

---

## 🔧 Configurar Deep Link no App

Para o link abrir o app, você precisa configurar o deep link:

### Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity android:name=".MainActivity">
    <!-- Deep Link -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <data
            android:scheme="scconecta"
            android:host="activate" />
    </intent-filter>
</activity>
```

### iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>scconecta</string>
        </array>
    </dict>
</array>
```

### Flutter (Deep Link Handler)

```dart
// lib/main.dart
import 'package:uni_links/uni_links.dart';

void initDeepLinks() async {
  // Escuta deep links
  uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'scconecta') {
      if (uri.host == 'activate') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          // Navegar para tela de ativação
          navigatorKey.currentState?.pushNamed(
            '/esim-activation',
            arguments: code,
          );
        }
      }
    }
  });
}
```

---

## 🧪 Fluxo de Teste Completo

### 1. Preparação

```bash
# Instalar app no celular
flutter run --release

# Ou gerar APK
flutter build apk --release
# APK estará em: build/app/outputs/flutter-apk/app-release.apk
```

### 2. Enviar Link

Enviar para seu WhatsApp:
```
https://SEU-USUARIO.github.io/SEU-REPOSITORIO/activate.html?code=TESTE-REAL
```

### 3. Testar no Celular

1. Abrir WhatsApp no celular
2. Clicar no link
3. Página abre no navegador
4. Clicar em "Instalar eSIM Agora"
5. **App deve abrir automaticamente!**
6. Tela de ativação aparece com código `TESTE-REAL`

### 4. Instalar eSIM Real

Se você configurou a LPA real no mock:

```dart
// lib/services/mock_api_service.dart
if (activationCode == 'TESTE-REAL') {
  return {
    'lpa_string': 'LPA:1\$RSP-4040.IDEMIA.IO\$QZTI5-CGVFT-E0ISM-5EOLW',
    // ... resto dos dados
  };
}
```

Então quando clicar em "Instalar eSIM Agora", vai instalar DE VERDADE!

---

## 🎨 Personalizar Páginas

### Mudar Cores

```css
/* docs/activate.html */
background: linear-gradient(135deg, #8DBB1B 0%, #6A9515 100%);
/* Mude para suas cores */
```

### Mudar Textos

```html
<h1>Seu eSIM está Pronto!</h1>
<!-- Mude para seu texto -->
```

### Adicionar Logo

```html
<div class="logo">
    <img src="logo.png" alt="SCCONECTA" width="100">
</div>
```

---

## 📊 Monitorar Acessos

### Google Analytics (Opcional)

```html
<!-- Adicionar antes de </head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## 🐛 Troubleshooting

### Problema: Página não carrega

**Solução:**
1. Verificar se GitHub Pages está ativado
2. Aguardar 2-3 minutos após ativar
3. Limpar cache do navegador

### Problema: Deep link não abre app

**Solução:**
1. Verificar se app está instalado
2. Verificar configuração do AndroidManifest.xml
3. Verificar configuração do Info.plist
4. Testar deep link manualmente:
   ```bash
   # Android
   adb shell am start -a android.intent.action.VIEW -d "scconecta://activate?code=TEST"
   
   # iOS (no simulador)
   xcrun simctl openurl booted "scconecta://activate?code=TEST"
   ```

### Problema: App abre mas não navega

**Solução:**
1. Verificar se deep link handler está implementado
2. Verificar logs:
   ```bash
   flutter logs
   ```
3. Adicionar prints de debug

---

## 🎯 Próximos Passos

### Quando APIs Estiverem Prontas

1. **Criar API Mock no GitHub Pages**
   ```javascript
   // docs/api/esim/TESTE-REAL.json
   {
     "success": true,
     "data": {
       "activation_code": "TESTE-REAL",
       "lpa_string": "LPA:1$RSP-4040.IDEMIA.IO$...",
       // ... resto
     }
   }
   ```

2. **App busca da API fake**
   ```dart
   final response = await http.get(
     'https://SEU-USUARIO.github.io/SEU-REPOSITORIO/api/esim/$code.json'
   );
   ```

3. **Testar fluxo completo**
   - Link → Página → App → API fake → Instalação real

---

## 🌟 Exemplo de URL Final

Quando tudo estiver configurado:

```
https://seu-usuario.github.io/scconecta-app/activate.html?code=TESTE-REAL
```

**Fluxo:**
1. Cliente clica no link (WhatsApp/Email)
2. Página abre no navegador
3. Detecta plataforma (Android/iOS)
4. Tenta abrir app: `scconecta://activate?code=TESTE-REAL`
5. App abre e busca dados (mock ou API)
6. Mostra tela de ativação
7. Cliente clica "Instalar eSIM"
8. eSIM é instalado DE VERDADE
9. Wizard guia configuração
10. Pronto! ✅

---

## 📚 Recursos

### Documentação
- [GitHub Pages](https://pages.github.com/)
- [Deep Links Android](https://developer.android.com/training/app-links)
- [Deep Links iOS](https://developer.apple.com/ios/universal-links/)
- [uni_links Flutter](https://pub.dev/packages/uni_links)

### Ferramentas
- [QR Code Generator](https://www.qr-code-generator.com/) - Gerar QR Code do link
- [Bitly](https://bitly.com/) - Encurtar link
- [Google Analytics](https://analytics.google.com/) - Monitorar acessos

---

## 🎉 Pronto!

Agora você tem uma página web real para testar o fluxo completo de ativação de eSIM!

**Próxima ação:**
1. Fazer push para GitHub
2. Ativar GitHub Pages
3. Testar link no celular
4. Instalar eSIM real! 🚀

---

**Criado com ❤️ para SCCONECTA**  
**Versão:** 1.0  
**Data:** Março 2026
