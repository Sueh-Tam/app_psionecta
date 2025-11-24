# Psiconecta

Aplicativo Flutter para conexão entre pacientes e psicólogos, com agendamento de consultas, gerenciamento de pacotes e notificações.

## Funcionalidades

- Autenticação de usuários (login, verificação de sessão, atualização de perfil)
- Listagem de clínicas parceiras e psicólogos por clínica
- Consulta de pacotes e compra de pacotes
- Agendamento de consultas a partir de disponibilidades
- Tela de consultas agendadas com filtros por status, mês e ano
- Notificações:
  - Alerta em tela ao detectar consulta marcada para o dia seguinte
  - Notificação nativa do dispositivo (Android/iOS) com horário e psicólogo
  - Lembrete agendado 1 dia antes para consultas futuras

## Estrutura e pontos-chave

- Base da API: `lib/config/app_config.dart`
- Serviço de autenticação: `lib/services/auth_service.dart`
- Serviço de dados (clínicas, psicólogos, pacotes, consultas): `lib/services/data_service.dart`
- Notificações locais: `lib/services/notification_service.dart`
- Home e verificação pós-login de consultas: `lib/screens/home_page.dart`

## Pré-requisitos

- Flutter SDK instalado e configurado
- Dispositivo físico ou emulador (Android/iOS) ou navegador (Web)
- Backend acessível pela `baseUrl` configurada em `lib/config/app_config.dart`

## Configuração da API

- Ajuste a `baseUrl` em `lib/config/app_config.dart` conforme seu ambiente.
- Exemplo atual: `http://10.216.245.121:800/api`.

## Instalação e execução

- Instalar dependências:
  - `flutter pub get`

- Análise opcional:
  - `flutter analyze`

- Executar no dispositivo/emulador padrão:
  - `flutter run`

- Executar no Chrome (Web):
  - `flutter run -d chrome`

## Permissões de notificações

- Android 13+: confirme a permissão de notificações do app nas configurações do dispositivo.
- iOS: o app solicita permissão em tempo de execução; aceite para receber notificações.

## Observações

- Em caso de indisponibilidade da API, algumas telas usam dados estáticos como fallback.
- As notificações são inicializadas automaticamente na inicialização do app e também sob demanda antes de disparos.
