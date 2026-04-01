#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   Ubuntu GNOME — Catppuccin Mocha Blue Dark Rice             ║
# ║   rice-install.sh                                            ║
# ║                                                              ║
# ║   O que instala:                                             ║
# ║   • Dependências base                                        ║
# ║   • JetBrainsMono Nerd Font                                  ║
# ║   • GTK Theme: Catppuccin Mocha Sapphire                     ║
# ║   • Ícones: Papirus-Dark + pastas Catppuccin                 ║
# ║   • Cursor: Catppuccin Mocha Dark                            ║
# ║   • Terminal: Kitty (Catppuccin)                             ║
# ║   • Prompt: Starship (azul)                                  ║
# ║   • Fastfetch + ASCII art                                    ║
# ║   • Plymouth: tema Catppuccin boot                           ║
# ║   • GRUB: tema Catppuccin                                    ║
# ║   • clear → volta ao fastfetch                               ║
# ║   • GDM: tela de login Catppuccin                            ║
# ║   • Aplicar temas via gsettings                              ║
# ║                                                              ║
# ║   Uso: bash rice-install.sh                                  ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Cores ─────────────────────────────────────────────────────────────────────
BL='\033[38;2;137;180;250m'   # blue
CY='\033[38;2;116;199;236m'   # sapphire
SK='\033[38;2;137;220;235m'   # sky
DM='\033[38;2;88;91;112m'     # dim
GR='\033[38;2;166;227;161m'   # green
RD='\033[38;2;243;139;168m'   # red
R='\033[0m'

info()    { echo -e "  ${BL}→${R}  $*"; }
success() { echo -e "  ${GR}✓${R}  $*"; }
warn()    { echo -e "  ${RD}!${R}  $*"; }
section() { echo -e "\n${DM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n${CY}  $*${R}\n${DM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"; }

ERRORS=()
catch() { ERRORS+=("$1"); warn "Falhou: $1 — continuando..."; }

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "
${BL}  ╔══════════════════════════════════════╗
  ║   Catppuccin Mocha · Blue Dark Rice  ║
  ╚══════════════════════════════════════╝${R}
${DM}  Ubuntu GNOME · bezerraluiz${R}
"

# ── 1. Dependências ───────────────────────────────────────────────────────────
section "1/11 · Dependências"

sudo apt-get update -qq
sudo apt-get install -y \
    gnome-tweaks \
    gnome-shell-extension-manager \
    git curl wget unzip python3 \
    kitty \
    fastfetch 2>/dev/null || \
sudo apt-get install -y \
    gnome-tweaks \
    gnome-shell-extension-manager \
    git curl wget unzip python3 \
    kitty

success "Dependências instaladas"

# ── 2. Fonte: JetBrainsMono Nerd Font ─────────────────────────────────────────
section "2/11 · JetBrainsMono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if fc-list | grep -q "JetBrainsMono"; then
    success "JetBrainsMono já instalada"
