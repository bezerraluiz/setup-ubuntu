#!/bin/bash

set -e

# =========================================================
# CORES PARA OUTPUT
# =========================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# =========================================================
# HELPERS
# =========================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

echo "🚀 Iniciando configuração do ambiente de desenvolvimento..."
echo ""

# =========================================================
# 1 — ATUALIZAÇÃO DO SISTEMA
# =========================================================

print_status "Atualizando sistema..."

sudo apt update
sudo apt upgrade -y

print_success "Sistema atualizado"

# =========================================================
# 2 — DEPENDÊNCIAS BASE
# =========================================================

print_status "Instalando dependências básicas..."

sudo apt install -y \
curl \
git \
ca-certificates \
gnupg \
lsb-release

print_success "Dependências instaladas"

# =========================================================
# 3 — CONFIGURAÇÃO DO GIT
# =========================================================

print_status "Configurando Git"

read -p "Nome Git: " git_username
read -p "Email Git: " git_email

if [ -n "$git_username" ] && [ -n "$git_email" ]; then
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"

    print_success "Git configurado"
else
    print_warning "Git não configurado"
fi

# =========================================================
# 4 — ZSH + OH MY ZSH
# =========================================================

print_status "Instalando ZSH..."

if ! command_exists zsh; then
    sudo apt install -y zsh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Instalando Oh My Zsh"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

print_success "ZSH pronto"

# =========================================================
# 5 — PLUGINS ZSH
# =========================================================

print_status "Instalando plugins ZSH..."

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions \
$ZSH_CUSTOM/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
$ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true

git clone https://github.com/zsh-users/zsh-completions \
$ZSH_CUSTOM/plugins/zsh-completions || true

git clone https://github.com/zsh-users/zsh-history-substring-search \
$ZSH_CUSTOM/plugins/zsh-history-substring-search || true

sudo apt install -y autojump

# atualizar plugins no zshrc
if [ -f "$HOME/.zshrc" ]; then

cp "$HOME/.zshrc" "$HOME/.zshrc.bak"

sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-completions autojump zsh-history-substring-search zsh-syntax-highlighting)/' "$HOME/.zshrc"

fi

print_success "Plugins configurados"

# =========================================================
# 6 — DOCKER
# =========================================================

print_status "Instalando Docker..."

if ! command_exists docker; then

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

print_success "Docker instalado"

else

print_success "Docker já instalado"

fi

# =========================================================
# 7 — NODE.JS LTS
# =========================================================

print_status "Instalando Node.js LTS..."

if ! command_exists node; then

curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -

sudo apt install -y nodejs

print_success "Node.js LTS instalado"

else

print_success "Node já instalado"

fi

# =========================================================
# 8 — DIODON
# =========================================================

print_status "Instalando Diodon..."

if ! package_installed diodon; then
sudo apt install -y diodon
fi

print_success "Diodon instalado"

# =========================================================
# 9 — CUSTOMIZAÇÃO DO GNOME TERMINAL
# =========================================================

print_status "Configurando tema do GNOME Terminal..."

if command_exists gsettings && command_exists dconf; then

PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
BASE="/org/gnome/terminal/legacy/profiles:/:$PROFILE/"

dconf write ${BASE}use-theme-colors false
dconf write ${BASE}background-color "'#1e1e2e'"
dconf write ${BASE}foreground-color "'#cdd6f4'"

dconf write ${BASE}palette "[
'#45475a',
'#f38ba8',
'#a6e3a1',
'#f9e2af',
'#89b4fa',
'#f5c2e7',
'#94e2d5',
'#bac2de',
'#585b70',
'#f38ba8',
'#a6e3a1',
'#f9e2af',
'#89b4fa',
'#f5c2e7',
'#94e2d5',
'#a6adc8'
]"

print_success "Tema do terminal configurado!"

else

print_warning "GNOME Terminal não detectado. Tema não aplicado."

fi

# =========================================================
# FINALIZAÇÃO
# =========================================================

echo ""
echo "Ambiente configurado."

echo ""
echo "Versões instaladas:"

git --version
node --version
npm --version
docker --version
zsh --version
