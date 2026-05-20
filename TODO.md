# TODO — DailyAdventure

Lista de funcionalidades e melhorias planejadas para o app.

## Ordem de prioridade sugerida

### 1. Revisões e polish (menor esforço, alto impacto visual)

- [x] **Revisar seção de Histórico** — verificar se o Adventure Log ainda faz sentido com o modelo atual (layout, informações exibidas, expandable rows)
- [ ] **Revisar imagem da página principal** — garantir que o logo/imagem funcione corretamente nas versões clara e escura
- [ ] **Opção de dia "mais ou menos"** — adicionar `DayFeedback.neutral` além de `.positive` e `.negative`

### 2. Features com base pronta

- [ ] **Feedback inteligente** — analisar o histórico e mostrar em qual categoria o usuário foca mais, onde está negligenciando e sugestões de melhoria (`categoryStats` já calculado no ViewModel, falta a UI)
- [ ] **Local Notifications** — base já existe em `NotificationService` (morning → Today, evening → Progress). Revisar comportamento, horários padrão e UX de configuração

### 3. Features novas de média complexidade

- [ ] **WeatherKit** — mostrar o tempo na localidade do usuário na tela Today (onde aparece a data)
- [ ] **Testes e dados de mock** — ampliar cobertura com Swift Testing (unit) e XCUITest (UI), especialmente para edge cases de rollover e streak. Também cobrir `DayFeedback.neutral` quando implementado. Criar um mecanismo de seed de dados (ex: launch argument `--mock-data`) que popula o app com histórico fictício de vários dias, permitindo testar analytics, streak e Adventure Log como se o app já estivesse em uso há algum tempo

### 4. Features complexas / dependências externas

- [ ] **WidgetKit** — avaliar opções de widgets: (1) preencher uma nova aventura; (2) progresso do dia; (3) outras a definir durante a implementação
- [ ] **Localização e acessibilidade** — localizar o app conforme a localidade do usuário; suporte a Dynamic Type, fonte para dislexia e outras opções de acessibilidade

### 5. Alto risco — discutir antes de implementar

- [ ] **Melhorar armazenamento** — avaliar migração de `UserDefaults` + `StorageService` para SwiftData (risco de perda de dados, exige estratégia de migração)
- [ ] **Ícone do app** — criar um ícone melhor (trabalho de design)

---

## Em andamento / Parcialmente feito

- [ ] **Melhorar consistência de sequência de dias** — streak já calculado no `QuestViewModel` (`currentStreak`, `excellenceInStreak`), mas a sequência ainda pode quebrar em edge cases. Elaborar testes para cobrir os cenários problemáticos

---

## Concluído

- [x] **Revisar seção de Histórico** — condição de exibição de hoje corrigida (`shouldArchiveToAdventureLog`), ano adicionado ao formato de datas de anos anteriores, label redundante "Today - Current" simplificada para "Today"
- [x] **Progress tab — redesign de streak cards e layout** — card grande (🔥) para streak atual + dois cards menores (⭐ perfect days, ⚔️ total days); seção Today movida para cima dando mais destaque ao gráfico; dia parcial no grid de 7 dias usa cor da categoria com mais quests completadas
- [x] **Progress tab com analytics histórico** — redesign completo: streak cards (🔥 / ⭐ / ⚔️), grid de 7 dias com `DayCompletionLevel`, seção Today compacta com donut
- [x] **DayCompletionLevel** — `.empty` / `.partial` / `.complete` no modelo; Adventure Log usa ⭐ dourado para dias 100%
- [x] **Main quest UX** — card persiste entre abas, TextField usa rascunho local, xmark sempre visível mesmo após completar
