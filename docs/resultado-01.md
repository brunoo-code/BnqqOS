# Primeira imagem BnqqOS

Base: ISO oficial Windows 11 x64 em inglês, build 26300.9457. O SHA-256 da origem coincidiu com o publicado pela Microsoft. A imagem do BnqqOS foi gerada a partir do índice 6, Windows 11 Pro.

| Medida na mídia | ISO oficial | BnqqOS |
| --- | ---: | ---: |
| Tamanho do arquivo ISO (bytes) | 9.047.330.816 | 8.517.957.632 |
| Apps provisionados no Windows 11 Pro | 47 | 43 |

O DISM confirmou a remoção de Clipchamp, Notícias, Clima e Solitaire. A diferença de tamanho entre ISOs inclui o efeito de exportar apenas a edição Pro e de reempacotar a mídia. O espaço ocupado após a instalação e a inicialização das VMs ainda precisam ser medidos.

Artefatos locais em `D:\BnqqOS-Lab\build-01`: BnqqOS.iso, manifest.json e build.log.

A BnqqOS iniciou pela ISO, concluiu a instalação e chegou à área de trabalho, conforme confirmado pelo operador da VM. As medições pós-instalação dependem da instalação da VM de controle.
