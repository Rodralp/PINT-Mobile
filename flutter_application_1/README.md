# flutter_application_1

App Flutter + Dart com consumo de API REST e suporte offline-first.

## Requisitos cobertos

- Flutter + Dart para Android/iOS.
- Consumo de API REST com `http`.
- Persistencia local com `sqflite`.
- Sincronizacao quando a internet estiver disponivel.

## Offline-first (estado atual)

- Lembretes sao armazenados em SQLite e sincronizados com a API.
- Alteracoes offline ficam marcadas como pendentes e sao enviadas quando houver rede.
- O cache local e usado como fonte principal de leitura.

## Testes

```bash
flutter test
```

## Notas

- A base de dados local e criada automaticamente em `pint_offline.db`.
- A configuracao de API esta em `lib/services/backend_config.dart`.
