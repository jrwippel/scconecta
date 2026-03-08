# 🧪 Como Testar no Emulador

**Validando o fluxo antes de testar no celular real**

---

## ⚠️ Importante

No emulador:
- ✅ Fluxo completo funciona
- ✅ Deep link funciona
- ✅ Telas aparecem
- ⚠️ Instalação de eSIM é SIMULADA (emulador não tem eSIM real)

---

## 🚀 Passo a Passo

### 1. Executar App no Emulador

```bash
flutter run
```

Aguarde o app abrir no emulador.

### 2. Testar Deep Link

Abra outro terminal e execute:

```bash
# Android
adb shell am start -a android.intent.action.VIEW -d "scconecta://install?lpa=LPA:1\$RSP-4040.IDEMIA.IO\$QZTI5-CGVFT-E0ISM-5EOLW"
```

**O que deve acontecer:**
- ✅ App abre (se estava fechado)
- ✅ Navega para tela de instalação
- ✅ Mostra a LPA recebida
- ✅ Botão "Instalar eSIM" aparece

### 3. Clicar em "Instalar eSIM"

**O que deve acontecer:**
- ✅ Loading aparece
- ✅ Após 3 segundos, instalação "sucesso" (simulada)
- ✅ Navega para wizard
- ✅ Wizard mostra 3 passos

### 4. Completar Wizard

**Passos:**
1. ✅ eSIM Instalado (já marcado)
2. Clicar em "Abrir Configurações" (Ativar Roaming)
3. Voltar para o app
4. Confirmar que ativou
5. Clicar em "Abrir Configurações" (Desativar Linha)
6. Voltar para o app
7. Confirmar que desativou
8. Clicar em "Concluir Configuração"
9. ✅ Dialog de sucesso aparece!

---

## 🧪 Testes Adicionais

### Teste 1: Link com LPA Diferente

```bash
adb shell am start -a android.intent.action.VIEW -d "scconecta://install?lpa=LPA:1\$test.com\$TESTE-123"
```

Deve funcionar com qualquer LPA!

### Teste 2: Link sem LPA

```bash
adb shell am start -a android.intent.action.VIEW -d "scconecta://install"
```

Deve mostrar erro: "LPA não encontrada"

### Teste 3: Simular Erro

```bash
adb shell am start -a android.intent.action.VIEW -d "scconecta://install?lpa=LPA:1\$test.com\$ERROR"
```

Deve simular erro de instalação (se LPA contém "ERROR")

---

## 📱 Testando a Página Web

### 1. Abrir Página no Navegador

No seu computador, abra:
```
file:///C:/Users/jrwip/scconecta_app/docs/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

(Ajuste o caminho para o seu)

### 2. Clicar no Botão

**O que deve acontecer:**
- ⚠️ Mostra "App não instalado" (normal, é no PC)
- ✅ Mostra botões de download

### 3. Testar no Emulador Android

Infelizmente, emulador Android não tem navegador completo. Você precisará:
- Testar no celular real, OU
- Usar Chrome DevTools para simular mobile

---

## 🔍 Verificar Logs

Enquanto testa, veja os logs:

```bash
flutter logs
```

Procure por:
- ✅ "Deep link recebido"
- ✅ "LPA String: LPA:1$..."
- ✅ "Instalando eSIM..."
- ✅ "Instalação simulada com sucesso"

---

## ✅ Checklist de Testes

### Fluxo Básico
- [ ] App abre no emulador
- [ ] Deep link funciona
- [ ] Tela de instalação aparece
- [ ] LPA é exibida corretamente
- [ ] Botão "Instalar" funciona
- [ ] Loading aparece
- [ ] Wizard aparece após instalação
- [ ] 3 passos do wizard funcionam
- [ ] Dialog de conclusão aparece

### Tratamento de Erros
- [ ] Link sem LPA mostra erro
- [ ] LPA inválida mostra erro
- [ ] Cancelamento funciona
- [ ] Botão "Tentar Novamente" funciona

### UI/UX
- [ ] Cores estão corretas
- [ ] Textos estão legíveis
- [ ] Animações são suaves
- [ ] Responsivo em diferentes tamanhos

---

## 🐛 Problemas Comuns

### Problema: Deep link não funciona

**Solução:**
```bash
# Verificar se app está instalado
adb shell pm list packages | grep scconecta

# Reinstalar
flutter run
```

### Problema: App não abre com deep link

**Solução:**
Verificar AndroidManifest.xml:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="scconecta" android:host="install"/>
</intent-filter>
```

### Problema: LPA não aparece

**Solução:**
Verificar logs:
```bash
flutter logs | grep -i lpa
```

---

## 🎯 Próximo Passo

Depois de validar no emulador:
1. ✅ Instalar no celular real
2. ✅ Testar com link do GitHub Pages
3. ✅ Instalar eSIM REAL da IDEMIA
4. ✅ Validar com cliente

---

**Status:** 🧪 Testando no Emulador  
**Próximo:** 📱 Testar no Celular Real
