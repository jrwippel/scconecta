# 🧪 Testando com LPA Strings Fake

**Como testar a instalação de eSIM sem precisar de LPA real**

---

## 🎯 O Que Foi Implementado

Agora você pode testar o fluxo completo de instalação de eSIM usando LPA Strings fake! O sistema detecta automaticamente quando é uma LPA de teste e simula o comportamento de instalação.

---

## 📱 Como Funciona

### 1. Detecção Automática
O `NativeESimService` detecta LPA Strings de teste por:
- Servidor: `test.scconecta.com`
- Palavras-chave: `TEST`, `DEMO`, `FAKE`

### 2. Simulação Realista
- ⏱️ Delay de 3 segundos (simula instalação real)
- 📋 Gera ICCID fake mas com formato válido
- ✅ Retorna sucesso ou erro baseado no código
- 📝 Logs detalhados no console

---

## 🧪 LPA Strings de Teste Disponíveis

### ✅ Sucesso (Instalação Normal)
```
LPA:1$test.scconecta.com$TEST-ABC123
LPA:1$test.scconecta.com$TEST-AMERICA
LPA:1$test.scconecta.com$TEST-BRASIL
LPA:1$test.scconecta.com$DEMO-12345
```

**Resultado:**
- ✅ Instalação bem-sucedida
- 📋 ICCID gerado: `8955141XXXXXXXXXX`
- ⏱️ Delay: 3 segundos
- ➡️ Navega para wizard

### ❌ Erro de Rede
```
LPA:1$test.scconecta.com$TEST-ERROR
LPA:1$test.scconecta.com$TEST-FAIL
LPA:1$test.scconecta.com$ERROR-123
```

**Resultado:**
- ❌ Erro: "Erro ao baixar perfil eSIM (simulado)"
- 🔴 Tipo: `networkError`
- ⏱️ Delay: 3 segundos
- ➡️ Fica na tela de ativação com mensagem de erro

### 🚫 Cancelamento pelo Usuário
```
LPA:1$test.scconecta.com$TEST-CANCEL
LPA:1$test.scconecta.com$CANCEL-123
```

**Resultado:**
- 🚫 Erro: "Instalação cancelada pelo usuário (simulado)"
- 🟡 Tipo: `userCancelled`
- ⏱️ Delay: 3 segundos
- ➡️ Fica na tela de ativação

### ⚠️ LPA Inválida
```
LPA:1$test.scconecta.com$TEST-INVALID
LPA:1$test.scconecta.com$INVALID-123
```

**Resultado:**
- ⚠️ Erro: "LPA String inválida (simulado)"
- 🟠 Tipo: `invalidLPA`
- ⏱️ Delay: 3 segundos
- ➡️ Fica na tela de ativação

---

## 🎮 Como Testar

### Teste 1: Fluxo de Sucesso

1. **Abrir app**
```bash
flutter run
```

2. **Clicar em "Simular Link do WhatsApp"**
   - Na landing page

3. **Aguardar tela de ativação carregar**
   - Deve mostrar detalhes do plano
   - LPA String será: `LPA:1$test.scconecta.com$TEST-DEMO1234` (ou similar)

4. **Clicar em "Instalar eSIM Agora"**
   - Loading aparece
   - Aguarda 3 segundos
   - ✅ Sucesso!
   - Navega para wizard

5. **Completar wizard**
   - Passo 1: eSIM Instalado ✓
   - Passo 2: Ativar Roaming
   - Passo 3: Desativar Linha
   - Concluir

### Teste 2: Erro de Rede

1. **Modificar código de ativação**
   - Usar código que contenha "ERROR"
   - Exemplo: `ERROR123`

2. **Ou modificar mock temporariamente**
```dart
// lib/services/mock_api_service.dart
'lpa_string': 'LPA:1\$test.scconecta.com\$TEST-ERROR',
```

3. **Executar fluxo**
   - Clicar em "Instalar eSIM Agora"
   - Aguarda 3 segundos
   - ❌ Erro aparece
   - Botão "Tentar Novamente" disponível

### Teste 3: Cancelamento

1. **Modificar mock**
```dart
'lpa_string': 'LPA:1\$test.scconecta.com\$TEST-CANCEL',
```

2. **Executar fluxo**
   - Clicar em "Instalar eSIM Agora"
   - Aguarda 3 segundos
   - 🚫 Mensagem de cancelamento
   - Pode tentar novamente

---

## 📝 Logs no Console

Quando você testar, verá logs assim:

### Sucesso
```
🧪 MODO TESTE: Simulando instalação de eSIM
📱 LPA String: LPA:1$test.scconecta.com$TEST-ABC123
✅ Instalação simulada com sucesso!
📋 ICCID: 8955141234567890
```

### Erro
```
🧪 MODO TESTE: Simulando instalação de eSIM
📱 LPA String: LPA:1$test.scconecta.com$TEST-ERROR
❌ Simulando erro de instalação
```

### Cancelamento
```
🧪 MODO TESTE: Simulando instalação de eSIM
📱 LPA String: LPA:1$test.scconecta.com$TEST-CANCEL
🚫 Simulando cancelamento pelo usuário
```

---

## 🔧 Personalizando Testes

### Criar Seus Próprios Cenários

Você pode criar LPA Strings customizadas seguindo o padrão:

