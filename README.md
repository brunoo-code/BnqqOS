# BnqqOS
Uma instalação enxuta de Windows 11 x64 para quem usa o PC principalmente para jogar. O BnqqOS parte de mídia oficial da Microsoft, preserva os mecanismos de atualização e recuperação e mede o efeito de cada mudança.

- [Análise das alternativas e decisões](docs/analise.md)
- [Protocolo de validação em VM e notebook](docs/validacao.md)
- [Arquitetura em quatro módulos](docs/modulos.md)
- [Lista revisável de aplicativos candidatos](profiles/bnqqos.json)

O protótipo atual consulta um inventário e lista os candidatos encontrados. Ele não remove aplicativos, não gera ISO e não muda o Windows em execução. O projeto pretende distribuir scripts e instruções para o usuário gerar sua própria mídia a partir de uma ISO oficial; não inclui binários do Windows.

O analisador de benchmark resume um CSV bruto do PresentMon, já recortado para a janela de teste e filtrado para um único fluxo do jogo: `python scripts/bench_frames.py captura.csv --target-fps 144`. O 1% low é o inverso da média dos intervalos do 1% mais lento; p99 usa a posição inteira seguinte. São intervalos entre apresentações, sem inferir atraso de clique.

```powershell
.\scripts\Get-BnqqOSPlan.ps1 -InventoryPath .\examples\inventory.json
# Alternativa, em PowerShell elevado: apontar para imagem oficial já montada com DISM.
# .\scripts\Get-BnqqOSPlan.ps1 -OfflineImagePath C:\Montagem\BnqqOS
```

O inventário em [Get-BnqqOSOptimizationInventory.ps1](scripts/Get-BnqqOSOptimizationInventory.ps1) consulta CPU, RAM, paginação, discos, plano de energia, serviços e pacotes Copilot da conta atual. Consulte as [decisões de otimização](docs/decisoes-de-otimizacao.md) para ver quais mudanças entram na imagem e quais seguem para teste comparativo.
