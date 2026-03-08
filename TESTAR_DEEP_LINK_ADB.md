# 🧪 Testar Deep Link via ADB

## Problema Identificado

O Chrome no Android não está abrindo o app automaticamente quando clica no link da página web. Isso é normal em modo debug.

## ✅ Solução: Testar via ADB

### 1. Abrir o deep link diretamente via ADB:

```bash
adb shell am start -W -a android.intent.action.VIEW -d "scconecta://install?lpa=LPA:1\$RSP-4040.IDEMIA.IO\$QZTI5-CGVFT-E0ISM-5EOLW"
```

**Isso deve:**
- Abrir o app SCCONECTA
- Mostrar a tela de instalação
- Processar a LPA

### 2. Ver os logs:

```bash
flutter logs
```

**Procure por:**
```
✅ LPA válida recebida: LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
Processando deep link: scconecta://install?lpa=...
```

## 🔧 Alternativa: Testar no Chrome

### Digite diretamente na barra de endereço:

```
scconecta://install?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

Pressione Enter. O Android deve perguntar "Abrir com SCCONECTA?"

## 📱 Por que a página não funciona no emulador?

1. **Modo Debug**: Apps em debug não são reconhecidos como "instalados" pelo Chrome
2. **Deep Link não verificado**: O `autoVerify` só funciona em apps assinados (release)
3. **Restrições do Chrome**: O Chrome bloqueia alguns deep links por segurança

## ✅ Solução Final: Testar em APK Release

### 1. Compile o APK:

```bash
flutter build apk --release
```

### 2. Instale no celular:

```bash
flutter install
```

### 3. Agora teste o link da página:

```
https://jrwippel.github.io/scconecta/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

**No APK release, o deep link vai funcionar perfeitamente!**

## 🎯 Resumo

| Método | Funciona no Debug? | Funciona no Release? |
|--------|-------------------|---------------------|
| Página Web → Deep Link | ❌ Não | ✅ Sim |
| ADB Command | ✅ Sim | ✅ Sim |
| Digitar no Chrome | ✅ Sim | ✅ Sim |

## 🚀 Próximo Passo

**Teste via ADB agora:**

```bash
adb shell am start -W -a android.intent.action.VIEW -d "scconecta://install?lpa=LPA:1\$RSP-4040.IDEMIA.IO\$QZTI5-CGVFT-E0ISM-5EOLW"
```

Isso vai abrir o app e você vai ver a tela de instalação funcionando! 🎉
