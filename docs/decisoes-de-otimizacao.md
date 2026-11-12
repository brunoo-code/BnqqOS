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
