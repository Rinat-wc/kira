#!/bin/bash
set +e && source "/etc/profile" &>/dev/null && set -e
exec &> >(tee -a "$KIRA_DUMP/setup.log")

KIRA_SETUP_BASE_TOOLS="$KIRA_SETUP/base-tools-v0.1.8"
if [ ! -f "$KIRA_SETUP_BASE_TOOLS" ]; then
  echo "INFO: Update and Intall basic tools and dependencies..."
  apt-get update -y --fix-missing
  apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    hashdeep \
    nginx \
    python \
    python3 \
    python3-pip \
    software-properties-common \
    tar \
    zip \
    jq \
    php-cli \
    unzip \
    php7.4-gmp \
    php-mbstring \
    md5deep

  pip3 install ECPy

  cd /home/$SUDO_USER
  curl -sS https://getcomposer.org/installer -o composer-setup.php
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer

  HD_WALLET_DIR="/home/$SUDO_USER/hd-wallet-derive"
  HD_WALLET_PATH="$HD_WALLET_DIR/hd-wallet-derive.php"
  $KIRA_SCRIPTS/git-pull.sh "https://github.com/KiraCore/hd-wallet-derive.git" "master" "$HD_WALLET_DIR" 555
  FILE_HASH=$(CDHelper hash SHA256 -p="$HD_WALLET_DIR" -x=true -r=true --silent=true -i="$HD_WALLET_DIR/.git,$HD_WALLET_DIR/.gitignore,$HD_WALLET_DIR/tests")
  EXPECTED_HASH="078da5d02f80e96fae851db9d2891d626437378dd43d1d647658526b9c807fcd"

  if [ "$FILE_HASH" != "$EXPECTED_HASH" ]; then
    echo "DANGER: Failed to check integrity hash of the hd-wallet derivaiton tool !!!"
    echo -e "\nERROR: Expected hash: $EXPECTED_HASH, but got $FILE_HASH\n"
    read -p "Press any key to continue..." -n 1
    exit 1
  fi

  cd $HD_WALLET_DIR
  yes "yes" | composer install

  ls -l /bin/hd-wallet-derive || echo "WARNING: Wallet Derive Tool was not found"
  rm /bin/hd-wallet-derive || echo "WARNING: Failed to remove old Wallet Derive symlink"
  ln -s $HD_WALLET_PATH /bin/hd-wallet-derive || echo "WARNING: KIRA Manager symlink already exists"

  cd /home/$SUDO_USER
  TOOLS_DIR="/home/$SUDO_USER/tools"
  PRIV_KEYGEN_DIR="$TOOLS_DIR/priv-validator-key-gen"
  $KIRA_SCRIPTS/git-pull.sh "https://github.com/KiraCore/tools.git" "main" "$TOOLS_DIR" 555
  FILE_HASH=$(CDHelper hash SHA256 -p="$TOOLS_DIR" -x=true -r=true --silent=true -i="$TOOLS_DIR/.git,$TOOLS_DIR/.gitignore")
  EXPECTED_HASH="37fc48248aead8af6d6e03a1497657431bae310b5cd71d6e6f74f7d4e3cd3de7"

  if [ "$FILE_HASH" != "$EXPECTED_HASH" ]; then
    echo "DANGER: Failed to check integrity hash of the kira tools !!!"
    echo -e "\nERROR: Expected hash: $EXPECTED_HASH, but got $FILE_HASH\n"
    read -p "Press any key to continue..." -n 1
    exit 1
  fi

  # TODO: intall tools
  #cd $PRIV_KEYGEN_DIR
  #make install

  cd /home/$SUDO_USER
  touch $KIRA_SETUP_BASE_TOOLS
else
  echo "INFO: Base tools were already installed."
fi
