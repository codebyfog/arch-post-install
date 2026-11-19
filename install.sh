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

echo "==> 6. Instalando dependências de compilação, firefox-gnome-theme, helix adwaita theme e paru..."
sudo pacman -S --needed --noconfirm base-devel git
tmpdir="$(mktemp -d)"

# 1. Inicializa o Firefox brevemente para criar o perfil *.default-release
timeout 5s firefox --headless >/dev/null 2>&1 || true

git clone --depth=1 https://github.com/rafaelmardojai/firefox-gnome-theme.git "$tmpdir/firefox-gnome-theme"

# Detecta o diretório base do Firefox (~/.config/mozilla/firefox ou ~/.mozilla/firefox)
ff_dir=""
for dir in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox"; do
    if [ -d "$dir" ]; then
        ff_dir="$dir"
        break
    fi
done

# Pega apenas o nome da pasta *.default-release
profile_name="$(find "$ff_dir" -maxdepth 1 -type d -name "*.default-release" -printf "%f\n" 2>/dev/null | head -n 1)"

if [ -n "$ff_dir" ] && [ -n "$profile_name" ]; then
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh -f "$ff_dir" -p "$profile_name")
elif [ -n "$ff_dir" ]; then
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh -f "$ff_dir")
else
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh)
fi

echo "==> Configurando Helix..."
mkdir -p "$HOME/.config/helix"
if [ ! -f "$HOME/.config/helix/config.toml" ]; then
    cat << 'EOF' > "$HOME/.config/helix/config.toml"
theme = "adwaita-dark"
EOF
fi

# 2. Instala o paru-bin em seguida
git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
(cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)

# 3. Remove a pasta temporária com ambos os repositórios
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "==> 7. Instalando pacotes do AUR (Vesktop)..."
paru -S --needed \
    vesktop-bin 
    
echo "==> Pós-instalação concluída! Pode reiniciar."
