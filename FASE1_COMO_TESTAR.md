# 🧪 Como Testar a Fase 1

**Guia prático para testar a instalação automática de eSIM**

---

## 🎯 Objetivo

Validar que o fluxo completo de instalação de eSIM funciona:
1. Usuário recebe link do WhatsApp
2. Link abre o app (ou redireciona para loja)
3. App instala eSIM automaticamente
4. Wizard guia configuração

---

## 📱 TESTE 1: Simulação no Emulador (Atual)

### Pré-requisitos
- Flutter instalado
- Emulador Android ou iOS rodando
- App compilado

### Passo a Passo

1. **Iniciar app**
```bash
flutter run
```

2. **Na tela inicial (Landing)**
   - Clicar no botão "Simular Link do WhatsApp"
   - Isso simula o usuário clicando no link recebido

3. **Tela de Ativação**
   - Deve carregar automaticamente
   - Mostrar detalhes do plano (mockado)
   - Botão "Instalar eSIM Agora" deve estar visível

4. **Instalar eSIM**
   - Clicar em "Instalar eSIM Agora"
   - Loading deve aparecer
   - Após 2 segundos, deve navegar para wizard

5. **Wizard de Configuração**
   - Passo 1: eSIM Instalado (já marcado como completo)
   - Passo 2: Ativar Roaming
     - Clicar em "Abrir Configurações"
     - Voltar para o app
     - Confirmar que ativou
   - Passo 3: Desativar Linha Pessoal
     - Clicar em "Abrir Configurações"
     - Voltar para o app
     - Confirmar que desativou
   - Clicar em "Concluir Configuração"
   - Dialog de sucesso deve aparecer

### Resultado Esperado
✅ Fluxo completo funciona sem erros  
✅ Todas as telas carregam corretamente  
✅ Navegação funciona  
✅ UI está responsiva

### Limitações
⚠️ Instalação é simulada (não instala eSIM real)  
⚠️ Dados são mockados  
⚠️ Deep link não funciona (precisa de dispositivo real)

---

## 📱 TESTE 2: Dispositivo Android Real (Próximo)

### Pré-requisitos
- Dispositivo Android com eSIM (Android 9+)
- Exemplos: Samsung S20+, Pixel 4+, Xiaomi Mi 11+
- LPA String real
- Cabo USB

### Preparação

1. **Habilitar modo desenvolvedor**
   - Ir em Configurações > Sobre o telefone
   - Tocar 7x em "Número da versão"
   - Voltar e entrar em "Opções do desenvolvedor"
   - Ativar "Depuração USB"

2. **Conectar dispositivo**
```bash
# Verificar conexão
adb devices

# Deve aparecer:
# List of devices attached
# 1234567890ABCDEF    device
```

3. **Instalar app**
```bash
# Limpar build anterior
flutter clean

# Instalar no dispositivo
flutter run --release
```

### Passo a Passo

1. **Verificar compatibilidade**
   - Abrir app
   - Ir em Configurações (se tiver)
   - Verificar se mostra "Dispositivo suporta eSIM: Sim"

2. **Testar instalação REAL**
   - Clicar em "Simular Link do WhatsApp"
   - Inserir código de teste
   - Clicar em "Instalar eSIM Agora"
   - **IMPORTANTE:** Sistema Android deve abrir dialog nativo
   - Confirmar instalação no dialog
   - Aguardar download (pode levar 30-60 segundos)

3. **Verificar instalação**
   - Ir em Configurações > Conexões > Gerenciador de Chips
   - Deve aparecer novo eSIM instalado
   - Nome: SCCONECTA (ou nome da operadora)

4. **Completar wizard**
   - Voltar para o app
   - Seguir passos do wizard
   - Ativar roaming de dados
   - Desativar linha pessoal (opcional para teste)

### Resultado Esperado
✅ Dialog nativo do Android aparece  
✅ eSIM é instalado de verdade  
✅ Aparece em Configurações > Gerenciador de Chips  
✅ Wizard funciona corretamente

### Problemas Comuns

**"Dispositivo não suporta eSIM"**
- Verificar se dispositivo realmente tem eSIM
- Verificar versão do Android (mínimo 9)
- Ver logs: `adb logcat | grep -i esim`

**"LPA String inválida"**
- Verificar formato: `LPA:1$servidor$codigo`
- Pedir nova LPA ao fornecedor
- Testar com LPA de exemplo

**"Erro ao baixar perfil"**
- Verificar conexão com internet
- Tentar com WiFi e dados móveis
- Verificar se LPA não expirou

---

## 📱 TESTE 3: Dispositivo iOS Real (Futuro)

### Pré-requisitos
- iPhone XS ou superior (iOS 12+)
- LPA String real
- Cabo Lightning/USB-C
- Xcode instalado (Mac)

### Preparação

1. **Configurar dispositivo**
   - Conectar iPhone ao Mac
   - Confiar no computador
   - Abrir Xcode

2. **Instalar app**
```bash
# Abrir projeto iOS
open ios/Runner.xcworkspace

# Ou via Flutter
flutter run -d iphone
```

### Passo a Passo

1. **Verificar compatibilidade**
   - Abrir app
   - Verificar se mostra suporte a eSIM

2. **Testar instalação REAL**
   - Clicar em "Simular Link do WhatsApp"
   - Inserir código de teste
   - Clicar em "Instalar eSIM Agora"
   - **IMPORTANTE:** iOS deve abrir tela nativa de instalação
   - Confirmar instalação
   - Aguardar download

3. **Verificar instalação**
   - Ir em Ajustes > Celular
   - Deve aparecer novo plano celular
   - Nome: SCCONECTA