else
    info "Baixando JetBrainsMono Nerd Font..."
    cd /tmp
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
         -O JetBrainsMono.zip || catch "Download JetBrainsMono"
    unzip -q JetBrainsMono.zip -d JetBrainsMonoNF 2>/dev/null || true
    cp JetBrainsMonoNF/*.ttf "$FONT_DIR/" 2>/dev/null || true
    rm -rf JetBrainsMono.zip JetBrainsMonoNF
    fc-cache -fv > /dev/null 2>&1
    success "JetBrainsMono Nerd Font instalada"
fi

# ── 3. GTK Theme: Catppuccin Mocha Sapphire ───────────────────────────────────
section "3/11 · GTK Theme: Catppuccin Mocha Sapphire"

THEME_DIR="$HOME/.themes"
mkdir -p "$THEME_DIR"

if [ -d "$THEME_DIR/catppuccin-mocha-sapphire-standard+default" ]; then
    success "GTK theme já instalado"
else
    info "Baixando GTK theme..."
    cd /tmp
    wget -q "https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-sapphire-standard+default.zip" \
         -O catppuccin-gtk.zip || catch "Download GTK theme"
    unzip -q catppuccin-gtk.zip -d "$THEME_DIR/" 2>/dev/null || true
    rm -f catppuccin-gtk.zip
    success "GTK theme instalado"
fi

# ── 4. Ícones: Papirus-Dark + Catppuccin folders ──────────────────────────────
section "4/11 · Ícones Papirus + pastas Catppuccin"

if dpkg -l papirus-icon-theme &>/dev/null; then
    success "Papirus já instalado"
else
    sudo add-apt-repository -y ppa:papirus/papirus > /dev/null 2>&1
    sudo apt-get update -qq
    sudo apt-get install -y papirus-icon-theme > /dev/null 2>&1
    success "Papirus instalado"
fi

info "Aplicando pastas Catppuccin Sapphire..."
cd /tmp
wget -q "https://github.com/catppuccin/papirus-folders/releases/latest/download/papirus-folders-catppuccin.sh" \
     -O papirus-folders-catppuccin.sh || catch "Download Papirus folders"
chmod +x papirus-folders-catppuccin.sh
./papirus-folders-catppuccin.sh --color cat-mocha-sapphire --theme Papirus-Dark 2>/dev/null || \
    catch "Papirus folders Catppuccin"
rm -f papirus-folders-catppuccin.sh
success "Papirus-Dark com pastas azuis configurado"

# ── 5. Cursor: Catppuccin Mocha Dark ─────────────────────────────────────────
section "5/11 · Cursor Catppuccin"

CURSOR_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSOR_DIR"

if [ -d "$CURSOR_DIR/catppuccin-mocha-dark-cursors" ]; then
    success "Cursor já instalado"
else
    info "Baixando cursores Catppuccin..."
    cd /tmp
    wget -q "https://github.com/catppuccin/cursors/releases/latest/download/catppuccin-mocha-dark-cursors.zip" \
         -O catppuccin-cursors.zip || catch "Download cursors"
    unzip -q catppuccin-cursors.zip -d "$CURSOR_DIR/" 2>/dev/null || true
    rm -f catppuccin-cursors.zip
    success "Cursor Catppuccin instalado"
fi

# ── 6. Kitty config ───────────────────────────────────────────────────────────
section "6/11 · Kitty Terminal"

mkdir -p "$HOME/.config/kitty"
cat > "$HOME/.config/kitty/kitty.conf" << 'KITTY'
# Catppuccin Mocha — Kitty
font_family      JetBrainsMono Nerd Font Mono
font_size        12.0
cursor                #f5e0dc
cursor_text_color     #1e1e2e
cursor_shape          beam
url_color             #89b4fa
window_padding_width  14
background_opacity    0.92
hide_window_decorations yes
tab_bar_style           powerline
tab_powerline_style     slanted
active_tab_background   #89b4fa
active_tab_foreground   #1e1e2e
inactive_tab_background #313244
inactive_tab_foreground #a6adc8
background   #1e1e2e
foreground   #cdd6f4
color0       #45475a
color8       #585b70
color1       #f38ba8
color9       #f38ba8
color2       #a6e3a1
color10      #a6e3a1
color3       #f9e2af
color11      #f9e2af
color4       #89b4fa
color12      #89b4fa
color5       #f5c2e7
color13      #f5c2e7
color6       #94e2d5
color14      #94e2d5
color7       #bac2de
color15      #a6adc8
KITTY
success "Kitty configurado"

# ── 7. Starship prompt ────────────────────────────────────────────────────────
section "7/11 · Starship Prompt"

if ! command -v starship &>/dev/null; then
    info "Instalando Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
    success "Starship instalado"
else
    success "Starship já instalado"
fi

mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'STARSHIP'
format = """
[](fg:#89b4fa)\
[ $os ](bg:#89b4fa fg:#1e1e2e bold)\
[](fg:#89b4fa bg:#313244)\
[ $directory ](bg:#313244 fg:#cdd6f4 bold)\
[](fg:#313244 bg:#1e1e2e)\
$git_branch$git_status$cmd_duration\
$fill\
$python$rust$nodejs\
[ $time ](fg:#585b70)\

[❯](bold fg:#89b4fa) """

[fill]
symbol = " "

[os]
disabled = false
style = "bg:#89b4fa fg:#1e1e2e"

[os.symbols]
Ubuntu = ""

[directory]
style             = "bg:#313244 fg:#89b4fa bold"
truncation_length = 3
truncate_to_repo  = true
read_only         = " 󰌾"

[git_branch]
symbol = " "
style  = "fg:#89b4fa"
format = '[ $symbol$branch ]($style)'

[git_status]
style  = "fg:#f38ba8"
format = '[$all_status$ahead_behind ]($style)'

[cmd_duration]
min_time = 2000
style    = "fg:#f9e2af"
format   = '[ 󱑍 $duration ]($style)'

[time]
disabled    = false
style       = "fg:#585b70"
time_format = "%H:%M"

[character]
success_symbol = "[❯](bold fg:#a6e3a1)"
error_symbol   = "[❯](bold fg:#f38ba8)"
STARSHIP

# Adiciona ao .bashrc se ainda não tiver
if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    info "Starship adicionado ao .bashrc"
fi
success "Starship configurado"

# ── 8. Fastfetch + ASCII art ──────────────────────────────────────────────────
section "8/11 · Fastfetch + ASCII art"

mkdir -p "$HOME/.config/fastfetch"

python3 - << 'PYEOF'
import os

B  = "\033[38;2;137;180;250m"
C  = "\033[38;2;116;199;236m"
S  = "\033[38;2;137;220;235m"
DM = "\033[38;2;88;91;112m"
R  = "\033[0m"

art1 = [
    "⠀⠀⠀⠀⢀⢠⡴⡶⠒⠲⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⢀⣴⠗⠁⢀⢥⠀⠀⠤⢼⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⡼⣏⡠⠊⠀⠀⢆⠀⠀⠐⡟⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⡇⣼⠳⣄⢀⠔⠙⡈⠉⢩⣳⣾⢿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⢰⣧⣄⡸⠣⡀⠀⣥⠤⣼⣿⠃⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⢿⡛⠛⠿⣾⣯⣘⣦⣾⠇⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠈⢷⣄⠀⠀⠙⢿⣿⣿⣀⣠⣾⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠻⣷⣶⣴⠞⡽⠝⢾⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠈⠻⣿⣶⣷⣒⣻⣿⣿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⣠⣭⣿⣿⣿⣿⣿⣿⣿⣧⡿⢯⣒⢤⣀⡀⠀⠀⠀",
    "⠀⠀⠀⠀⣀⢔⣾⣿⣿⣇⣹⣿⡫⠧⢾⠿⢿⣾⡗⠻⡋⠉⠻⣷⣦⣄",
    "⠀⡠⡲⢿⢽⣏⢩⢛⣟⡿⣋⣡⠠⠄⠚⡎⠁⠈⠣⣐⣪⠶⡖⠉⠈⢿",
    "⠰⡿⡰⡱⠁⠠⢩⣟⣞⢩⢃⢸⠀⠀⣀⣰⠠⢐⡊⠙⣄⠀⢈⣆⠄⣺",
    "⣿⣰⡱⠉⢑⢇⣿⣾⣿⣾⣚⢺⠈⠁⠀⠀⣇⢀⣨⣽⣿⣿⣿⣬⣷⡿",
]

c1 = [C,C,C,B,B,C,B,C,B,B,C,B,C,B]
c2 = [S,C,C,B,C,B,C,B,C,DM]

art = (
    [f"{c1[i]}{l}{R}" for i,l in enumerate(art1)]
    + [""]
    + [
        "",
        f"  {DM}◈{B}━━━━━━━━━━━━━━━━━━━━━━━━━━{DM}◈  {R}",
        f"  {C}       Luiz  ·  Bezerra       {R}",
        f"  {DM}◈{B}━━━━━━━━━━━━━━━━━━━━━━━━━━{DM}◈  {R}",
        "",
    ]
)

home = os.path.expanduser("~")
ascii_path = os.path.join(home, ".config/fastfetch/ascii.txt")
with open(ascii_path, "w") as f:
    f.write("\n".join(art))

config_path = os.path.join(home, ".config/fastfetch/config.jsonc")
config = f'''\u007b
  "logo": \u007b
    "type": "file",
    "source": "{ascii_path}",
    "padding": \u007b "right": 3 \u007d
  \u007d,
  "display": \u007b
    "separator": "  →  ",
    "color": \u007b "keys": "34", "title": "36" \u007d
  \u007d,
  "modules": [
    \u007b "type": "title", "format": "\u007b6\u007d\u007b7\u007d\u007b8\u007d",
      "color": \u007b "user": "bold_blue", "host": "bold_cyan", "at": "blue" \u007d \u007d,
    "separator",
    \u007b "type": "os",       "key": "  󰕈 OS",      "keyColor": "blue" \u007d,
    \u007b "type": "kernel",   "key": "   Kernel",    "keyColor": "blue" \u007d,
    \u007b "type": "uptime",   "key": "  󰔛 Uptime",   "keyColor": "blue" \u007d,
    \u007b "type": "packages", "key": "  󰏖 Packages", "keyColor": "blue" \u007d,
    \u007b "type": "shell",    "key": "   Shell",     "keyColor": "blue" \u007d,
    \u007b "type": "de",       "key": "   DE",        "keyColor": "blue" \u007d,
    \u007b "type": "wm",       "key": "  󱂬 WM",        "keyColor": "blue" \u007d,
    \u007b "type": "terminal", "key": "   Terminal",  "keyColor": "blue" \u007d,
    \u007b "type": "cpu",      "key": "   CPU",       "keyColor": "blue" \u007d,
    \u007b "type": "gpu",      "key": "  󰍛 GPU",       "keyColor": "blue" \u007d,
    \u007b "type": "memory",   "key": "   RAM",       "keyColor": "blue" \u007d,
    \u007b "type": "disk",     "key": "  󰋊 Disk",      "keyColor": "blue", "folders": "/" \u007d,
    "separator",
    \u007b "type": "colors", "paddingLeft": 2, "symbol": "circle" \u007d
  ]
\u007d'''

with open(config_path, "w") as f:
    f.write(config)

print("  ✓  Fastfetch configurado")
PYEOF

# Adiciona fastfetch + clear override ao .bashrc
if ! grep -q 'fastfetch' "$HOME/.bashrc"; then
    echo 'fastfetch' >> "$HOME/.bashrc"
    info "Fastfetch adicionado ao .bashrc"
fi
if ! grep -q 'clear()' "$HOME/.bashrc"; then
    echo 'clear() { command clear; fastfetch; }' >> "$HOME/.bashrc"
fi

# Adiciona fastfetch + clear override ao .zshrc
touch "$HOME/.zshrc"
if ! grep -q 'fastfetch' "$HOME/.zshrc"; then
    echo 'fastfetch' >> "$HOME/.zshrc"
    info "Fastfetch adicionado ao .zshrc"
fi
if ! grep -q 'clear()' "$HOME/.zshrc"; then
    echo 'clear() { command clear; fastfetch; }' >> "$HOME/.zshrc"
fi

success "Fastfetch configurado"

# ── 9. Plymouth ───────────────────────────────────────────────────────────────
section "9/11 · Plymouth (tela de boot)"

sudo apt-get install -y plymouth plymouth-themes > /dev/null 2>&1

PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes"
PLYMOUTH_THEME_NAME="catppuccin-mocha"

_install_plymouth_fallback() {
    local d="$PLYMOUTH_THEME_DIR/$PLYMOUTH_THEME_NAME"
    sudo mkdir -p "$d"
    sudo tee "$d/$PLYMOUTH_THEME_NAME.plymouth" > /dev/null << 'EOF'
[Plymouth Theme]
Name=Catppuccin Mocha
Description=Catppuccin Mocha Blue Dark
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/catppuccin-mocha
ScriptFile=/usr/share/plymouth/themes/catppuccin-mocha/catppuccin-mocha.script
EOF
    sudo tee "$d/$PLYMOUTH_THEME_NAME.script" > /dev/null << 'EOF'
Window.SetBackgroundTopColor(0.118, 0.118, 0.180);
Window.SetBackgroundBottomColor(0.098, 0.098, 0.149);
logo_image = Image.Text("Ubuntu", 0.537, 0.706, 0.980);
logo_sprite = Sprite(logo_image);
logo_sprite.SetPosition(
    Window.GetWidth()  / 2 - logo_image.GetWidth()  / 2,
    Window.GetHeight() / 2 - logo_image.GetHeight() / 2 - 40, 10);
spinner_frame = 0;
fun refresh_cb() {
    spinner_frame = (spinner_frame + 0.05) % (2 * Math.Pi);
    for (i = 0; i < 12; i++) {
        angle = spinner_frame + (2 * Math.Pi / 12) * i;
        alpha = (i + 1) / 12 * 0.8;
        dot = Image.Text("●", 0.537 * alpha, 0.706 * alpha, 0.980 * alpha);
        s = Sprite(dot);
        s.SetPosition(
            Window.GetWidth()  / 2 + Math.Cos(angle) * 40,
            Window.GetHeight() / 2 + Math.Sin(angle) * 40 + 30, 10);
    }
}
Plymouth.SetRefreshFunction(refresh_cb);
EOF
}

if [ ! -d "$PLYMOUTH_THEME_DIR/$PLYMOUTH_THEME_NAME" ]; then
    info "Baixando tema Plymouth..."
    cd /tmp
    if curl -sfL "https://github.com/catppuccin/plymouth/releases/latest/download/catppuccin-mocha.tar.gz" \
            -o catppuccin-plymouth.tar.gz 2>/dev/null; then
        sudo tar -xzf catppuccin-plymouth.tar.gz -C "$PLYMOUTH_THEME_DIR/" 2>/dev/null || \
            _install_plymouth_fallback
        rm -f catppuccin-plymouth.tar.gz
    else
        _install_plymouth_fallback
    fi
fi

sudo plymouth-set-default-theme -R "$PLYMOUTH_THEME_NAME" 2>/dev/null || \
    sudo update-initramfs -u 2>/dev/null || catch "Plymouth initramfs"

if ! grep -q 'quiet splash' /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' \
        /etc/default/grub
fi
success "Plymouth configurado"

# ── 10. GRUB Theme ────────────────────────────────────────────────────────────
section "10/11 · GRUB Theme Catppuccin"

GRUB_THEME_DIR="/boot/grub/themes"
GRUB_THEME_NAME="catppuccin-mocha-grub-theme"

if [ -d "$GRUB_THEME_DIR/$GRUB_THEME_NAME" ]; then
    success "GRUB theme já instalado"
else
    info "Baixando GRUB theme Catppuccin..."
    cd /tmp
    if git clone --depth=1 -q https://github.com/catppuccin/grub.git catppuccin-grub 2>/dev/null; then
        sudo mkdir -p "$GRUB_THEME_DIR"
        sudo cp -r catppuccin-grub/src/"$GRUB_THEME_NAME" "$GRUB_THEME_DIR/"
        rm -rf catppuccin-grub
        success "GRUB theme copiado"
    else
        catch "Download GRUB theme"
    fi
fi

if [ -d "$GRUB_THEME_DIR/$GRUB_THEME_NAME" ]; then
    GRUB_THEME_PATH="$GRUB_THEME_DIR/$GRUB_THEME_NAME/theme.txt"
    if grep -q "^#\?GRUB_THEME=" /etc/default/grub; then
        sudo sed -i "s|^#\?GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_PATH\"|" /etc/default/grub
    else
        echo "GRUB_THEME=\"$GRUB_THEME_PATH\"" | sudo tee -a /etc/default/grub > /dev/null
    fi
    sudo update-grub 2>/dev/null || catch "update-grub"
    success "GRUB theme Catppuccin ativado"
fi

# ── 11. GDM Login Screen ──────────────────────────────────────────────────────
section "11/11 · GDM Login Screen (Catppuccin)"

# Gera background SVG com gradiente Catppuccin
python3 - << 'PYEOF'
svg = """\
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">
  <defs>
    <radialGradient id="rg" cx="30%" cy="30%" r="80%">
      <stop offset="0%"   stop-color="#24273a"/>
      <stop offset="100%" stop-color="#1e1e2e"/>
    </radialGradient>
  </defs>
  <rect width="1920" height="1080" fill="url(#rg)"/>
  <circle cx="300"  cy="250"  r="380" fill="#89b4fa" opacity="0.04"/>
  <circle cx="1650" cy="850"  r="420" fill="#74c7ec" opacity="0.04"/>
  <circle cx="960"  cy="980"  r="220" fill="#cba6f7" opacity="0.025"/>
</svg>"""
with open("/tmp/catppuccin-gdm-bg.svg", "w") as f:
    f.write(svg)
print("  ✓  Background SVG gerado")
PYEOF

sudo mkdir -p /usr/share/backgrounds/catppuccin
sudo cp /tmp/catppuccin-gdm-bg.svg /usr/share/backgrounds/catppuccin/mocha-dark.svg

# Configura GDM via dconf (background + cursor + fonte)
sudo mkdir -p /etc/dconf/db/gdm.d /etc/dconf/profile

if [ ! -f /etc/dconf/profile/gdm ]; then
    sudo tee /etc/dconf/profile/gdm > /dev/null << 'EOF'
user-db:user
system-db:gdm
EOF
fi

sudo tee /etc/dconf/db/gdm.d/01-catppuccin-mocha > /dev/null << 'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/catppuccin/mocha-dark.svg'
picture-uri-dark='file:///usr/share/backgrounds/catppuccin/mocha-dark.svg'
primary-color='#1e1e2e'
color-shading-type='solid'
picture-options='zoom'

[org/gnome/desktop/interface]
cursor-theme='catppuccin-mocha-dark-cursors'
font-name='JetBrainsMono Nerd Font 11'
color-scheme='prefer-dark'
EOF

sudo dconf update 2>/dev/null || catch "GDM dconf update"
success "GDM background e cursor configurados"

# Patch CSS no gresource do gnome-shell (diálogo de login)
info "Aplicando CSS Catppuccin no diálogo de login..."
GRES="/usr/share/gnome-shell/gnome-shell-theme.gresource"
WORKDIR="/tmp/gdm-catppuccin-theme"
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR/theme"

PREFIX=$(gresource list "$GRES" 2>/dev/null | head -1 | sed 's|/[^/]*$||')

if [ -n "$PREFIX" ]; then
    cd "$WORKDIR"

    # Extrai todos os recursos
    for res in $(gresource list "$GRES" 2>/dev/null); do
        fname="theme/${res#${PREFIX}/}"
        mkdir -p "$(dirname "$fname")"
        gresource extract "$GRES" "$res" > "$fname" 2>/dev/null || true
    done

    CSS_FILE="$WORKDIR/theme/gnome-shell.css"
    if [ -f "$CSS_FILE" ]; then
        cat > /tmp/catppuccin-gdm-patch.css << 'CSS'
/* === Catppuccin Mocha — GDM Login Dialog === */
#lockDialogGroup {
  background-color: transparent;
}
.login-dialog {
  background-color: rgba(30, 30, 46, 0.92);
  border-radius: 16px;
  border: 1px solid rgba(137, 180, 250, 0.20);
  color: #cdd6f4;
}
.login-dialog StLabel.prompt-label,
.login-dialog StLabel { color: #cdd6f4; }
.login-dialog StEntry,
.login-dialog StPasswordEntry {
  background-color: #313244;
  color: #cdd6f4;
  border: 1px solid rgba(137, 180, 250, 0.40);
  border-radius: 8px;
}
.login-dialog .login-button,
.login-dialog StButton {
  background-color: #89b4fa;
  color: #1e1e2e;
  border-radius: 8px;
  font-weight: bold;
}
.login-dialog .login-button:hover,
.login-dialog StButton:hover { background-color: #74c7ec; }
/* === end Catppuccin === */
CSS
        cat /tmp/catppuccin-gdm-patch.css "$CSS_FILE" > /tmp/gnome-shell-patched.css
        mv /tmp/gnome-shell-patched.css "$CSS_FILE"

        # Gera XML do gresource
        {
            echo '<?xml version="1.0" encoding="UTF-8"?>'
            echo '<gresources>'
            echo "  <gresource prefix=\"$PREFIX\">"
            find "$WORKDIR/theme" -type f | sort | while read -r f; do
                echo "    <file>${f#$WORKDIR/theme/}</file>"
            done
            echo '  </gresource>'
            echo '</gresources>'
        } > "$WORKDIR/theme.gresource.xml"

        if glib-compile-resources \
                --sourcedir="$WORKDIR/theme" \
                "$WORKDIR/theme.gresource.xml" \
                --target="$WORKDIR/gnome-shell-theme.gresource" 2>/dev/null; then
            sudo cp "$GRES" "${GRES}.bak"
            sudo cp "$WORKDIR/gnome-shell-theme.gresource" "$GRES"
            success "CSS do diálogo de login aplicado"
        else
            warn "Compilação gresource falhou — background ainda foi aplicado"
            catch "GDM CSS gresource"
        fi
    else
        catch "GDM CSS: gnome-shell.css não encontrado"
    fi
else
    catch "GDM gresource não encontrado"
fi

# ── Aplicar temas via gsettings ───────────────────────────────────────────────
section "Aplicando temas via gsettings"

gsettings set org.gnome.desktop.interface gtk-theme        "catppuccin-mocha-sapphire-standard+default" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme       "Papirus-Dark"                               2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme     "catppuccin-mocha-dark-cursors"              2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name        "JetBrainsMono Nerd Font 11"                 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font Mono 11"         2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme     "prefer-dark"                                2>/dev/null || true

success "Temas aplicados"

# ── Resumo ────────────────────────────────────────────────────────────────────
echo -e "
${BL}  ╔══════════════════════════════════════╗
  ║          Rice instalado!             ║
  ╚══════════════════════════════════════╝${R}

${GR}  ✓${R}  JetBrainsMono Nerd Font
${GR}  ✓${R}  GTK Theme: Catppuccin Mocha Sapphire
${GR}  ✓${R}  Ícones: Papirus-Dark
${GR}  ✓${R}  Cursor: Catppuccin Mocha Dark
${GR}  ✓${R}  Kitty configurado
${GR}  ✓${R}  Starship prompt
${GR}  ✓${R}  Fastfetch + ASCII art
${GR}  ✓${R}  clear → volta ao fastfetch
${GR}  ✓${R}  Plymouth boot theme
${GR}  ✓${R}  GRUB theme Catppuccin
${GR}  ✓${R}  GDM login screen Catppuccin
"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RD}  Itens que falharam (verifique manualmente):${R}"
    for e in "${ERRORS[@]}"; do
        echo -e "  ${DM}•${R} $e"
    done
    echo ""
fi

echo -e "${DM}  Extensões GNOME recomendadas (instale via Extension Manager):${R}"
echo -e "  ${BL}•${R} User Themes"
echo -e "  ${BL}•${R} Blur my Shell"
echo -e "  ${BL}•${R} Rounded Window Corners Reborn"
echo -e "  ${BL}•${R} Just Perfection"
echo ""
echo -e "${DM}  Reinicie a sessão (logout/login) para aplicar tudo.${R}"
echo ""
