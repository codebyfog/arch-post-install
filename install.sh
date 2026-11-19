#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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
    helix \
    git

echo "==> 3. Aplicando tema adw-gtk-theme, neuwaita e wallpapers..."
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

wallpapers_src="$script_dir/Wallpapers"
wallpapers_dst="$HOME/Wallpapers"

if [ -d "$wallpapers_src" ]; then
    mkdir -p "$wallpapers_dst"
    cp -r "$wallpapers_src/." "$wallpapers_dst/"

    default_wp="$wallpapers_dst/01.jpeg"
    if [ -f "$default_wp" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$default_wp"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$default_wp"
        gsettings set org.gnome.desktop.background picture-options 'zoom'
    fi
fi

icons_dir="$HOME/.local/share/icons"
neuwaita_dst="$icons_dir/Neuwaita"

mkdir -p "$icons_dir"
if [ ! -d "$neuwaita_dst" ]; then
    git clone --depth=1 https://github.com/xydani/Neuwaita.git "$neuwaita_dst"
    rm -rf "$neuwaita_dst/.git"
fi

gsettings set org.gnome.desktop.interface icon-theme 'Neuwaita'

echo "==> 4. Configurando mise e Helix..."
grep -qxF 'eval "$(mise activate bash)"' "$HOME/.bashrc" || echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"

mkdir -p "$HOME/.config/helix"
if [ ! -f "$HOME/.config/helix/config.toml" ]; then
    cat << 'EOF' > "$HOME/.config/helix/config.toml"
theme = "adwaita-dark"
EOF
fi

echo "==> 5. Habilitando serviços essenciais (GDM e LACT)..."
sudo systemctl enable gdm.service lactd.service

echo "==> 6. Instalando dependências, firefox-gnome-theme e paru-bin..."
sudo pacman -S --needed --noconfirm base-devel

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Inicializa o Firefox brevemente para gerar o perfil *.default-release
timeout 5s firefox --headless >/dev/null 2>&1 || true

git clone --depth=1 https://github.com/rafaelmardojai/firefox-gnome-theme.git "$tmpdir/firefox-gnome-theme"

ff_dir=""
for dir in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox"; do
    if [ -d "$dir" ]; then
        ff_dir="$dir"
        break
    fi
done

profile_name=""
if [ -n "$ff_dir" ]; then
    profile_name="$(find "$ff_dir" -maxdepth 1 -type d -name "*.default-release" -printf "%f\n" 2>/dev/null | head -n 1)"
fi

if [ -n "$ff_dir" ] && [ -n "$profile_name" ]; then
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh -f "$ff_dir" -p "$profile_name")
elif [ -n "$ff_dir" ]; then
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh -f "$ff_dir")
else
    (cd "$tmpdir/firefox-gnome-theme" && ./scripts/install.sh)
fi

git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
(cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)

echo "==> 7. Instalando pacotes do AUR (Vesktop)..."
paru -S --needed \
    vesktop-bin

echo "==> Pós-instalação concluída! Pode reiniciar."
