# Requirements Document

## Introduction

Este documento especifica os requisitos para a feature de automação de instalação e configuração de eSIM no aplicativo SCCONECTA. A feature visa eliminar o processo manual complexo atual, que requer QR Codes físicos e múltiplos passos manuais nas configurações do dispositivo, substituindo-o por um processo automatizado e guiado dentro do próprio aplicativo.

## Glossary

- **SCCONECTA_App**: O aplicativo móvel Flutter que gerencia serviços de conectividade eSIM
- **eSIM**: Embedded SIM, um chip SIM virtual que pode ser ativado digitalmente sem necessidade de chip físico
- **LPA_String**: Local Profile Assistant string no formato `LPA:1$endereco.servidor$codigo-ativacao` usado para ativar eSIMs
- **QR_Code**: Código QR que contém a LPA_String para ativação de eSIM
- **Activation_Code**: Código único fornecido pela operadora para ativar um perfil eSIM específico
- **Primary_Line**: Linha telefônica pessoal principal do usuário no dispositivo
- **Data_Roaming**: Configuração que permite uso de dados móveis em redes internacionais
- **Deep_Link**: URL especial que abre o aplicativo diretamente em uma tela específica
- **Profile_Manager**: Componente do sistema operacional que gerencia perfis eSIM
- **Travel_Assistant**: Módulo do aplicativo que detecta contexto de viagem e oferece ações automatizadas
- **Setup_Wizard**: Interface guiada passo a passo para configuração de eSIM

## Requirements

### Requirement 1: Instalação Automática de eSIM via LPA String

**User Story:** Como usuário, eu quero instalar o eSIM com um único clique usando o código de ativação, para que eu não precise escanear QR Codes físicos ou navegar manualmente pelas configurações do sistema.

#### Acceptance Criteria

1. WHEN the user receives an Activation_Code, THE SCCONECTA_App SHALL extract the LPA_String from the code
2. WHEN the user taps the install button, THE SCCONECTA_App SHALL invoke the native Profile_Manager API with the LPA_String
3. IF the eSIM installation succeeds, THEN THE SCCONECTA_App SHALL display a success confirmation message
4. IF the eSIM installation fails, THEN THE SCCONECTA_App SHALL display a descriptive error message with troubleshooting steps
5. THE SCCONECTA_App SHALL validate the LPA_String format before attempting installation
6. WHEN installation is in progress, THE SCCONECTA_App SHALL display a progress indicator to the user

### Requirement 2: Deep Link para Ativação Direta

**User Story:** Como usuário, eu quero clicar em um link recebido por email ou WhatsApp e ser levado diretamente para a tela de ativação no app, para que eu não precise copiar e colar códigos manualmente.

#### Acceptance Criteria

1. WHEN the user clicks a Deep_Link containing an Activation_Code, THE SCCONECTA_App SHALL open and navigate to the activation screen
2. WHEN the activation screen opens via Deep_Link, THE SCCONECTA_App SHALL pre-populate the Activation_Code field
3. THE SCCONECTA_App SHALL support Deep_Link format `scconecta://esim/activate?code={Activation_Code}`
4. IF the SCCONECTA_App is not installed, THEN THE Deep_Link SHALL redirect to the app store
5. WHEN a Deep_Link is processed, THE SCCONECTA_App SHALL validate the Activation_Code before displaying the activation screen

### Requirement 3: Wizard Guiado de Configuração

**User Story:** Como usuário, eu quero ser guiado passo a passo através do processo de configuração do eSIM, para que eu saiba exatamente o que fazer em cada etapa e possa acompanhar meu progresso.

#### Acceptance Criteria

1. WHEN the user starts the eSIM setup, THE Setup_Wizard SHALL display a visual checklist of all required steps
2. FOR each step in the Setup_Wizard, THE SCCONECTA_App SHALL provide a clear description and action button
3. WHEN the user completes a step, THE Setup_Wizard SHALL mark it as complete and advance to the next step
4. WHERE a step requires system settings access, THE Setup_Wizard SHALL provide a button that opens the specific system settings screen
5. THE Setup_Wizard SHALL persist progress so users can resume if they exit the app
6. WHEN all steps are completed, THE Setup_Wizard SHALL display a completion summary

