# Comparação em VMs limpas

O par de teste usa duas VMs novas de geração 2, com 2 vCPUs, 4 GiB fixos, disco virtual de 80 GiB, Secure Boot e TPM. Instalar Windows Pro em disco vazio, igualar a build e as atualizações e medir uma VM por vez, após cinco minutos sem interações.

Na primeira sessão do BnqqOS, conferir Settings > Personalization > Colors > Choose your mode e registrar o valor mostrado. Conferir a configuração antes de executar qualquer script de tema.

Executar Get-BnqqOSBaseline.ps1 em cada convidado com 60 amostras e guardar ambos os JSONs. Compare-BnqqOSBaseline.ps1 rejeita pares com edição, build, quantidade de amostras ou RAM visível diferentes. O relatório calcula a diferença BnqqOS menos Windows oficial. Conferir o hardware virtual e o estado das atualizações separadamente.

A coleta anterior na VM BnqqOS-Setup-Test veio de uma instalação que tinha Windows.old e memória dinâmica. Ela não faz parte deste par.

## Registro da build

A segunda tentativa copiou a mídia e exportou o WIM, mas parou na validação antes de montar a imagem. A leitura do XML confirmou uma entrada de índice 1, com nome interno BnqqOS Win11 Pro 26H2, edição Professional e nome de exibição Windows 11 Pro. A fonte tinha Windows 11 Pro no índice 6 e edição Professional. O gerador agora valida o índice, a edição e o nome interno diretamente no XML.

A leitura foi testada com os dois arquivos reais. A execução completa da correção ainda depende de uma sessão administrativa para montar o WIM, ajustar o perfil inicial, gerar a ISO e preparar as VMs. O primeiro login e as medições comparativas permanecem pendentes.
