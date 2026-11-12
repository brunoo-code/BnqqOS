# Decisões de otimização do BnqqOS

| Área | ISO inicial | Experimento |
| --- | --- | --- |
| Apps | Remover Clipchamp, Notícias, Clima e Solitaire pela lista de pacotes. | Verificar a lista após instalar, o espaço ocupado, a Microsoft Store e o Windows Update. |
| IA | Inventariar Copilot na conta atual e tratar Recall como recurso separado. | Verificar o que a edição Pro e o hardware suportam antes de remover pacotes ou recursos. |
| CPU | Manter temporizadores e plano de energia do Windows. | Comparar Equilibrado e Alto desempenho na tomada, com temperatura e tempo de quadro. |
| RAM | Preservar paginação e compressão de memória. | Medir RAM disponível e memória comprometida sob carga. |
| SSD e HDD | Preservar a manutenção automática. | Distinguir TRIM em SSD e otimização de HDD. Fazer manutenção fora da partida. |
| Serviços | Inventariar SysMain, Windows Search e DiagTrack. | Avaliar um serviço por vez em SSD e HDD, com teste de abertura do jogo e CPU em repouso. |
| Captura | Manter o ajuste fora da ISO inicial. | Comparar gravação em segundo plano ligada e desligada no mesmo cenário. |
| Segurança | Preservar Windows Update, Defender, TPM, Secure Boot e recuperação. | Validar atualizações e abertura dos jogos em hardware compatível. |

O comando BCDEdit oferece opções de temporizador para depuração. Esses parâmetros ficam fora do perfil. A manutenção de disco depende do tipo de mídia. Recall tem requisitos específicos de hardware e políticas que variam por edição.

Capturar cinco rodadas por configuração no mesmo PC e alternar a ordem dos testes. Comparar a mediana e a variação de FPS médio, 1% low e p99 de tempo de quadro. Se a diferença couber na variação normal, registrar o resultado como inconclusivo. Para falar em atraso de entrada, medir separadamente o tempo do clique até a mudança na tela.

## Referências

- Temporizadores de depuração do Windows: https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set
- Manutenção de volumes: https://learn.microsoft.com/powershell/module/storage/optimize-volume
- Recall e requisitos: https://learn.microsoft.com/en-us/windows/client-management/manage-recall
- Métricas de quadros e latência: https://github.com/GameTechDev/PresentMon/blob/main/README-CaptureApplication.md

## Opção 0 e critérios para novos cortes

- Ponteiro: desligar a aceleração do Windows pela API de preferências do usuário e preservar a velocidade. Medir a sensação no desktop. O efeito em jogo depende de como o jogo recebe a entrada.
- Widgets: usar a política documentada em edições compatíveis e preservar políticas já definidas. Verificar o estado após novo login e comparar o consumo antes de avaliar remoção de pacotes relacionados.
- Energia: manter o plano existente quando o notebook estiver na bateria. Com fonte conectada, comparar Equilibrado e Alto desempenho no mesmo hardware.
- Apps: o inventário da imagem identifica o pacote provisionado. O inventário em execução mostra se existe processo associado. O primeiro justifica avaliar espaço em disco. O segundo ajuda a decidir o que merece teste de CPU e RAM.
- GPU: testar a otimização de jogos em janela com DX10/DX11 e medir o tempo de quadro. A VM com adaptador virtual serve para verificar o fluxo de instalação e não fornece o resultado de GPU do PC físico.
- VM: PowerShell Direct retornou credencial inválida na tentativa de 12/11/2026. A coleta parou antes do baseline. Não há medição dessa rodada para justificar novos cortes.