### Requirement 4: Assistente Inteligente de Viagem

**User Story:** Como usuário viajante, eu quero receber lembretes automáticos para ativar/desativar linhas nos momentos apropriados, para que eu não esqueça de fazer as configurações necessárias durante minha viagem.

#### Acceptance Criteria

1. WHEN the user's location indicates they are at an airport, THE Travel_Assistant SHALL send a notification suggesting to disable the Primary_Line
2. WHEN the user arrives at their destination country, THE Travel_Assistant SHALL send a notification to enable Data_Roaming on the eSIM
3. THE Travel_Assistant SHALL provide quick action buttons in notifications that open the relevant system settings
4. THE SCCONECTA_App SHALL request location permission before enabling the Travel_Assistant
5. WHERE the user has not granted location permission, THE Travel_Assistant SHALL offer manual triggers for travel mode
6. THE Travel_Assistant SHALL allow users to enable or disable automatic travel detection in app settings

### Requirement 5: Monitoramento de Status do eSIM

**User Story:** Como usuário, eu quero ver o status atual do meu eSIM e das configurações relacionadas, para que eu possa verificar se tudo está configurado corretamente.

#### Acceptance Criteria

1. THE SCCONECTA_App SHALL display the current status of all installed eSIM profiles
2. THE SCCONECTA_App SHALL indicate whether Data_Roaming is enabled or disabled for each line
3. THE SCCONECTA_App SHALL show which line is currently active for data
4. WHEN an eSIM profile status changes, THE SCCONECTA_App SHALL update the display within 5 seconds
5. THE SCCONECTA_App SHALL provide a refresh button to manually check current eSIM status
6. IF the device does not support eSIM, THEN THE SCCONECTA_App SHALL display a clear message explaining device limitations

### Requirement 6: Instruções Contextuais por Plataforma

**User Story:** Como usuário, eu quero ver instruções específicas para meu dispositivo (iPhone ou Android), para que eu não fique confuso com instruções que não se aplicam ao meu aparelho.

#### Acceptance Criteria

1. THE SCCONECTA_App SHALL detect the device platform (iOS or Android) automatically
2. WHEN displaying instructions, THE SCCONECTA_App SHALL show only platform-specific steps
3. WHERE manual steps are required, THE SCCONECTA_App SHALL provide screenshots or illustrations specific to the detected platform and OS version
4. THE SCCONECTA_App SHALL adapt terminology to match the platform (e.g., "Ajustes" for iOS, "Configurações" for Android)
5. IF the OS version is not supported, THEN THE SCCONECTA_App SHALL display a warning message with minimum version requirements

### Requirement 7: Gestão de Múltiplos Perfis eSIM

**User Story:** Como usuário frequente, eu quero gerenciar múltiplos perfis eSIM de diferentes viagens, para que eu possa reutilizar perfis anteriores ou remover perfis expirados.

#### Acceptance Criteria

1. THE SCCONECTA_App SHALL display a list of all eSIM profiles associated with the user account
2. FOR each eSIM profile, THE SCCONECTA_App SHALL show the status (active, inactive, expired)
3. WHEN a profile is expired, THE SCCONECTA_App SHALL provide an option to remove it from the device
4. THE SCCONECTA_App SHALL allow users to rename eSIM profiles for easier identification
5. WHEN multiple profiles are installed, THE SCCONECTA_App SHALL indicate which profile is currently in use
6. THE SCCONECTA_App SHALL provide a search or filter function for users with more than 5 profiles

### Requirement 8: Validação e Diagnóstico de Compatibilidade

**User Story:** Como usuário, eu quero saber se meu dispositivo é compatível com eSIM antes de tentar ativar, para que eu não perca tempo em um processo que não funcionará.

#### Acceptance Criteria

