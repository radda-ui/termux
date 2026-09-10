#!/bin/zsh

# --- Phase 1: Environment Preparation ---
echo "Setting up storage (please grant permission in the dialog)..."
termux-setup-storage
read -p "Press enter after granting permissions..."

echo "Updating packages..."
apt update -y && apt upgrade -y

# --- Phase 2: Package Installation ---
echo "Installing packages..."
apt install -y bat busybox coreutils curl file git lsd openssh termux-api termux-services termux-tools wget zsh lf

# --- Phase 3: Configuration & Customization ---
echo "Setting up dotfiles..."
mkdir -p ~/temp_config
git clone https://github.com/radda-ui/termux ~/temp_config

# Backup
BACKUP_DIR=~/backup_$(date +%Y%m%d)
mkdir -p $BACKUP_DIR
[ -f ~/.zshrc ] && mv ~/.zshrc $BACKUP_DIR/
[ -f ~/.p10k.zsh ] && mv ~/.p10k.zsh $BACKUP_DIR/
[ -d ~/.termux ] && mv ~/.termux $BACKUP_DIR/

# Copy new
cp -r ~/temp_config/.zshrc ~/.zshrc
cp -r ~/temp_config/.p10k.zsh ~/.p10k.zsh
cp -r ~/temp_config/.termux ~/.termux
rm -rf ~/temp_config

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "Setting zsh as default shell..."
chsh -s zsh

echo "Installing style..."
mkdir -p ~/temp_style
git clone https://github.com/adi1090x/termux-style ~/temp_style
cd ~/temp_style && ./install
cd ~
rm -rf ~/temp_style

# --- Phase 4: System Services & ADB ---
echo "Setting up boot services..."
mkdir -p ~/.termux/boot
cat <<EOF > ~/.termux/boot/start-services.sh
#!/bin/zsh
termux-wake-lock
sshd
EOF
chmod +x ~/.termux/boot/start-services.sh

read -p "Setup ADB over WiFi? (y/n): " setup_adb
if [[ "$setup_adb" == "y" ]]; then
    read -p "Enter port: " adb_port
    termux-adb-wifi $adb_port
fi

echo "Setup complete."
source ~/.zshrc
