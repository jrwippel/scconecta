# 🔌 Especificação de APIs - Backend SCCONECTA

## 📌 Prioridade: CRÍTICA
**Estas 2 APIs são bloqueadoras para o desenvolvimento mobile**

---

## 🎯 Resumo Executivo

O time de backend precisa criar **2 endpoints REST** que permitirão o app mobile:
1. Buscar informações do eSIM comprado
2. Confirmar que o eSIM foi instalado com sucesso

**Prazo:** 2 semanas (Semanas 1-2 do projeto)  
**Ambiente:** Staging primeiro, depois produção

---

## 📡 API 1: Buscar Detalhes do eSIM

### Endpoint
```
GET /api/v1/esim/{activation_code}
```

### Descrição
Retorna todas as informações necessárias para instalar um eSIM, incluindo a LPA String.

### Autenticação
```
Authorization: Bearer {JWT_TOKEN}
```
Ou pode ser público se o `activation_code` for suficientemente seguro (UUID).

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| activation_code | string (path) | Sim | Código único de ativação gerado na compra |

### Request Example
```http
GET /api/v1/esim/ABC123XYZ456 HTTP/1.1
Host: api.scconecta.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Success (200 OK)
```json
{
  "success": true,
  "data": {
    "activation_code": "ABC123XYZ456",
    "lpa_string": "LPA:1$smdp.gsma.com$ABC123XYZ456-FULL-CODE",
    "iccid": "8901234567890123456",
    "plan": {
      "id": "america",
      "name": "Plano América",
      "countries": ["USA", "Canada", "Mexico", "Brasil"],
      "data": "Ilimitado",
      "voice": "Ilimitado",
      "sms": "Ilimitado",
      "price": 199.90
    },
    "validity": {
      "start_date": "2026-03-10T00:00:00Z",
      "end_date": "2026-04-10T23:59:59Z",
      "days_remaining": 31
    },
    "status": "pending_activation",
    "user": {
      "email": "cliente@email.com",
      "name": "João Silva",
      "phone": "+5511999999999"
    },
    "created_at": "2026-03-08T10:30:00Z"
  }
}
```

### Response Error (404 Not Found)
```json
{
  "success": false,
  "error": {
    "code": "ESIM_NOT_FOUND",
    "message": "eSIM não encontrado",
    "details": "O código de ativação ABC123 não existe ou já expirou"
  }
}
```

### Response Error (401 Unauthorized)
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Token inválido ou expirado",
    "details": "Por favor, faça login novamente"
  }
}
```

### Regras de Negócio

1. **Código de Ativação:**
   - Deve ser único por eSIM
   - Gerado no momento da compra
   - Não expira (ou expira em 90 dias)
   - Case-insensitive (ABC123 = abc123)

2. **LPA String:**
   - Formato: `LPA:1$servidor$codigo`
   - Fornecida pela operadora de eSIM
   - Armazenada de forma segura
   - Não pode ser reutilizada

3. **Status Possíveis:**
   - `pending_activation` - Aguardando instalação
   - `active` - eSIM instalado e ativo
   - `expired` - Período de validade expirado
   - `cancelled` - Cancelado pelo usuário

4. **Segurança:**
   - Rate limit: 10 requisições/minuto por IP
   - Log de todas as consultas
   - Não retornar LPA String se já foi ativado

---

## 📡 API 2: Confirmar Ativação do eSIM

### Endpoint
```
POST /api/v1/esim/{activation_code}/activate
```

### Descrição
Confirma que o eSIM foi instalado com sucesso no dispositivo do usuário.

### Autenticação
```
Authorization: Bearer {JWT_TOKEN}
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| activation_code | string (path) | Sim | Código único de ativação |

### Request Body
```json
{
  "device_info": {
    "model": "Samsung Galaxy S24",
    "os": "Android",
    "os_version": "14",
    "imei": "123456789012345",
    "manufacturer": "Samsung"
  },
  "activated_at": "2026-03-08T11:00:00Z",
  "location": {
    "country": "BR",
    "city": "São Paulo"
  }
}
```

### Request Example
```http
POST /api/v1/esim/ABC123XYZ456/activate HTTP/1.1
Host: api.scconecta.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "device_info": {
    "model": "Samsung Galaxy S24",
    "os": "Android",
    "os_version": "14",
    "manufacturer": "Samsung"
  },
  "activated_at": "2026-03-08T11:00:00Z"
}
```

### Response Success (200 OK)
```json
{
  "success": true,
  "data": {
    "activation_code": "ABC123XYZ456",
    "status": "active",
    "activated_at": "2026-03-08T11:00:00Z",
    "expires_at": "2026-04-10T23:59:59Z"
  },
  "message": "eSIM ativado com sucesso!"
}
```

### Response Error (400 Bad Request)
```json
{
  "success": false,
  "error": {
    "code": "ALREADY_ACTIVATED",
    "message": "eSIM já foi ativado",
    "details": "Este eSIM foi ativado em 2026-03-07 às 15:30"
  }
}
```

### Response Error (404 Not Found)
```json
{
  "success": false,
  "error": {
    "code": "ESIM_NOT_FOUND",
    "message": "eSIM não encontrado",
    "details": "O código de ativação ABC123 não existe"
  }
}
```

### Regras de Negócio

1. **Ativação:**
   - Só pode ser ativado uma vez
   - Atualiza status de `pending_activation` para `active`
   - Registra data/hora de ativação
   - Registra informações do dispositivo

2. **Notificações:**
   - Enviar email de confirmação ao usuário
   - Enviar notificação push (se app instalado)
   - Registrar no histórico do usuário

3. **Analytics:**
   - Registrar tempo entre compra e ativação
   - Registrar tipo de dispositivo
   - Registrar localização (se disponível)

4. **Segurança:**
   - Validar que o código existe
   - Validar que não foi ativado antes
   - Rate limit: 5 requisições/minuto por código

---

## 🗄️ Modelo de Dados Sugerido

### Tabela: esims
```sql
CREATE TABLE esims (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    activation_code VARCHAR(50) UNIQUE NOT NULL,
    lpa_string TEXT NOT NULL,
    iccid VARCHAR(50),
    plan_id INT NOT NULL,
    user_id INT NOT NULL,
    status ENUM('pending_activation', 'active', 'expired', 'cancelled') DEFAULT 'pending_activation',
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    activated_at DATETIME NULL,
    device_model VARCHAR(100) NULL,
    device_os VARCHAR(50) NULL,
    device_os_version VARCHAR(20) NULL,
    device_manufacturer VARCHAR(100) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_activation_code (activation_code),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);
