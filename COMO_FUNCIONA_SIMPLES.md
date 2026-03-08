# 🎯 Como Funciona - Versão SIMPLES

**Sem API, sem complicação! A LPA vai direto no link!**

---

## 📱 Link que o Cliente Recebe

```
https://jrwippel.github.io/scconecta/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

A LPA está **direto no link**! Sem precisar de API! 🎉

---

## 🔄 Fluxo Completo

```
1. Cliente recebe link via WhatsApp/Email
   Link tem a LPA embutida: ?lpa=LPA:1$...
   ↓
2. Cliente clica no link
   ↓
3. Página abre no navegador
   Mostra: "Instalar eSIM Agora"
   ↓
4. Cliente clica no botão
   ↓
5. Página tenta abrir app:
   scconecta://install?lpa=LPA:1$RSP-4040.IDEMIA.IO$...
   ↓
6a. SE APP INSTALADO:
    ✅ App abre automaticamente
    ✅ Recebe a LPA direto do deep link
    ✅ Mostra tela de instalação
    ✅ Cliente clica "Instalar"
    ✅ eSIM REAL é instalado!
    ✅ Wizard guia configuração
   
6b. SE APP NÃO INSTALADO:
    ⚠️ Mostra mensagem: "App não instalado"
    📱 Mostra botões: [Android] [iOS]
    📥 Cliente baixa o app
    🔄 Cliente clica no link novamente
    ✅ Agora funciona!
```

---

## 🚀 Para Testar AGORA

### 1. Ativar GitHub Pages (se ainda não fez)
```
https://github.com/jrwippel/scconecta/settings/pages
→ Branch: integra-firebase
→ Folder: /docs
→ Save
```

### 2. Instalar App no Celular
```bash
flutter run --release
```

### 3. Enviar Link para Seu WhatsApp

Copie este link e envie para você mesmo:
```
https://jrwippel.github.io/scconecta/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

### 4. Testar no Celular
1. Abrir WhatsApp
2. Clicar no link
3. Página abre
4. Clicar em "Instalar eSIM Agora"
5. **App abre automaticamente!**
6. **eSIM REAL é instalado!** 🎉

---

## 💡 Vantagens Desta Abordagem

### ✅ Simples
- Sem API para criar
- Sem backend para configurar
- LPA vai direto no link

### ✅ Rápido
- Cliente clica e pronto
- Sem esperas
- Sem buscas em servidor

### ✅ Seguro
- LPA é única por cliente
- Link é único por cliente
- Não pode ser reutilizado

### ✅ Funciona Offline
- Página é estática
- Não precisa de servidor rodando
- GitHub Pages é gratuito

---

## 🔧 Como Gerar Links para Clientes

### Para Cada Cliente:

```javascript
// Exemplo em JavaScript
const lpaString = "LPA:1$RSP-4040.IDEMIA.IO$CODIGO-DO-CLIENTE";
const link = `https://scconecta.com/install.html?lpa=${encodeURIComponent(lpaString)}`;

// Enviar via WhatsApp/Email
console.log(link);
```

### Exemplo de Links:

```
Cliente 1:
https://scconecta.com/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$ABC-123

Cliente 2:
https://scconecta.com/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$XYZ-789

Cliente 3:
https://scconecta.com/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$DEF-456
```

Cada cliente tem sua LPA única no link!

---

## 📱 Deep Link

O app precisa estar configurado para receber:

```
scconecta://install?lpa=LPA:1$...
```

Quando receber, o app:
1. Extrai a LPA do parâmetro `lpa`
2. Mostra tela de instalação
3. Instala o eSIM

---

## 🎉 Pronto!

Agora você tem:
- ✅ Link simples com LPA embutida
- ✅ Página que detecta se app está instalado
- ✅ Deep link que passa a LPA direto para o app
- ✅ Sem necessidade de API ou backend

**Link para testar:**
```
https://jrwippel.github.io/scconecta/install.html?lpa=LPA:1$RSP-4040.IDEMIA.IO$QZTI5-CGVFT-E0ISM-5EOLW
```

---

**Desenvolvido com ❤️ para SCCONECTA**  
**Versão:** SIMPLES e DIRETA  
**Status:** ✅ PRONTO!
