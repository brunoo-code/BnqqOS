# Plano de trabalho do BnqqOS

## 1. Medir a VM atual

O Windows Update terminou. O Gerenciador de Tarefas mostrou 2,9 GB de RAM em uso e o Explorador mostrou cerca de 33,7 GB ocupados em C:. O disco de diagnóstico leva o coletor para dentro da VM. A etapa termina com um relatório de 60 amostras de CPU, memória, versão do Windows e disco.

## 2. Comparar com o Windows oficial

Usar a VM de controle com a mesma edição, build, atualizações, dois processadores virtuais, 4 GB de RAM fixa e disco equivalente. Igualar também a VM BnqqOS antes da comparação formal. Medir as duas separadamente, após o mesmo período em repouso, e registrar diferenças de RAM, CPU e disco.

## 3. Aplicar a identidade visual

Depois de registrar a medição inicial, aplicar a política local de wallpaper e foto padrão na VM. Validar após entrar novamente e confirmar que uma conta comum não consegue alterar as imagens pelas Configurações. Manter a cópia de segurança das configurações anteriores.

## 4. Testar os ajustes de desempenho

Medir um ajuste por vez. Usar a VM para verificar instalação e funcionamento básico. No PC de teste, comparar FPS e tempo de quadro sob o mesmo cenário, versão do jogo e configuração gráfica. Registrar somente ganhos que se repitam.

## Padrão visual da próxima imagem

A instalação nova deve manter o modo de cores padrão do Windows. No primeiro login, verifique o papel de parede do BnqqOS, o painel na área de trabalho e a disponibilidade das opções de tema em Configurações.

Os ajustes de desempenho serão medidos separadamente das preferências de aparência, com comparação contra o Windows oficial na mesma build.

A ISO configura Escuro como modo inicial em Personalização > Cores para o Windows e os aplicativos compatíveis. O instalador recebe essa preferência pelo perfil padrão da imagem. Validar em uma instalação limpa no primeiro login. A opção continua editável.

## Ordem dos testes de otimização

| Etapa | Mudança | Como decidir |
| --- | --- | --- |
| A | Windows Pro oficial | Registrar a build e o nível de atualização. Fixar 2 vCPUs, 4 GB de RAM e disco equivalente. |
| B | BnqqOS com remoção dos quatro apps opcionais e cor Escuro | Usar instalação limpa, sem Windows.old. Comparar espaço, RAM e CPU com A. Conferir Windows Update e Microsoft Store. |
| C | BnqqOS com um perfil opcional aplicado depois de instalar | Testar primeiro gravação em segundo plano e depois apps de inicialização, separadamente. Registrar a configuração anterior e o efeito de cada ajuste. |
| D | Validação em hardware real | Repetir o mesmo cenário no mesmo PC. Registrar FPS médio, 1% low e p99 de tempo de quadro. Verificar a abertura dos jogos e a estabilidade. |

A VM já usada é adequada para conferir o instalador e o visual. O Explorador mostrou Windows.old nessa VM. Os 33,71 GiB coletados são uma referência dessa instalação e não entram como valor de uma instalação limpa. Preservar Windows Update, Defender, Secure Boot, TPM, drivers e recuperação em todas as etapas.
