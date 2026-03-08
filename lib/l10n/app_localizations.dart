import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'pt': {
      // Geral
      'app_name': 'SC Conecta',
      'loading': 'Carregando...',
      'error': 'Erro',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'save': 'Salvar',
      'continue': 'Continuar',
      'close': 'Fechar',
      'hello': 'Olá,',
      'visitor': 'Visitante',
      'user': 'Usuário',
      
      // Menu
      'menu_my_orders': 'Meus Pedidos',
      'menu_connectivity': 'Conectividade',
      'menu_language': 'Idioma',
      'menu_logout': 'Sair',
      'select_language': 'Selecionar Idioma',
      
      // Landing Screen
      'landing_title_1': 'Seu chip internacional\nativado no Brasil',
      'landing_title_2': ', com ',
      'landing_title_3': 'internet e voz ilimitada',
      'landing_date_placeholder': 'Data inicial — Data final',
      'landing_activate_button': 'Ativar meu chip agora',
      'landing_our_plans': 'Nossos Planos',
      'landing_plan_america': 'Plano América',
      'landing_plan_world': 'Plano Mundo',
      'landing_plan_brazil': 'Plano Brasil',
      'landing_from': 'A partir de',
      'landing_min_days_error': 'Selecione um período de no mínimo 4 dias.',
      
      // Plan Selection
      'plan_breadcrumb': 'Escolha o seu plano',
      'plan_title': 'eSIMs e Chips com dados e voz ilimitados',
      'plan_advantages': 'Vantagens',
      'plan_specifications': 'Especificações',
      'plan_choose': 'Escolha o Plano para sua viagem',
      'plan_america': 'Plano América',
      'plan_world': 'Plano Mundo',
      'plan_brazil': 'Plano Brasil',
      'plan_esim': 'eSIM',
      'plan_chip': 'Chip',
      'plan_coverage_america': 'Cobertura em mais de 30 países das Américas',
      'plan_coverage_world': 'Cobertura em mais de 120 países',
      'plan_coverage_brazil': 'Cobertura em todo Brasil',
      'plan_unlimited_internet': 'Internet ilimitada',
      'plan_unlimited_voice': 'Ligações de voz ilimitada',
      'plan_unlimited_voice_brazil': 'Ligações de voz ilimitada dentro do Brasil',
      'plan_high_speed': 'Internet de alta velocidade',
      'plan_board_connected': 'Embarque para seu destino já conectado',
      'plan_arrive_connected': 'Chegue no Brasil conectado',
      'plan_support_24h': 'Suporte 24 horas',
      'plan_support_whatsapp': 'via WhatsApp',
      'plan_activate_now': 'Ativar meu chip',
      'plan_add_cart': 'Adicionar ao Carrinho',
      'plan_total_selection': 'Total desta seleção',
      'plan_delivery_time': 'Prazo de entrega do Chip',
      'plan_enter_cep': 'Informe o CEP',
      'plan_pickup_agency': 'Retirar em uma agência',
      'plan_device_compatible': 'Confirmo que o aparelho de destino é compatível com eSIM',
      'plan_esim_warning': 'Celular não possui eSim',
      'plan_chip_shipping': 'Envio via correios',
      'plan_cart': 'Carrinho',
      'plan_order_summary': 'Resumo do pedido',
      'plan_finish_purchase': 'Finalizar compra',
      'plan_esim_tech': 'Tecnologia eSIM',
      'plan_esim_not_detected': 'O sistema não detectou suporte a eSIM neste aparelho. Se estiver comprando para outra pessoa, verifique se o aparelho dela é compatível.',
      'plan_esim_compatible': 'Este aparelho é compatível com eSIM.',
      'plan_items': 'itens',
      
      // Vantagens
      'advantage_unlimited_internet': 'Internet Ilimitada',
      'advantage_board_connected': 'Embarque já conectado',
      'advantage_unlimited_voice': 'Voz ilimitada*',
      'advantage_whatsapp_support': 'Suporte WhatsApp',
      'advantage_high_speed': 'Alta velocidade',
      'advantage_countries': '+120 países*',
      
      // Especificações
      'spec_description': 'Voz e dados ilimitados. Cobertura 4G/5G.',
      
      // Diagnostic Screen
      'diagnostic_title': 'CONECTIVIDADE',
      'diagnostic_location_brazil': 'Você está no Brasil',
      'diagnostic_location_in': 'Você está em:',
      'diagnostic_action_required': 'AÇÃO RECOMENDADA',
      'diagnostic_all_set': 'TUDO PRONTO',
      'diagnostic_plan_trip': 'PLANEJE SUA VIAGEM',
      'diagnostic_configuration': 'CONFIGURAÇÃO',
      'diagnostic_no_connection': 'SEM CONEXÃO',
      'diagnostic_msg_critical': 'Atenção! Desative sua linha pessoal para evitar cobranças de roaming.',
      'diagnostic_msg_ideal': 'Configuração ideal! Sua linha pessoal está desativada. Boa viagem!',
      'diagnostic_msg_warning': 'Lembre-se de desativar sua linha pessoal ao chegar no destino.',
      'diagnostic_msg_roaming': 'Você está em roaming internacional! Adquira um chip SCCONECTA para evitar cobranças altas.',
      'diagnostic_msg_no_connection': 'Sem conexão de rede celular. Conecte-se ao WiFi para configurar seu chip internacional.',
      'diagnostic_msg_default': 'Viaje tranquilo! Adquira seu chip SCCONECTA antes de embarcar.',
      'diagnostic_connect_wifi': 'CONECTAR AO WIFI',
      'diagnostic_manage_line': 'GERENCIAR ESTA LINHA',
      'diagnostic_active': 'ATIVO',
      'diagnostic_inactive': 'DESATIVADO',
      'diagnostic_download_speed': 'VELOCIDADE DE DOWNLOAD',
      'diagnostic_test_signal': 'TESTAR SINAL',
      'diagnostic_testing': 'TESTANDO...',
      
      // Countries
      'country_brazil': 'Brasil',
      'country_usa': 'Estados Unidos',
      'country_france': 'França',
      'country_uk': 'Reino Unido',
      'country_spain': 'Espanha',
      'country_italy': 'Itália',
      'country_germany': 'Alemanha',
      'country_australia': 'Austrália',
      'country_abroad': 'Exterior',
    },
    
    'en': {
      // General
      'app_name': 'SC Connect',
      'loading': 'Loading...',
      'error': 'Error',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'continue': 'Continue',
      'close': 'Close',
      'hello': 'Hello,',
      'visitor': 'Visitor',
      'user': 'User',
      
      // Menu
      'menu_my_orders': 'My Orders',
      'menu_connectivity': 'Connectivity',
      'menu_language': 'Language',
      'menu_logout': 'Logout',
      'select_language': 'Select Language',
      
      // Landing Screen
      'landing_title_1': 'Your international chip\nactivated in Brazil',
      'landing_title_2': ', with ',
      'landing_title_3': 'unlimited internet and voice',
      'landing_date_placeholder': 'Start date — End date',
      'landing_activate_button': 'Activate my chip now',
      'landing_our_plans': 'Our Plans',
      'landing_plan_america': 'America Plan',
      'landing_plan_world': 'World Plan',
      'landing_plan_brazil': 'Brazil Plan',
      'landing_from': 'From',
      'landing_min_days_error': 'Select a period of at least 4 days.',
      
      // Plan Selection
      'plan_breadcrumb': 'Choose your plan',
      'plan_title': 'eSIMs and Chips with unlimited data and voice',
      'plan_advantages': 'Advantages',
      'plan_specifications': 'Specifications',
      'plan_choose': 'Choose the Plan for your trip',
      'plan_america': 'America Plan',
      'plan_world': 'World Plan',
      'plan_brazil': 'Brazil Plan',
      'plan_esim': 'eSIM',
      'plan_chip': 'Chip',
      'plan_coverage_america': 'Coverage in over 30 countries in the Americas',
      'plan_coverage_world': 'Coverage in over 120 countries',
      'plan_coverage_brazil': 'Coverage throughout Brazil',
      'plan_unlimited_internet': 'Unlimited internet',
      'plan_unlimited_voice': 'Unlimited voice calls',
      'plan_unlimited_voice_brazil': 'Unlimited voice calls within Brazil',
      'plan_high_speed': 'High-speed internet',
      'plan_board_connected': 'Board to your destination already connected',
      'plan_arrive_connected': 'Arrive in Brazil connected',
      'plan_support_24h': '24-hour support',
      'plan_support_whatsapp': 'via WhatsApp',
      'plan_activate_now': 'Activate my chip',
      'plan_add_cart': 'Add to Cart',
      'plan_total_selection': 'Total for this selection',
      'plan_delivery_time': 'Chip delivery time',
      'plan_enter_cep': 'Enter ZIP code',
      'plan_pickup_agency': 'Pick up at an agency',
      'plan_device_compatible': 'I confirm that the destination device is eSIM compatible',
      'plan_esim_warning': 'Phone does not have eSIM',
      'plan_chip_shipping': 'Shipping via mail',
      'plan_cart': 'Cart',
      'plan_order_summary': 'Order summary',
      'plan_finish_purchase': 'Complete purchase',
      'plan_esim_tech': 'eSIM Technology',
      'plan_esim_not_detected': 'The system did not detect eSIM support on this device. If you are buying for someone else, verify that their device is compatible.',
      'plan_esim_compatible': 'This device is eSIM compatible.',
      'plan_items': 'items',
      
      // Advantages
      'advantage_unlimited_internet': 'Unlimited Internet',
      'advantage_board_connected': 'Board already connected',
      'advantage_unlimited_voice': 'Unlimited voice*',
      'advantage_whatsapp_support': 'WhatsApp Support',
      'advantage_high_speed': 'High speed',
      'advantage_countries': '+120 countries*',
      
      // Specifications
      'spec_description': 'Unlimited voice and data. 4G/5G coverage.',
      
      // Diagnostic Screen
      'diagnostic_title': 'CONNECTIVITY',
      'diagnostic_location_brazil': 'You are in Brazil',
      'diagnostic_location_in': 'You are in:',
      'diagnostic_action_required': 'ACTION REQUIRED',
      'diagnostic_all_set': 'ALL SET',
      'diagnostic_plan_trip': 'PLAN YOUR TRIP',
      'diagnostic_configuration': 'CONFIGURATION',
      'diagnostic_no_connection': 'NO CONNECTION',
      'diagnostic_msg_critical': 'Attention! Disable your personal line to avoid roaming charges.',
      'diagnostic_msg_ideal': 'Ideal setup! Your personal line is disabled. Have a great trip!',
      'diagnostic_msg_warning': 'Remember to disable your personal line when you arrive at your destination.',
      'diagnostic_msg_roaming': 'You are on international roaming! Get a SCCONECTA chip to avoid high charges.',
      'diagnostic_msg_no_connection': 'No cellular network connection. Connect to WiFi to set up your international chip.',
      'diagnostic_msg_default': 'Travel worry-free! Get your SCCONECTA chip before boarding.',
      'diagnostic_connect_wifi': 'CONNECT TO WIFI',
      'diagnostic_manage_line': 'MANAGE THIS LINE',
      'diagnostic_active': 'ACTIVE',
      'diagnostic_inactive': 'INACTIVE',
      'diagnostic_download_speed': 'DOWNLOAD SPEED',
      'diagnostic_test_signal': 'TEST SIGNAL',
      'diagnostic_testing': 'TESTING...',
      
      // Countries
      'country_brazil': 'Brazil',
      'country_usa': 'United States',
      'country_france': 'France',
      'country_uk': 'United Kingdom',
      'country_spain': 'Spain',
      'country_italy': 'Italy',
      'country_germany': 'Germany',
      'country_australia': 'Australia',
      'country_abroad': 'Abroad',
    },
    
    'es': {
      // General
      'app_name': 'SC Conecta',
      'loading': 'Cargando...',
      'error': 'Error',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'continue': 'Continuar',
      'close': 'Cerrar',
      'hello': 'Hola,',
      'visitor': 'Visitante',
      'user': 'Usuario',
      
      // Menu
      'menu_my_orders': 'Mis Pedidos',
      'menu_connectivity': 'Conectividad',
      'menu_language': 'Idioma',
      'menu_logout': 'Salir',
      'select_language': 'Seleccionar Idioma',
      
      // Landing Screen
      'landing_title_1': 'Tu chip internacional\nactivado en Brasil',
      'landing_title_2': ', con ',
      'landing_title_3': 'internet y voz ilimitada',
      'landing_date_placeholder': 'Fecha inicial — Fecha final',
      'landing_activate_button': 'Activar mi chip ahora',
      'landing_our_plans': 'Nuestros Planes',
      'landing_plan_america': 'Plan América',
      'landing_plan_world': 'Plan Mundo',
      'landing_plan_brazil': 'Plan Brasil',
      'landing_from': 'Desde',
      'landing_min_days_error': 'Seleccione un período de al menos 4 días.',
      
      // Plan Selection
      'plan_breadcrumb': 'Elige tu plan',
      'plan_title': 'eSIMs y Chips con datos y voz ilimitados',
      'plan_advantages': 'Ventajas',
      'plan_specifications': 'Especificaciones',
      'plan_choose': 'Elige el Plan para tu viaje',
      'plan_america': 'Plan América',
      'plan_world': 'Plan Mundo',
      'plan_brazil': 'Plan Brasil',
      'plan_esim': 'eSIM',
      'plan_chip': 'Chip',
      'plan_coverage_america': 'Cobertura en más de 30 países de las Américas',
      'plan_coverage_world': 'Cobertura en más de 120 países',
      'plan_coverage_brazil': 'Cobertura en todo Brasil',
      'plan_unlimited_internet': 'Internet ilimitado',
      'plan_unlimited_voice': 'Llamadas de voz ilimitadas',
      'plan_unlimited_voice_brazil': 'Llamadas de voz ilimitadas dentro de Brasil',
      'plan_high_speed': 'Internet de alta velocidad',
      'plan_board_connected': 'Embarca a tu destino ya conectado',
      'plan_arrive_connected': 'Llega a Brasil conectado',
      'plan_support_24h': 'Soporte 24 horas',
      'plan_support_whatsapp': 'vía WhatsApp',
      'plan_activate_now': 'Activar mi chip',
      'plan_add_cart': 'Agregar al Carrito',
      'plan_total_selection': 'Total de esta selección',
      'plan_delivery_time': 'Tiempo de entrega del Chip',
      'plan_enter_cep': 'Ingresa el código postal',
      'plan_pickup_agency': 'Recoger en una agencia',
      'plan_device_compatible': 'Confirmo que el dispositivo de destino es compatible con eSIM',
      'plan_esim_warning': 'El teléfono no tiene eSIM',
      'plan_chip_shipping': 'Envío por correo',
      'plan_cart': 'Carrito',
      'plan_order_summary': 'Resumen del pedido',
      'plan_finish_purchase': 'Finalizar compra',
      'plan_esim_tech': 'Tecnología eSIM',
      'plan_esim_not_detected': 'El sistema no detectó soporte eSIM en este dispositivo. Si estás comprando para otra persona, verifica que su dispositivo sea compatible.',
      'plan_esim_compatible': 'Este dispositivo es compatible con eSIM.',
      'plan_items': 'artículos',
      
      // Advantages
      'advantage_unlimited_internet': 'Internet Ilimitado',
      'advantage_board_connected': 'Embarca ya conectado',
      'advantage_unlimited_voice': 'Voz ilimitada*',
      'advantage_whatsapp_support': 'Soporte WhatsApp',
      'advantage_high_speed': 'Alta velocidad',
      'advantage_countries': '+120 países*',
      
      // Specifications
      'spec_description': 'Voz y datos ilimitados. Cobertura 4G/5G.',
      
      // Diagnostic Screen
      'diagnostic_title': 'CONECTIVIDAD',
      'diagnostic_location_brazil': 'Estás en Brasil',
      'diagnostic_location_in': 'Estás en:',
      'diagnostic_action_required': 'ACCIÓN RECOMENDADA',
      'diagnostic_all_set': 'TODO LISTO',
      'diagnostic_plan_trip': 'PLANIFICA TU VIAJE',
      'diagnostic_configuration': 'CONFIGURACIÓN',
      'diagnostic_no_connection': 'SIN CONEXIÓN',
      'diagnostic_msg_critical': '¡Atención! Desactiva tu línea personal para evitar cargos de roaming.',
      'diagnostic_msg_ideal': '¡Configuración ideal! Tu línea personal está desactivada. ¡Buen viaje!',
      'diagnostic_msg_warning': 'Recuerda desactivar tu línea personal al llegar a tu destino.',
      'diagnostic_msg_roaming': '¡Estás en roaming internacional! Adquiere un chip SCCONECTA para evitar cargos altos.',
      'diagnostic_msg_no_connection': 'Sin conexión de red celular. Conéctate al WiFi para configurar tu chip internacional.',
      'diagnostic_msg_default': '¡Viaja tranquilo! Adquiere tu chip SCCONECTA antes de embarcar.',
      'diagnostic_connect_wifi': 'CONECTAR AL WIFI',
      'diagnostic_manage_line': 'GESTIONAR ESTA LÍNEA',
      'diagnostic_active': 'ACTIVO',
      'diagnostic_inactive': 'DESACTIVADO',
      'diagnostic_download_speed': 'VELOCIDAD DE DESCARGA',
      'diagnostic_test_signal': 'PROBAR SEÑAL',
      'diagnostic_testing': 'PROBANDO...',
      
      // Countries
      'country_brazil': 'Brasil',
      'country_usa': 'Estados Unidos',
      'country_france': 'Francia',
      'country_uk': 'Reino Unido',
      'country_spain': 'España',
      'country_italy': 'Italia',
      'country_germany': 'Alemania',
      'country_australia': 'Australia',
      'country_abroad': 'Extranjero',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