```dart
// Sucesso
'LPA:1$test.scconecta.com$TEST-MEUCENARIO'

// Erro
'LPA:1$test.scconecta.com$TEST-ERROR-MEUCENARIO'

// Cancelamento
'LPA:1$test.scconecta.com$TEST-CANCEL-MEUCENARIO'

// LPA Inválida
'LPA:1$test.scconecta.com$TEST-INVALID-MEUCENARIO'
```

### Modificar Delay

Para testar com delays diferentes:

```dart
// lib/services/native_esim_service.dart
// Linha ~95
await Future.delayed(const Duration(seconds: 3)); // Mude aqui
```

Exemplos:
- `Duration(seconds: 1)` - Rápido (1s)
- `Duration(seconds: 10)` - Médio (10s)
- `Duration(seconds: 30)` - Realista (30s)

---

## 🎯 Cenários de Teste Recomendados

### Teste Básico (5 minutos)
1. ✅ Instalação com sucesso
2. ✅ Wizard completo
3. ✅ Conclusão

### Teste de Erros (10 minutos)
1. ❌ Erro de rede
2. 🚫 Cancelamento
3. ⚠️ LPA inválida
4. 🔄 Tentar novamente após erro

### Teste de UX (15 minutos)
1. ⏱️ Loading states
2. 🎨 Animações
3. 📱 Responsividade
4. ♿ Acessibilidade (VoiceOver/TalkBack)

### Teste de Fluxo Completo (20 minutos)
1. 📱 Landing page
2. 🔗 Simular link WhatsApp
3. 📋 Tela de ativação
4. ⬇️ Instalação
5. 🧭 Wizard
6. ✅ Conclusão

---

## 🚀 Quando Usar LPA Real

Você deve migrar para LPA real quando:

### ✅ Pronto para LPA Real
- [ ] Código nativo Android testado
- [ ] Código nativo iOS implementado
- [ ] APIs do backend prontas
- [ ] Dispositivo com eSIM disponível
- [ ] LPA String real obtida

### 🔄 Como Migrar

1. **Desativar mock**
```dart
// lib/services/esim_api_service.dart
static const bool useMockData = false;
```

2. **Configurar URL da API**
```dart
static const String baseUrl = 'https://api.scconecta.com/v1';
```

3. **Remover detecção de teste (opcional)**
```dart
// lib/services/native_esim_service.dart
// Comentar ou remover _isTestLpaString() e _simulateInstallation()
```

4. **Testar em dispositivo real**
```bash
flutter run --release
```

---

## 🐛 Troubleshooting

### Problema: "Erro inesperado"
**Solução:** Verificar logs no console

### Problema: Não simula instalação
**Solução:** Verificar se LPA contém "test.scconecta.com" ou palavras-chave

### Problema: Delay muito longo
**Solução:** Reduzir `Duration(seconds: 3)` para `Duration(seconds: 1)`

### Problema: Não navega para wizard
**Solução:** Verificar se `result.success` é `true`

---

## 📊 Comparação: Teste vs Real

| Aspecto | LPA Teste | LPA Real |
|---------|-----------|----------|
| Instalação | Simulada (3s) | Real (30-60s) |
| ICCID | Fake gerado | Real da operadora |
| Dispositivo | Qualquer | Precisa suporte eSIM |
| Internet | Não precisa | Precisa conexão |
| Operadora | Não conecta | Conecta de verdade |
| Configurações | Não aparece | Aparece em Ajustes |

---

## 🎉 Vantagens das LPA Strings de Teste

### ✅ Desenvolvimento
- Testar sem dispositivo real
- Testar sem LPA real
- Testar sem APIs prontas
- Desenvolvimento mais rápido

### ✅ Testes
- Testar cenários de erro
- Testar cancelamento
- Testar diferentes delays
- Testes automatizados

### ✅ Demonstração
- Mostrar para stakeholders
- Fazer demos
- Validar UX
- Coletar feedback

---

## 📚 Próximos Passos

1. **Agora:** Testar com LPA fake
2. **Semana 2:** Obter LPA real
3. **Semana 3:** Testar em dispositivo real
4. **Semana 4:** Integrar com APIs reais
5. **Semana 5:** Deploy

---

## 💡 Dicas

### Para Desenvolvimento
- Use LPA de sucesso para desenvolvimento normal
- Use LPA de erro para testar tratamento de erros
- Use delay curto (1s) para desenvolvimento rápido
- Use delay longo (30s) para testes realistas

### Para Demonstração
- Use LPA de sucesso
- Use delay médio (5s) para parecer real
- Prepare cenários de erro também
- Tenha screenshots prontos

### Para Testes
- Teste todos os cenários
- Teste em diferentes dispositivos
- Teste com diferentes delays
- Documente problemas encontrados

---

**Última atualização:** Março 2026  
**Status:** ✅ Funcionando  
**Testado em:** Emulador Android/iOS

---

## 🎮 Comece a Testar Agora!

```bash
# 1. Executar app
flutter run

# 2. Clicar em "Simular Link do WhatsApp"

# 3. Clicar em "Instalar eSIM Agora"

# 4. Aguardar 3 segundos

# 5. ✅ Sucesso! Wizard aparece
```

**Divirta-se testando! 🚀**
