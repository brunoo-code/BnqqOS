# Plano de otimização do BnqqOS

O painel inclui consultas de energia e serviços, além de atalhos para as configurações de energia e Modo de Jogo. O instalador continua dedicado à preparação do sistema.

| Função do BNQQ Toolkit | Aplicação na BnqqOS |
| --- | --- |
| Diagnóstico, prontidão e inventário de drivers | Mostrar GPU, versão do driver, plano ativo e serviços. Em seguida, oferecer relatório local de rede, armazenamento e eventos WHEA. |
| Energia | Comparar planos que já existem no Windows. Testar mudanças individualmente, salvar o plano anterior e verificar sua restauração. Medir temperatura e tempo de quadro em hardware real. |
| Sessão Focus e manutenção | Considerar pausar a indexação do Windows Search durante uma sessão, com restauração e sem alterar o tipo de inicialização, como no Toolkit. Avaliar se há atividade real de indexação durante o teste. |
| CS2 e VALORANT | Oferecer perfis locais depois de detectar a instalação do jogo. Fazer backup das configurações antes de qualquer aplicação. |
| FrameBench | Usar três capturas por variante no mesmo cenário e com os mesmos ajustes, alternando a ordem. Comparar p99 de tempo de quadro e verificar a dispersão. |
| Rede, GPU e serviços | Começar com diagnóstico. Tratar cada ajuste como experimento reversível. Preservar Windows Update, Defender, Secure Boot e configurações de virtualização e segurança. |

Validar a instalação, a navegação do painel e os estados dos serviços na VM. Ganhos de desempenho em jogo e compatibilidade com os anti-cheats devem ser avaliados no PC de teste físico.

A opção 9 abre o executável completo do BNQQ Toolkit. Para incluir o binário na imagem, passe o caminho de BNQQ_Optimizer.exe em -ToolkitExe ao rodar New-BnqqOS.ps1. O SHA-256 do binário copiado consta no manifest.json. Em uma mídia de teste, o painel também aceita BNQQ_Optimizer.exe ao lado do .bat.

## Limpeza de apps da conta e diagnóstico de inicialização

O Toolkit no commit `ca732b8` inclui Gravador de Voz, Hub de Feedback,
Dev Home, To Do e Power Automate Desktop na lista de remoção da opção 0.
Copilot já fazia parte da lista. A remoção consulta novamente cada pacote
e registra um relatório JSON por execução na conta atual. O teste
simulado confirmou os estados removido, ausente e falhou.

A opção 0 também mostra os itens de inicialização e lê a preferência
atual de captura. Esses dados serão usados para decidir quais ajustes
de segundo plano devem ter aplicação e restauração próprias.

O DVD `BNQQ_APPS_QA` foi anexado à VM `BnqqOS-Teste`. O teste real
depende da execução de `Run BNQQ Option 0.cmd` dentro da sessão da VM.
Nenhuma remoção real foi registrada até esta atualização.
