# arch-post-install

Script de pós-instalação para Arch Linux com GNOME, PipeWire, codecs, drivers AMD e apps essenciais.

## Requisitos

- Arch Linux instalado via `archinstall`
- Repositório `multilib` habilitado
- Conexão com a internet
- Rodar como usuário comum (não root), com acesso ao `sudo`
- GPU AMD (o script instala `vulkan-radeon`)

## Uso

Execute direto, sem baixar o arquivo:

    bash <(curl -fsSL https://raw.githubusercontent.com/codebyfog/arch-post-install/main/install.sh)

Reinicie o sistema ao final.

> Use `bash <(...)` e não `curl ... | bash`: assim o teclado continua livre para responder às perguntas do `pacman` e do `paru`.

## O que o script faz

1. Atualiza o sistema
2. Instala áudio (PipeWire), codecs (GStreamer), drivers Vulkan AMD, GNOME e aplicativos
3. Aplica o tema escuro (adw-gtk3-dark)
4. Habilita os serviços GDM e LACT
5. Instala o paru (AUR helper)
6. Instala pacotes do AUR (Vesktop, Mixtapes)

## Aviso

Leia o script antes de executar. Ele instala pacotes e habilita serviços no seu sistema. Para conferir o conteúdo, abra o link abaixo no navegador:

    https://raw.githubusercontent.com/SEU-USUARIO/arch-post-install/main/install.sh

Use por sua conta e risco.
