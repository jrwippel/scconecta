# 🌐 SCCONECTA - Páginas de Ativação de eSIM

Páginas web para simular o fluxo de ativação de eSIM.

---

## 📄 Páginas Disponíveis

### 1. `index.html`
Página principal com informações gerais.

**URL:** `https://seu-usuario.github.io/seu-repo/`

### 2. `activate.html`
Página de ativação de eSIM com deep link.

**URL:** `https://seu-usuario.github.io/seu-repo/activate.html?code=CODIGO`

---

## 🚀 Como Usar

### Teste Rápido

```
https://seu-usuario.github.io/seu-repo/activate.html?code=TESTE-REAL
```

### Enviar via WhatsApp

1. Copiar link acima
2. Enviar para seu WhatsApp
3. Abrir no celular
4. Clicar em "Instalar eSIM Agora"
5. App abre automaticamente!

---

## 🔧 Configuração

### Deep Link

O app precisa estar configurado para responder ao deep link:

```
scconecta://activate?code=CODIGO
```

### Parâmetros

- `code` - Código de ativação do eSIM

---

## 📱 Fluxo

```
1. Cliente recebe link via WhatsApp/Email
   ↓
2. Clica no link
   ↓
3. Página abre no navegador
   ↓
4. Clica em "Instalar eSIM Agora"
   ↓
5. Deep link tenta abrir app
   ↓
6. Se app instalado: Abre app
   Se não: Redireciona para loja
   ↓
7. App instala eSIM automaticamente
```

---

## 🎨 Personalização

Edite os arquivos HTML para personalizar:
- Cores
- Textos
- Logo
- Informações do plano

---

## 📚 Documentação

Veja `GITHUB_PAGES_SETUP.md` para instruções completas.

---

**SCCONECTA © 2026**