```

### Tabela: plans
```sql
CREATE TABLE plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    countries JSON NOT NULL,
    data_allowance VARCHAR(50),
    voice_allowance VARCHAR(50),
    sms_allowance VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔐 Segurança

### Autenticação
- JWT com expiração de 24h
- Refresh token com expiração de 30 dias
- HTTPS obrigatório

### Rate Limiting
```
GET /esim/{code}:  10 req/min por IP
POST /esim/{code}/activate: 5 req/min por código
```

### Validações
- Sanitizar todos os inputs
- Validar formato do activation_code
- Validar formato da LPA String
- Prevenir SQL injection
- Prevenir XSS

### Logs
- Registrar todas as requisições
- Registrar tentativas de acesso inválido
- Alertar sobre comportamento suspeito

---

## 🧪 Testes

### Casos de Teste - API 1 (GET)

| # | Cenário | Input | Output Esperado |
|---|---------|-------|-----------------|
| 1 | Código válido | ABC123 | 200 OK com dados |
| 2 | Código inválido | INVALID | 404 Not Found |
| 3 | Código expirado | EXPIRED123 | 404 ou 410 Gone |
| 4 | Sem autenticação | ABC123 | 401 Unauthorized |
| 5 | Token expirado | ABC123 | 401 Unauthorized |

### Casos de Teste - API 2 (POST)

| # | Cenário | Input | Output Esperado |
|---|---------|-------|-----------------|
| 1 | Primeira ativação | Dados válidos | 200 OK |
| 2 | Segunda ativação | Mesmo código | 400 Already Activated |
| 3 | Código inválido | INVALID | 404 Not Found |
| 4 | Dados incompletos | Sem device_info | 400 Bad Request |
| 5 | Sem autenticação | Dados válidos | 401 Unauthorized |

---

## 📚 Documentação

### Swagger/OpenAPI
Criar documentação interativa em:
```
https://api.scconecta.com/docs
```

### Postman Collection
Exportar collection com exemplos de todas as requisições.

### Changelog
Manter histórico de mudanças na API.

---

## 🚀 Ambientes

### Development
```
URL: https://api-dev.scconecta.com/v1
Banco: MySQL Dev
```

### Staging
```
URL: https://api-staging.scconecta.com/v1
Banco: MySQL Staging (cópia de produção)
```

### Production
```
URL: https://api.scconecta.com/v1
Banco: MySQL Production
```

---

## 📊 Monitoramento

### Métricas
- Tempo de resposta (p50, p95, p99)
- Taxa de erro (4xx, 5xx)
- Requisições por minuto
- Uptime

### Alertas
- Tempo de resposta > 1s
- Taxa de erro > 5%
- Downtime > 1 minuto

### Logs
- CloudWatch / Datadog / New Relic
- Retention: 30 dias

---

## ✅ Checklist de Entrega

### Backend
- [ ] API 1 (GET) implementada
- [ ] API 2 (POST) implementada
- [ ] Testes unitários (cobertura > 80%)
- [ ] Testes de integração
- [ ] Documentação Swagger
- [ ] Postman Collection
- [ ] Deploy em staging
- [ ] Testes de carga (100 req/s)

### Infraestrutura
- [ ] HTTPS configurado
- [ ] Rate limiting ativo
- [ ] Logs configurados
- [ ] Monitoramento ativo
- [ ] Alertas configurados
- [ ] Backup automático

### Documentação
- [ ] README atualizado
- [ ] Exemplos de uso
- [ ] Códigos de erro documentados
- [ ] Changelog criado

---

## 🤝 Integração com Mobile

### O que o time mobile precisa:

1. **URLs dos ambientes**
   - Dev, Staging, Production

2. **Credenciais de teste**
   - Token JWT válido
   - Códigos de ativação de teste

3. **Documentação**
   - Swagger URL
   - Postman Collection
   - Exemplos de requisição/resposta

4. **Suporte**
   - Canal de comunicação (Slack)
   - Contato para dúvidas
   - Horário de disponibilidade

---

## 📞 Contatos

**Backend Lead:** [Nome]  
**Email:** [email]  
**Slack:** @backend-lead

**Mobile Lead:** [Seu nome]  
**Email:** [seu email]  
**Slack:** @mobile-lead

---

## 📅 Timeline

| Semana | Atividade | Responsável |
|--------|-----------|-------------|
| 1 | Implementação APIs | Backend |
| 1 | Testes unitários | Backend |
| 2 | Deploy staging | Backend + DevOps |
| 2 | Testes integração | Backend + Mobile |
| 2 | Documentação | Backend |
| 3 | Deploy produção | Backend + DevOps |

---

**Documento criado em:** Março 2026  
**Versão:** 1.0  
**Status:** Aguardando implementação
