# Como provar o que mudou

**A:** Windows oficial limpo. **B:** BnqqOS, mesma build/edição/idioma e patches. **C:** BnqqOS com um perfil documentado do BNQQ Toolkit. Comparar A/B primeiro; depois B/C. Manter Windows e jogos atualizados de forma equivalente nas imagens.

1. **Hyper-V:** duas VMs novas de geração 2, mesmas vCPUs, RAM fixa, disco e segurança de boot. Testar instalação, atualizações cumulativas, reinício após atualização, WinRE, login, Store e instalação do Steam. Conferir o delta da lista AppX, guardar logs e verificar se continuam intactos os componentes preservados. A VM serve para compatibilidade básica e uso de disco; não serve para certificar desempenho ou compatibilidade do Vanguard.
2. **Notebook físico:** começar com um notebook de entrada que cumpra os requisitos oficiais do Windows 11. Usar mesmo aparelho, drivers, versão de jogo, resolução, preset, fonte conectada, perfil térmico, limite de FPS e estado dos caches. Se usar discos separados, igualar modelo e configuração ou controlar a diferença. Registrar temperatura, clocks e potência. Fazer aquecimento fora da medição.
3. **Cenários:** repouso cinco minutos após login; CS2 em trecho fixo de replay local para repetir a cena; VALORANT em modo treino para compatibilidade e observação, sem automatizar entradas. Partida online é teste complementar, pois servidor, jogadores e rede variam.
4. **Repetição:** pelo menos cinco execuções válidas por condição e cenário, alternando A/B em blocos com ordem balanceada para reduzir viés térmico. Fixar janela de captura e critério de exclusão antes de iniciar. Divulgar dados por execução, mediana e dispersão; ganho menor do que a variação entre rodadas é inconclusivo.
5. **Métricas separadas:** disco ocupado após atualizações, tempo de boot, RAM disponível/comprometida, CPU e disco em repouso. Em jogo, FPS médio, 1% low com definição publicada, p99 do tempo de quadro e frames acima do dobro do orçamento de tempo do FPS alvo. Usar [PresentMon](https://github.com/GameTechDev/PresentMon/blob/main/README-CaptureApplication.md) e guardar CSVs. Tempo de quadro não mede clique até a tela; só anunciar ganho de input lag com medição própria de clique até a imagem.
6. **Aceite:** a primeira imagem precisa instalar e atualizar, preservar recuperação e passar nos testes de compatibilidade. Se liberar espaço sem alterar FPS, divulgar o resultado como instalação mais enxuta. Se houver perda de compatibilidade ou regressão consistente, identificar e reverter a mudança antes de recomendar a edição.

## Teste da opção 0

Depois das atualizações, tire um checkpoint da VM BnqqOS e deixe o
sistema em repouso por cinco minutos. Capture o baseline e o inventário
de otimização. Execute a opção 0 no painel Configure BnqqOS, registre o
resultado e reinicie se solicitado. Repita as medições na mesma VM,
com o mesmo tempo de repouso. Use Compare-BnqqOSBaseline.ps1 com
-SameVm para obter os deltas e guarde o setup.log junto aos relatórios.

No notebook, compare também Equilibrado e Alto desempenho, com a
mesma fonte e condição térmica. A VM mede consumo em repouso. A
medição de tempo de quadro e 1% low é feita no hardware físico.

## Experimento Compact OS

Use uma instalação limpa de teste. No PC atual, o SSD SATA tem uma
partição D: em uso. Para validar o fluxo sem formatar, use um disco
virtual dedicado. Para avaliar desempenho físico, use uma instalação
de teste em SSD com backup e autorização específica.

- Capture Before e After com Get-BnqqOSCompactTrial.ps1, em arquivos
  separados, na mesma instalação. O coletor apenas consulta o estado
  de compressão e mede 60 amostras de RAM, CPU e disco.
- Use a mesma condição de boot em cada rodada. Se usar cronômetro
  externo, informe BootMilliseconds medindo do mesmo ponto até a
  área de trabalho pronta. Use GameLoadMilliseconds e GameScenario
  para a mesma cena local, com o mesmo ponto de início e fim.
- Faça pelo menos três rodadas por condição, mantendo a versão do
  Windows, espaço de jogo, energia e atualizações equivalentes.
  Compare as medianas de boot e carregamento. Use
  Compare-BnqqOSBaseline.ps1 -SameVm para os deltas de repouso de cada par.
- Confira o texto de CompactQuery de cada relatório antes de comparar.
  Use o WPR quando precisar atribuir uma diferença de boot a CPU ou disco.

Referência: https://learn.microsoft.com/en-us/windows-hardware/test/wpt/optimizing-performance-and-responsiveness-exercise-2
