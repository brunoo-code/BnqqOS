# BnqqOS
Uma instalação enxuta de Windows 11 x64 para quem usa o PC principalmente para jogar. O BnqqOS parte de mídia oficial da Microsoft, preserva os mecanismos de atualização e recuperação e mede o efeito de cada mudança.

- [Análise das alternativas e decisões](docs/analise.md)
- [Protocolo de validação em VM e notebook](docs/validacao.md)
- [Arquitetura em quatro módulos](docs/modulos.md)
- [Lista revisável de aplicativos candidatos](profiles/bnqqos.json)

## Estado atual

O construtor gera uma ISO inicializável a partir de uma ISO oficial do Windows 11. Ele usa DISM para remover os aplicativos previstos no perfil, registra o inventário antes e depois e permite incluir o executável do [BNQQ Toolkit](https://github.com/brunoo-code/bnqq-toolkit) no painel pós-instalação. Este repositório distribui os scripts, a identidade visual e a documentação de build.

- [Build verificado e checksum da ISO](docs/resultado-iso-menu-compacto.md)
- [Módulos de implementação](docs/modulos-implementacao.md)
- [Painel pós-instalação e critérios de otimização](docs/plano-otimizacao-painel.md)

O build atual usa o tema padrão do Windows. A instalação limpa desta mídia e os comparativos de RAM, CPU, disco e desempenho em jogos seguem pendentes.

## Benchmark

O analisador de benchmark resume um CSV bruto do PresentMon, já recortado para a janela de teste e filtrado para um único fluxo do jogo: `python scripts/bench_frames.py captura.csv --target-fps 144`. O 1% low é o inverso da média dos intervalos do 1% mais lento; p99 usa a posição inteira seguinte. São intervalos entre apresentações, sem inferir atraso de clique.

```powershell
.\scripts\Get-BnqqOSPlan.ps1 -InventoryPath .\examples\inventory.json
# Alternativa, em PowerShell elevado: apontar para imagem oficial já montada com DISM.
# .\scripts\Get-BnqqOSPlan.ps1 -OfflineImagePath C:\Montagem\BnqqOS
```

O inventário em [Get-BnqqOSOptimizationInventory.ps1](scripts/Get-BnqqOSOptimizationInventory.ps1) consulta CPU, RAM, paginação, discos, plano de energia, serviços e pacotes Copilot da conta atual. Consulte as [decisões de otimização](docs/decisoes-de-otimizacao.md) para ver quais mudanças entram na imagem e quais seguem para teste comparativo.
