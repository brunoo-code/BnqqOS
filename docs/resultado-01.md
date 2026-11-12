# Primeira imagem BnqqOS

Base: ISO oficial Windows 11 x64 em inglês, build 26300.9457. O SHA-256 da origem coincidiu com o publicado pela Microsoft. A imagem do BnqqOS foi gerada a partir do índice 6, Windows 11 Pro.

| Medida na mídia | ISO oficial | BnqqOS |
| --- | ---: | ---: |
| Tamanho do arquivo ISO (bytes) | 9.047.330.816 | 8.517.957.632 |
| Apps provisionados no Windows 11 Pro | 47 | 43 |

O DISM confirmou a remoção de Clipchamp, Notícias, Clima e Solitaire. A diferença de tamanho entre ISOs inclui o efeito de exportar apenas a edição Pro e de reempacotar a mídia. O espaço ocupado após a instalação e a inicialização das VMs ainda precisam ser medidos.

Artefatos locais em `D:\BnqqOS-Lab\build-01`: BnqqOS.iso, manifest.json e build.log.

A BnqqOS iniciou pela ISO, concluiu a instalação e chegou à área de trabalho, conforme confirmado pelo operador da VM. As medições pós-instalação dependem da instalação da VM de controle.

## Build de primeiro uso de 12/11/2026

- ISO: `D:\BnqqOS-Lab\build-first-setup-ab5fb13\BnqqOS.iso` (8.518.604.800 bytes).
- SHA-256: `0FF05B552DE52FA8597BF3B2525F1B17F9D57397143122D483C2177D5B43B07B`.
- Instalador: BnqqOS Win11 Pro 26H2. O build verificou os valores de tema escuro no perfil padrão e incluiu Configure BnqqOS com a opção 0.
- DISM confirmou seis remoções: Clipchamp, Notícias, Clima, Solitaire, hub do Microsoft 365 e novo Outlook. O pacote independente do Copilot não estava provisionado na mídia de origem.
- O Toolkit embutido é o do commit `1fa7b9f`, com SHA-256 `4BA5B768C4FFFAAF616169D690E13C631A8BBD03A8DAD512CFB8637E6294BF33`. Os ajustes de ponteiro, Widgets e bateria entraram no Toolkit após o início deste build.
- PowerShell Direct rejeitou a credencial da VM antes do baseline. Nenhuma comparação de consumo ou execução da opção 0 na VM foi concluída nesta rodada. O boot e o primeiro login desta mídia também aguardam teste.

## Build com aparência padrão do Windows

- ISO: `C:\Users\bruno\Documents\BnqqOS-Lab\build-windows-default-90228f5\BnqqOS.iso` (8.518.604.800 bytes).
- SHA-256: `E4662BE12C38E5017C93CA214EDEF793090F7136117787FCD64893648E7589E0`.
- O manifesto registra `WindowsDefault`. O gerador não grava preferência de tema no perfil padrão. A aparência real do primeiro login ainda precisa ser observada em uma instalação nova.
- O hash do Toolkit embutido coincide com o executável do commit `1ad0fa0`: `6ECB6B0535EDC745D9B996FAF05C1865AD7DB7E03D3A3B9881E71066411991EB`.
- A sessão PowerShell Direct foi rejeitada antes da medição. O DVD `BNQQ_GUEST_QA` foi anexado à VM `BnqqOS-Teste` após a geração da ISO. A coleta interativa ainda não produziu dados.