Referências: [Microsoft sobre desempenho do Windows](https://support.microsoft.com/en-gb/windows/experience/performance-optimization/tips-to-improve-pc-performance-in-windows), [API do ponteiro](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa), [política de Widgets](https://learn.microsoft.com/windows/client-management/mdm/policy-csp-newsandinterests), [gráficos em janela](https://support.microsoft.com/en-us/windows/hardware/display-graphics/optimizations-for-windowed-games-in-windows-11), [componentes do AtlasOS](https://docs.atlasos.net/faq/install-faq/removed-features/).

## Referências de mercado e próximos testes

| Projeto | O que dá para verificar | Aplicação no BnqqOS |
| --- | --- | --- |
| [AtlasOS](https://github.com/Atlas-OS/Atlas/blob/main/docs/architecture.md) | Playbook público com checagem de pré-requisitos, estado de instalação, fases e configurações de energia e apps. | Registrar o estado antes e depois de cada ajuste da opção 0 e retomar somente etapas que falharam. |
| [ReviOS](https://github.com/meetrevision/playbook) | Playbook e ferramenta de configuração com versões de Windows suportadas explicitamente. | Bloquear ajustes que não se aplicam à edição ou build e mostrar a razão no relatório. |
| [Tiny11 Builder](https://github.com/ntdevlabs/tiny11builder/) | Monta a mídia a partir de uma fonte Windows e oferece listas de remoção. A edição normal preserva atualização, Defender e recuperação. | Publicar a receita, a lista de pacotes removidos e os hashes. Validar atualização e WinRE após instalar. |
| [Ghost Spectre, descrição da Techworm](https://www.techworm.net/2023/08/download-ghost-spectre-windows-11-superlite-iso.html) | A matéria descreve variantes Compact e Superlite e um painel pós-instalação. A matéria não demonstra ganho em jogo nem permite verificar a implementação. | Testar Compact OS separadamente em SSD com pouco espaço. Medir espaço, tempo de abertura e CPU antes de incluir. |
| [WinUtil](https://github.com/ChrisTitusTech/winutil) e [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/configure) | Instalação por catálogo e configuração reproduzível. | Reusar os IDs de pacote já presentes no painel e registrar resultado por item. Manter os launchers opcionais. |
| [Zenith](https://www.zenithoptimizacao.com/) e [Hype Tweaks](https://hypetweaks.com/) | Oferta comercial de otimização de Windows ou hardware. As páginas públicas consultadas não forneceram uma lista auditável de ajustes. | Usar como referência de apresentação. Exigir documentação ou medição própria para qualquer decisão técnica. |

Ordem de implementação:

1. **Relatório e restauração.** Mostrar por etapa os estados aplicado, já configurado, ignorado e falhou. Gravar valores anteriores e indicar se é preciso sair da conta ou reiniciar. Repetir a opção 0 duas vezes para confirmar que não duplica alterações.
2. **Inicialização e captura.** Usar inventário de início automático e um trace de CPU/disco para identificar processos ativos. Testar Widgets, inicialização de navegadores, sincronização opcional e captura em segundo plano individualmente. Preservar o que o usuário usa para gravar ou transmitir.
3. **Armazenamento com pouco espaço.** Avaliar Compact OS em flash/SSD de capacidade baixa. Preservar o arquivo de paginação gerenciado pelo Windows. Medir espaço, boot e carregamento de jogo. A orientação de implantação da Microsoft desaconselha Compact OS em disco rotacional.
4. **Prontidão pós-formatação.** Conferir WinGet, runtimes e GPU, apontar drivers do fabricante e exportar o resultado. Testar Windows Update, Store, recuperação e primeira instalação de um launcher em VM limpa.
5. **Validação competitiva.** Medir 1% lows e p99 no PC físico com temperatura e alimentação controladas. Guardar CSVs e informar a variação entre rodadas. Evitar ajustes globais de timer, rede, GPU ou BIOS sem teste no equipamento-alvo.

Métodos: [Compact OS](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/compact-os), [orientação para disco rotacional](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/oem-deployment-of-windows-desktop-editions?view=windows-11), [WPR para CPU e disco](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/recording-for-resource-based-analysis).
