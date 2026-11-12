# Comparação em VMs limpas

O par de teste usa duas VMs novas de geração 2, com 2 vCPUs, 4 GiB fixos, disco virtual de 80 GiB, Secure Boot e TPM. Instalar Windows Pro em disco vazio, igualar a build e as atualizações e medir uma VM por vez, após cinco minutos sem interações.

Na primeira sessão do BnqqOS, conferir Settings > Personalization > Colors > Choose your mode e registrar o valor mostrado. Conferir a configuração antes de executar qualquer script de tema.

Executar Get-BnqqOSBaseline.ps1 em cada convidado com 60 amostras e guardar ambos os JSONs. Compare-BnqqOSBaseline.ps1 rejeita pares com edição, build, quantidade de amostras ou RAM visível diferentes. O relatório calcula a diferença BnqqOS menos Windows oficial. Conferir o hardware virtual e o estado das atualizações separadamente.

A coleta anterior na VM BnqqOS-Setup-Test veio de uma instalação que tinha Windows.old e memória dinâmica. Ela não faz parte deste par.
