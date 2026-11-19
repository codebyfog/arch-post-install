#!/usr/bin/env bash
set -e

echo "==> 1. Atualizando repositórios e sistema..."
sudo pacman -Syu --noconfirm

echo "==> 2. Instalando Áudio, Vídeo, Codecs, GNOME e Apps..."
sudo pacman -S --needed \
    pipewire-audio \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    rtkit \
    vulkan-radeon \
    lib32-vulkan-radeon \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gst-libav \
    gst-plugin-pipewire \
    gdm \
    gnome-control-center \
    nautilus \
    gvfs \
    adw-gtk-theme \
    ttf-dejavu \
    ptyxis \
    loupe \
    decibels \
    showtime \
    gnome-text-editor \
    evince \
    fragments \
    gnome-disk-utility \
    sushi \
    eyedropper \
    lact \
    steam \
    firefox \
    mise \
    helix

echo "==> 3. Aplicando tema adw-gtk-theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "==> 4. Habilitando mise..."
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

echo "==> 5. Habilitando serviços essenciais (GDM e LACT)..."
sudo systemctl enable gdm.service lactd.service

echo "==> 6. Instalando dependências de compilação, firefox-gnome-theme e paru..."
sudo pacman -S --needed --noconfirm base-devel git
tmpdir="$(mktemp -d)"

# 1. Cria o perfil headless do Firefox e instala o tema primeiro
firefox --headless --CreateProfile default
git clone --depth=1 https://github.com/rafaelmardojai/firefox-gnome-theme.git "$tmpdir/firefox-gnome-theme"
(cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh)

# 2. Instala o paru-bin em seguida
git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
(cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)

# 3. Remove a pasta temporária com ambos os repositórios
rm -rf "$tmpdir"

echo "==> 7. Instalando pacotes do AUR (Vesktop)..."
paru -S --needed \
    vesktop-bin 
    
echo "==> Pós-instalação concluída! Pode reiniciar."
