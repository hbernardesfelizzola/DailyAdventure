# TODO — DailyAdventure

Lista de funcionalidades e melhorias planejadas para o app.

## Em andamento / Parcialmente feito

- [ ] **Melhorar consistência de sequência de dias** — streak já calculado no `QuestViewModel` (`currentStreak`, `excellenceInStreak`), mas a sequência ainda pode quebrar em edge cases. Elaborar testes para cobrir os cenários problemáticos.

## Pendente

- [ ] **Local Notifications** — base já existe em `NotificationService` (morning → Today, evening → Progress). Revisar comportamento, horários padrão e UX de configuração.
- [ ] **WeatherKit** — mostrar o tempo na localidade do usuário na tela Today (onde aparece a data).
- [ ] **WidgetKit** — dois widgets: (1) preencher uma nova aventura; (2) progresso do dia.
- [ ] **Melhorar armazenamento** — avaliar migração de `UserDefaults` + `StorageService` para SwiftData. Discutir antes de implementar (risco de perda de dados).
- [ ] **Localização e acessibilidade** — localizar o app conforme a localidade do usuário; suporte a Dynamic Type, fonte para dislexia e outras opções de acessibilidade.
- [ ] **Testes** — ampliar cobertura com Swift Testing (unit) e XCUITest (UI), especialmente para edge cases de rollover e streak.
- [ ] **Ícone do app** — criar um ícone melhor.
- [ ] **Feedback inteligente** — analisar o histórico do usuário e mostrar em qual categoria ele foca mais, onde está negligenciando e sugestões de melhoria. (`categoryStats` já calculado no ViewModel, falta a UI.)
- [ ] **Opção de dia "mais ou menos"** — adicionar `DayFeedback.neutral` além de `.positive` e `.negative`.

## Concluído

- [x] **Progress tab com analytics histórico** — redesign completo: streak cards (🔥 / ⭐ / ⚔️), grid de 7 dias com `DayCompletionLevel`, seção Today compacta com donut.
- [x] **DayCompletionLevel** — `.empty` / `.partial` / `.complete` no modelo; Adventure Log usa ⭐ dourado para dias 100%.
- [x] **Main quest UX** — card persiste entre abas, TextField usa rascunho local, xmark sempre visível mesmo após completar.
