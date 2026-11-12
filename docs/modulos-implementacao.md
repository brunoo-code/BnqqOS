# BnqqOS em 12 módulos

A opção 0 aplica o preset pós-formatação. A opção 8 restaura por área.
A opção 9 concentra diagnósticos, experimentos e controles opcionais.
A imagem parte da mídia oficial e preserva o modo de cores do Windows.

| Módulo | Entrega | Estado e critério |
| --- | --- | --- |
| 1. Origem da ISO | Verificar SHA-256 da fonte, edição e índice. | Implementado no gerador. Rejeitar mídia divergente. |
| 2. Apps na ISO | Remover somente pacotes provisionados da lista. | Cinco novos alvos aprovados no perfil. O verificador exige a ausência dos cinco no inventário final. |
| 3. Primeiro uso | Painel, runtimes, launchers opcionais e pasta de relatórios. | Implementado. Verificar abertura, atualizações e primeiro login em instalação limpa. |
| 4. Apps na conta e IA | Limpeza da conta e detecção de Copilot e Recall. | Sete remoções reais na VM. Manter o registro por pacote e informar quando Recall pedir reinício. |
| 5. Energia | BNQQ Competitive derivado do plano original. | Ativação e restauração confirmadas na VM. Medir energia, temperatura e tempo de quadro no PC físico. |
| 6. Navegadores e inicialização | Reduzir pré-carregamento, inventariar entradas e oferecer OneDrive reversível. | Apps Lite aplicado na VM. Validar OneDrive no próximo login e confirmar recuperação. |
| 7. Captura, tela e entrada | Diagnóstico de captura e taxa de atualização. Ajuste reversível do ponteiro. | Ponteiro aplicado na VM. Testar gravação em segundo plano com a mesma cena e preservar escolha de clipes. |
| 8. Serviços e indexação | Desativar serviços selecionados e permitir restauração. | SysMain e telefonia aplicados na VM. Comparar SysMain em HD e SSD antes de ampliar a lista. |
| 9. Disco e memória | Manutenção nativa, diagnóstico de pressão de RAM e Compact OS experimental. | Compact OS só para ensaio em SSD. Comparar espaço, boot e abertura de jogo antes de adotar. |
| 10. Rede | Diagnóstico e experimento com downloads automáticos em segundo plano. | Próximo experimento. Medir jitter e perda com tráfego concorrente e verificar Windows Update. |
| 11. Recuperação e registros | Menu compacto, backups por área e relatórios por etapa. | Implementado. Testes do menu e seleção de backups passaram. |
| 12. Qualificação | Verificação da ISO e comparações independentes em VM e PC físico. | Verificador de lançamento automatizado. Ganho de desempenho depende de medições repetidas, com 1% low e p99. |

Antes de tornar um ajuste automático, documente seu alvo, escopo, motivo,
condição de aplicação e recuperação. Para testar desempenho, altere uma
variável por vez e publique o resultado mesmo quando a diferença ficar
dentro da variação normal entre rodadas.
