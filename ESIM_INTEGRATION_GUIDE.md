# Guia de Integração eSIM - SCCONECTA

## 📱 Visão Geral

Este guia explica como funciona a integração completa do eSIM com o app SCCONECTA, incluindo deep links, detecção automática e tutorial de configuração.

## 🔗 Sistema de Deep Links

### Links Suportados

O app responde aos seguintes formatos de link:

1. **HTTPS (Universal Link)**
   ```
   https://scconecta.com/esim/install?iccid=89010123456789
   ```

2. **Custom Scheme**
   ```
   scconecta://esim/install?iccid=89010123456789
   ```

### Comportamento

- **App instalado**: Abre o app automaticamente e mostra o tutorial
- **App NÃO instalado**: Abre página web sugerindo instalação

## 🌐 Página Web de Fallback

Crie uma página em `https://scconecta.com/esim/install` com o seguinte conteúdo:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instalar eSIM SCCONECTA</title>
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background: #F1F8E9;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 400px;
            margin: 50px auto;
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .logo {
            width: 80px;
            height: 80px;
            background: #8DBB1B;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
        }
        h1 {
            color: #333;
            font-size: 24px;
            margin-bottom: 10px;
        }
        p {
            color: #666;
            margin-bottom: 30px;
        }
        .btn {
            display: inline-block;
            padding: 15px 30px;
            margin: 10px;
            background: #8DBB1B;
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-weight: bold;
        }
        .btn-secondary {
            background: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">📱</div>
        <h1>eSIM SCCONECTA</h1>
        <p>Para melhor experiência e configuração guiada, instale nosso app!</p>
        
        <a href="https://play.google.com/store/apps/details?id=com.example.scconecta_app" class="btn">
            📥 Baixar no Google Play
        </a>
        
        <a href="https://apps.apple.com/app/scconecta" class="btn">
            📥 Baixar na App Store
        </a>
        
        <br><br>
        
        <a href="#manual" class="btn btn-secondary" onclick="showManual()">
            📖 Ver instruções manuais
        </a>
        
        <div id="manual" style="display:none; margin-top:30px; text-align:left;">
            <h3>Instruções Manuais</h3>
            <ol>
                <li>Escaneie o QR Code do eSIM</li>
                <li>Aguarde a instalação</li>
                <li>Ative o roaming do eSIM</li>
                <li>Desative sua linha pessoal ao chegar no destino</li>
            </ol>
        </div>
    </div>
    
    <script>
        // Tenta abrir o app
        window.location = 'scconecta://esim/install' + window.location.search;
        
        function showManual() {
            document.getElementById('manual').style.display = 'block';
        }
        
        // Se o app não abrir em 2 segundos, mostra os botões
        setTimeout(() => {
            document.querySelector('.container').style.display = 'block';
        }, 2000);
    </script>
</body>
</html>
```

## 🔍 Detecção Automática de eSIM

O app monitora automaticamente quando um novo eSIM é instalado:

1. **Verifica a cada 2 segundos** se há novas linhas
2. **Identifica eSIMs SCCONECTA** pelo ICCID
3. **Mostra tutorial automaticamente** na primeira vez
4. **Não mostra novamente** para o mesmo eSIM

### Configurar Prefixos de ICCID

Edite o arquivo `lib/services/esim_detector_service.dart`:

```dart
static const List<String> scconectaICCIDPrefixes = [
  '8901', // Seu prefixo real aqui
  '8902', // Adicione outros se necessário
];
```

## 📋 Fluxo Completo

### Cenário 1: Usuário com App Instalado

1. Usuário compra eSIM no app
2. Recebe QR Code por email
3. Escaneia QR Code nas configurações do celular
4. eSIM é instalado
5. **App detecta automaticamente** o novo eSIM
6. **Tutorial aparece automaticamente**
7. Usuário segue o checklist:
   - ✅ eSIM instalado
   - ⚠️ Ativar roaming do eSIM
   - ⚠️ Desativar linha pessoal
8. Clica em "Verificar Configuração"
9. Vai para tela de diagnóstico

### Cenário 2: Usuário SEM App Instalado

1. Usuário compra eSIM (site ou outro canal)
2. Recebe link: `https://scconecta.com/esim/install?iccid=xxxxx`
3. Clica no link
4. **Página web abre** sugerindo instalar o app
5. Usuário instala o app
6. Clica no link novamente
7. **App abre automaticamente** com o tutorial

### Cenário 3: Deep Link Direto

1. Email/SMS contém link: `scconecta://esim/install?iccid=xxxxx`
2. Usuário clica
3. Se app instalado: abre direto no tutorial
4. Se app não instalado: sistema pergunta se quer instalar

## 🔧 Configuração Técnica

### Android

1. **AndroidManifest.xml** - Já configurado com intent-filters
2. **MainActivity.kt** - Métodos nativos para detectar eSIM
3. **Deep Links** - Suporta HTTPS e custom scheme

### iOS (Futuro)

1. Adicionar em `Info.plist`:
```xml
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

2. Configurar Associated Domains para Universal Links

## 📊 Monitoramento

O app salva em `SharedPreferences`:
- `tutorial_shown_<iccid>`: Timestamp de quando o tutorial foi mostrado
- Evita mostrar múltiplas vezes para o mesmo eSIM

## 🎯 Próximos Passos

1. **Configurar domínio**: Registrar `scconecta.com` e criar página de fallback
2. **Testar deep links**: Usar `adb` para testar no Android
3. **Ajustar prefixos ICCID**: Configurar com os prefixos reais da operadora
4. **Push notifications**: Adicionar notificação quando eSIM for ativado
5. **Analytics**: Rastrear quantos usuários instalam via deep link

## 🧪 Como Testar

### Testar Deep Link no Android

```bash
# Testar HTTPS link
adb shell am start -W -a android.intent.action.VIEW -d "https://scconecta.com/esim/install?iccid=89010123456789" com.example.scconecta_app

# Testar custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "scconecta://esim/install?iccid=89010123456789" com.example.scconecta_app
```

### Simular Instalação de eSIM

O app já tem sistema de simulação na tela de diagnóstico. Para testar a detecção:

1. Modifique temporariamente `esim_detector_service.dart`
2. Force retorno de `hasNewESim: true`
3. Teste o fluxo completo

## 📞 Suporte

Para dúvidas sobre a integração, consulte:
- Documentação do carrier/operadora
- Especificações GSMA para eSIM
- Guias de deep linking do Flutter