1. WHEN the user first opens the eSIM activation feature, THE SCCONECTA_App SHALL check device eSIM compatibility
2. IF the device does not support eSIM, THEN THE SCCONECTA_App SHALL display a clear message explaining the limitation
3. THE SCCONECTA_App SHALL verify that the device is not carrier-locked before attempting activation
4. IF the device is carrier-locked, THEN THE SCCONECTA_App SHALL provide instructions on how to unlock it
5. THE SCCONECTA_App SHALL check for sufficient storage space required for eSIM profile installation
6. WHEN running diagnostics, THE SCCONECTA_App SHALL display results in a user-friendly format with actionable recommendations

### Requirement 9: Notificações de Ativação e Expiração

**User Story:** Como usuário, eu quero ser notificado quando meu eSIM for ativado com sucesso e quando estiver próximo de expirar, para que eu possa gerenciar minha conectividade proativamente.

#### Acceptance Criteria

1. WHEN an eSIM profile is successfully activated, THE SCCONECTA_App SHALL send a push notification confirming activation
2. WHEN an eSIM profile has 3 days remaining before expiration, THE SCCONECTA_App SHALL send a reminder notification
3. WHEN an eSIM profile has 1 day remaining before expiration, THE SCCONECTA_App SHALL send a final reminder notification
4. THE SCCONECTA_App SHALL include a quick action in expiration notifications to renew or purchase a new plan
5. WHERE the user has disabled notifications, THE SCCONECTA_App SHALL display expiration warnings in the app interface
6. THE SCCONECTA_App SHALL allow users to configure notification preferences for eSIM events

### Requirement 10: Tratamento de Erros e Recuperação

**User Story:** Como usuário, eu quero receber mensagens de erro claras e opções de recuperação quando algo der errado, para que eu possa resolver problemas sem precisar contatar o suporte.

#### Acceptance Criteria

1. IF eSIM installation fails due to network issues, THEN THE SCCONECTA_App SHALL offer a retry option
2. IF eSIM installation fails due to invalid Activation_Code, THEN THE SCCONECTA_App SHALL prompt the user to verify the code
3. WHEN an error occurs, THE SCCONECTA_App SHALL log detailed error information for support purposes
4. THE SCCONECTA_App SHALL provide a "Contact Support" button that includes diagnostic information in the support request
5. IF installation is interrupted, THEN THE SCCONECTA_App SHALL allow the user to resume from the last successful step
6. THE SCCONECTA_App SHALL display error messages in the user's preferred language

### Requirement 11: Integração com Sistema de Suporte

**User Story:** Como usuário, eu quero poder solicitar ajuda facilmente se encontrar problemas, para que eu receba suporte rápido sem sair do contexto do app.

#### Acceptance Criteria

1. THE SCCONECTA_App SHALL provide a help button accessible from all eSIM-related screens
2. WHEN the user requests help, THE SCCONECTA_App SHALL include current device state and eSIM status in the support request
3. THE SCCONECTA_App SHALL offer a FAQ section with common eSIM activation issues and solutions
4. WHERE available, THE SCCONECTA_App SHALL provide a chat option to contact support directly
5. THE SCCONECTA_App SHALL allow users to share diagnostic logs with support via secure channel
6. WHEN a support request is submitted, THE SCCONECTA_App SHALL provide a ticket number for tracking

### Requirement 12: Configuração Automática de Roaming

**User Story:** Como usuário, eu quero que o app configure automaticamente o roaming de dados quando necessário, para que eu não precise fazer isso manualmente nas configurações do sistema.

#### Acceptance Criteria

1. WHEN an eSIM is activated for international use, THE SCCONECTA_App SHALL prompt the user to enable Data_Roaming
2. WHERE the platform API allows, THE SCCONECTA_App SHALL enable Data_Roaming automatically with user consent
3. IF automatic configuration is not possible, THEN THE SCCONECTA_App SHALL provide a button that opens the Data_Roaming settings screen
4. THE SCCONECTA_App SHALL verify that Data_Roaming is enabled after the user returns from system settings
5. WHEN Data_Roaming is successfully enabled, THE SCCONECTA_App SHALL mark this step as complete in the Setup_Wizard
6. THE SCCONECTA_App SHALL warn users about potential roaming charges before enabling Data_Roaming
