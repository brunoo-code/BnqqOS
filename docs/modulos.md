# BnqqOS: quatro módulos

| Módulo | Padrão da primeira versão | Experimento separado |
| --- | --- | --- |
| ISO | Remover só aplicativos da lista exata. Manter Defender, Update, WinRE, Store, Gaming Services, WebView2, TPM, Secure Boot e o padrão de VBS/HVCI. | Avaliar Copilot se existir como app independente naquela build. Não presumir que Cortana esteja presente. |
| Serviços | Manter SysMain, Search, hibernação e DiagTrack no padrão. DiagTrack é serviço, não AppX. | Investigar CPU e disco no momento das travadas com WPR/WPA. Só testar SysMain ou Search separadamente se a captura apontar concorrência. Começar pelo escopo da indexação. |
| Toolkit | Perfil de sessão reversível, com estado anterior registrado. | Comparar captura retroativa ligada/desligada, sincronizadores em segundo plano, perfil térmico do fabricante na tomada e limite de FPS dentro do jogo. Testar cada mudança por vez. |
| Validação | Oficial × BnqqOS × BnqqOS com Toolkit, conforme o [protocolo](validacao.md). | Rodada sustentada de 20 minutos em notebook para detectar perda por calor. Captura WPR detalhada em rodada separada para não misturar o custo da ferramenta com o teste principal. |

## Decisões de engenharia

- SSD não prova que SysMain atrapalha. Hibernação usa disco, mas liberar esse espaço não demonstra ganho durante a partida. Em notebook, preservar suspensão e hibernação.
- A captura retroativa pode ser avaliada sem remover Xbox ou Game Bar. A preservação da Store, Gaming Services e WebView2 tem como objetivo a compatibilidade geral; não são requisitos documentados do Vanguard. Validar o VALORANT pelos canais oficiais. Não prometer ausência de banimentos.
- Não trocar C-States, HPET ou timers de boot por padrão. Mais consumo e calor podem piorar o desempenho sustentado. A Microsoft documenta a seleção de relógio pelo Windows e indica os ajustes BCDEdit de relógio para depuração.
- TCP_NODELAY é uma opção de socket TCP, não uma redução universal de ping; não altera UDP. Medir jitter, perda e latência sob carga em cenário separado.
- Um ajuste de desempenho só vira padrão quando o benefício supera a variação normal e é repetível sem regressão de estabilidade ou compatibilidade. Ganho de disco sem ganho de FPS é resultado válido de leveza.

## Construção da primeira imagem

Verificar a ISO oficial e registrar SHA-256, build, idioma e edição. Listar índices antes de escolher a edição: índice 1 não identifica uma edição universal. Se a mídia usar install.esd, exportar o índice selecionado para um WIM de trabalho e confirmar o índice resultante. Montar a cópia offline, inventariar, aplicar só a lista aprovada e conferir o delta antes de salvar; descartar a montagem se a conferência falhar. Não injetar chaves de registro na v1. Manter o boot original, empacotar com Oscdimg e validar UEFI em uma VM nova.

Referências: [WPR/WPA](https://learn.microsoft.com/en-us/troubleshoot/windows-server/support-tools/support-tools-xperf-wpa-wpr), [BCDEdit](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set), [relógios do Windows](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps), [TCP](https://learn.microsoft.com/en-us/windows/win32/winsock/ipproto-tcp-socket-options), [suporte do VALORANT](https://support.riotgames.com/en-us/valorant/).
