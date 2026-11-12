# Identidade e próximas melhorias do BnqqOS

O avatar usa um B geométrico em menta com um detalhe violeta. O wallpaper mantém o azul escuro e deixa a esquerda livre para ícones. Os arquivos estão em ../assets/branding. O JPG é a cópia para a política de wallpaper do Windows.

Para validar a identidade, aplique a foto padrão de conta e a política Desktop Wallpaper na VM de teste após a coleta inicial. Verifique o avatar em duas contas locais, o papel de parede após sair e entrar e a reversão pelo administrador. O BnqqOS usa o wallpaper fixo e a foto padrão fixa para todas as contas via política local. O script scripts/Set-BnqqOSBranding.ps1 usa a ferramenta Microsoft LGPO.exe e salva cópias das políticas e imagens existentes antes de aplicar. O wallpaper tem versões 1920×1080 e 3840×2160, redimensionadas a partir da arte original. A validação visual na VM está pendente.

## O que vale trazer

1. **Prévia e reversão.** Um painel de primeira execução apresenta os ajustes por objetivo, registra os valores anteriores e exporta um relatório local. O AtlasOS oferece opções de instalação e pós-instalação. Para o BnqqOS, a ideia é facilitar a comparação de uma mudança por vez.
2. **Instalação limpa com lista explícita.** Começar pelos apps opcionais. Separar remoções feitas na imagem de preferências por usuário, como sugestões e captura em segundo plano. Manter Windows Update, Defender, Secure Boot, TPM e a recuperação. Validar serviços como SysMain e indexação em testes separados antes de decidir qualquer padrão.
3. **Benchmark público e reproduzível.** Na VM, comparar a mesma edição, build, nível de updates e recursos de hardware virtual. Medir RAM, CPU ociosa e disco após estabilizar. Em PC real, usar a mesma configuração gráfica, driver e cenário, repetir as rodadas e registrar FPS, 1% low e p99 de tempo de quadro com PresentMon. Registrar separadamente inicialização de Steam, CS2, Riot Client e VALORANT.
4. **Rastreabilidade da imagem.** Registrar hash SHA-256 da ISO oficial, versão do Windows, lista de pacotes removidos e hash do resultado. Isso permite conferir o que cada build mudou.

## Referências consultadas

- AtlasOS, opções e código: https://github.com/Atlas-OS/Atlas
- Ghost Spectre, descrição das variantes: https://www.techworm.net/2023/08/download-ghost-spectre-windows-11-superlite-iso.html
- Discussão da comunidade sobre Compact e Superlite: https://www.reddit.com/r/ghostspectre/comments/1c1ceed/ghost_spectre_windows_11_compact_vs_superlight/
- Hype Tweaks, posicionamento comercial sobre ajustes de PC e BIOS: https://hypetweaks.com/
- Zenith, consultado como referência comercial. A página não expôs conteúdo detalhado na leitura: https://www.zenithoptimizacao.com/
- Microsoft, política de foto padrão para contas: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-admx-cpls
- Microsoft, política de wallpaper: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-admx-desktop
- Intel PresentMon, métricas de captura: https://github.com/GameTechDev/PresentMon/blob/main/README-CaptureApplication.md

As discussões ajudam a escolher hipóteses. A evidência de desempenho do BnqqOS virá dos próprios testes A/B.