4. **Completar wizard**
   - Voltar para o app
   - Seguir passos do wizard
   - Ativar roaming de dados
   - Desativar linha pessoal (opcional)

### Resultado Esperado
✅ Tela nativa do iOS aparece  
✅ eSIM é instalado  
✅ Aparece em Ajustes > Celular  
✅ Wizard funciona

---

## 🌐 TESTE 4: Deep Link (Quando Configurado)

### Pré-requisitos
- App publicado (ou em TestFlight/Beta)
- Deep links configurados
- Página web criada

### Passo a Passo

1. **Enviar link via WhatsApp**
   - Enviar para seu próprio número
   - Link: `https://scconecta.com/activate/ABC123`

2. **Clicar no link**
   - No Android: deve abrir app diretamente
   - No iOS: deve abrir app diretamente
   - Se app não instalado: deve abrir loja

3. **Verificar fluxo**
   - App deve abrir na tela de ativação
   - Código ABC123 deve ser detectado automaticamente
   - Não deve pedir para inserir código manualmente

### Resultado Esperado
✅ Link abre app automaticamente  
✅ Código é detectado  
✅ Fluxo continua normalmente

---

## 🧪 TESTE 5: Cenários de Erro

### Teste 5.1: Código Inválido

1. Abrir app
2. Simular link com código inválido: `INVALID123`
3. Deve mostrar erro: "eSIM não encontrado"
4. Botão "Tentar Novamente" deve aparecer

### Teste 5.2: Sem Internet

1. Desativar WiFi e dados móveis
2. Abrir app
3. Tentar instalar eSIM
4. Deve mostrar erro: "Erro de rede"
5. Botão "Tentar Novamente" deve aparecer

### Teste 5.3: Dispositivo Incompatível

1. Testar em dispositivo sem eSIM
2. Deve mostrar: "Dispositivo não suporta eSIM"
3. Não deve permitir continuar

### Teste 5.4: Usuário Cancela

1. Iniciar instalação
2. Cancelar no dialog nativo
3. Deve voltar para tela de ativação
4. Mostrar mensagem: "Instalação cancelada"

---

## 📊 CHECKLIST DE TESTES

### Funcionalidades Básicas
- [ ] App abre sem erros
- [ ] Landing page carrega
- [ ] Botão "Simular Link" funciona
- [ ] Tela de ativação carrega
- [ ] Detalhes do plano aparecem
- [ ] Botão "Instalar" funciona
- [ ] Wizard aparece após instalação
- [ ] 3 passos do wizard funcionam
- [ ] Dialog de conclusão aparece

### Instalação Real (Android)
- [ ] Verifica compatibilidade corretamente
- [ ] Dialog nativo aparece
- [ ] eSIM é instalado de verdade
- [ ] Aparece em Configurações
- [ ] Callback de sucesso funciona
- [ ] Callback de erro funciona

### Instalação Real (iOS)
- [ ] Verifica compatibilidade corretamente
- [ ] Tela nativa aparece
- [ ] eSIM é instalado
- [ ] Aparece em Ajustes
- [ ] Callback de sucesso funciona
- [ ] Callback de erro funciona

### Tratamento de Erros
- [ ] Código inválido mostra erro
- [ ] Sem internet mostra erro
- [ ] Dispositivo incompatível mostra erro
- [ ] Cancelamento é tratado
- [ ] Botão "Tentar Novamente" funciona

### UI/UX
- [ ] Loading states funcionam
- [ ] Animações são suaves
- [ ] Textos estão corretos
- [ ] Cores estão corretas
- [ ] Responsivo em diferentes tamanhos
- [ ] Acessibilidade (VoiceOver/TalkBack)

### Deep Links (Quando Configurado)
- [ ] Link abre app (Android)
- [ ] Link abre app (iOS)
- [ ] Código é detectado automaticamente
- [ ] Fallback para loja funciona

---

## 🐛 COMO REPORTAR BUGS

### Template de Bug Report

```markdown
## Bug: [Título curto]

### Descrição
[Descreva o problema]

### Passos para Reproduzir
1. Abrir app
2. Clicar em X
3. Fazer Y
4. Ver erro Z

### Resultado Esperado
[O que deveria acontecer]

### Resultado Atual
[O que aconteceu]

### Dispositivo
- Modelo: Samsung Galaxy S21
- OS: Android 12
- Versão do App: 1.0.0

### Logs
```
[Cole os logs aqui]
```

### Screenshots
[Anexe screenshots se possível]

### Prioridade
- [ ] Crítico (app não funciona)
- [ ] Alto (funcionalidade importante quebrada)
- [ ] Médio (problema menor)
- [ ] Baixo (melhoria)
```

---

## 📝 REGISTRO DE TESTES

### Teste em [Data]

**Dispositivo:** [Modelo]  
**OS:** [Versão]  
**Testador:** [Nome]

**Resultados:**
- ✅ Funcionalidade X funcionou
- ✅ Funcionalidade Y funcionou
- ❌ Funcionalidade Z falhou (Bug #123)

**Observações:**
[Notas adicionais]

---

## 🎯 PRÓXIMOS TESTES

### Esta Semana
- [ ] Testar em Samsung Galaxy S21
- [ ] Testar em Google Pixel 5
- [ ] Testar com LPA real
- [ ] Testar cenários de erro

### Próxima Semana
- [ ] Testar em iPhone 12
- [ ] Testar deep links
- [ ] Testar em 5+ dispositivos
- [ ] Testes de performance

---

**Última atualização:** Março 2026  
**Responsável:** [Seu nome]
