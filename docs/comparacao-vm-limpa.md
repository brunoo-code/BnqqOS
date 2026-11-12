# Comparação em VMs limpas

O par de teste usa duas VMs novas de geração 2, com 2 vCPUs, 4 GiB fixos, disco virtual de 80 GiB, Secure Boot e TPM. Instalar Windows Pro em disco vazio, igualar a build e as atualizações e medir uma VM por vez, após cinco minutos sem interações.

Na primeira sessão do BnqqOS, conferir Settings > Personalization > Colors > Choose your mode e registrar o valor mostrado. Conferir a configuração antes de executar qualquer script de tema.

Executar Get-BnqqOSBaseline.ps1 em cada convidado com 60 amostras e guardar ambos os JSONs. Compare-BnqqOSBaseline.ps1 rejeita pares com edição, build, quantidade de amostras ou RAM visível diferentes. O relatório calcula a diferença BnqqOS menos Windows oficial. Conferir o hardware virtual e o estado das atualizações separadamente.

A coleta anterior na VM BnqqOS-Setup-Test veio de uma instalação que tinha Windows.old e memória dinâmica. Ela não faz parte deste par.

## Registro da build

A segunda tentativa copiou a mídia e exportou o WIM, mas parou na validação antes de montar a imagem. A leitura do XML confirmou uma entrada de índice 1, com nome interno BnqqOS Win11 Pro 26H2, edição Professional e nome de exibição Windows 11 Pro. A fonte tinha Windows 11 Pro no índice 6 e edição Professional. O gerador agora valida o índice, a edição e o nome interno diretamente no XML.

A leitura foi testada com os dois arquivos reais. A retomada administrativa montou o WIM, gravou e conferiu os valores do perfil padrão e concluiu a geração da ISO.

A retomada pode usar a mídia já copiada e o WIM já exportado, com os hashes SHA-256 registrados no laboratório. O gerador confere o hash do WIM, o nome e a edição antes de montar a imagem e mantém o arquivo de instalação da mídia de trabalho até concluir a edição do WIM.

O disco BNQQ_AB contém o coletor atualizado. Ele registra a preferência de cores da conta, os processadores lógicos, a capacidade do volume e a presença de Windows.old. O comparador recusa instalações com Windows.old e relatórios atuais com processadores ou capacidade diferentes. Os campos de tema complementam a inspeção visual da página Cores no primeiro login. A conferência da memória fixa no Hyper-V e das atualizações continua necessária.

## ISO gerada em 12/11/2026

- Imagem interna BnqqOS Win11 Pro 26H2, edição Professional.
- Perfil padrão conferido na imagem montada com SystemUsesLightTheme e AppsUseLightTheme iguais a 0.
- ISO BnqqOS com 8.518.072.320 bytes e SHA-256 `00F22788F0C59F7346FBED65FDA33732237B76F7A5C51C12AF2EB3A970EBADA2`.
- ISO oficial com 9.047.330.816 bytes e SHA-256 `BD4307DF32BC8AF33B39CCECB1174AEB345386630F89A2B86C7A4E36B55EA650`.
- Pacotes removidos da imagem BnqqOS: Clipchamp, Bing News, Bing Weather e Microsoft Solitaire Collection.

O Hyper-V confirmou a configuração equivalente nas VMs BnqqOS-Clean-Dark e Windows11-Clean-Control. A VM BnqqOS-Clean-Dark chegou ao aviso para iniciar pelo DVD virtual, mas a janela foi aberta após o prazo do aviso e o firmware tentou iniciar pela rede. O primeiro login e as medições comparativas permanecem pendentes.
