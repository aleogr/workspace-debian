#!/bin/bash

# --- Multi-Security Key Registration for Debian 13 ---
# This script aligns with your Ansible Security Role.
# Works with YubiKey, Google Titan, SoloKeys, and other U2F/FIDO2 tokens.

# 1. Root Check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)."
  exit 1
fi

# 2. Get the main user from vars.yml
MAIN_USER=$(grep 'main_user:' vars.yml | awk '{print $2}' | tr -d '"')
AUTH_FINAL_FILE="/etc/security-keys/u2f_mappings"

# 3. Prerequisites
apt install libpam-u2f -y -qq 
mkdir -p /etc/security-keys

echo "------------------------------------------------------------"
echo "🔐 REGISTERING SECURITY KEYS FOR: $MAIN_USER"
echo "------------------------------------------------------------"

key_count=0
register_more="S"
TEMP_KEYS=""

while [[ "$register_more" =~ ^[Ss]$ ]]; do
    key_count=$((key_count + 1))
    
    echo -e "\n--- KEY $key_count: INSERT your security key now. ---"
    read -p "Press [Enter] when ready..."
    
    # Generate the handle
    # -n removes the username from output for manual concatenation
    CURRENT_KEY=$(pamu2fcfg -u "$MAIN_USER" -n)
    
    if [ $? -eq 0 ]; then
        if [ -z "$TEMP_KEYS" ]; then
            TEMP_KEYS="$CURRENT_KEY"
        else
            # Append subsequent keys with a colon (:) separator
            TEMP_KEYS="${TEMP_KEYS}:${CURRENT_KEY}"
        fi
        echo "✅ Key $key_count registered in memory."
    else
        echo "❌ Error capturing key. Let's try this one again."
        key_count=$((key_count - 1))
    fi

    echo -e "------------------------------------------------------------"
    read -p "Do you want to register another Security Key? (S/n): " register_more
done

# 4. Finalizing the file in the correct format: user:key1:key2...
if [ ! -z "$TEMP_KEYS" ]; then
    echo "${MAIN_USER}:${TEMP_KEYS}" > "$AUTH_FINAL_FILE"
    chmod 0644 "$AUTH_FINAL_FILE"
    chown root:root "$AUTH_FINAL_FILE"
    
    echo -e "\n🎉 DONE! $key_count keys registered for $MAIN_USER."
    echo "📍 File saved at: $AUTH_FINAL_FILE"
    echo "👉 Now run the Ansible playbook to apply the PAM rules."
else
    echo "⚠️ No keys were registered."
fi
