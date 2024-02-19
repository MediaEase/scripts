#!/usr/bin/bash
# @function zen::vault::init
# @internal
# @description Initializes the vault by setting up the salt and secret key.
# @global credentials_file Path to the credentials file.
# @note Creates a salt file if not present and sets up the credentials
# @note $vault_name is a global variable
zen::vault::init() {
    local salt hash
    declare salt_file="/root/.mediaease/config"
    declare vault_base_dir="/etc/.mediaease"

    if [[ -f "$salt_file" ]]; then
        salt=$(head -n 1 "$salt_file")
        printf "Salt found\n"
    else
        zen::vault::create
    fi

    # Hashing to determine vault path
    # vault_name is a global variable
    # shellcheck disable=SC2154 
    hash=$(echo -n "${vault_name}${salt}" | sha256sum | cut -d' ' -f1)
    local vault_dir="${vault_base_dir}/${hash:0:32}"
    local vault_file="${hash:32}.yaml"

    declare -g credentials_file="${vault_dir}/${vault_file}"

    if [[ -f "$credentials_file" ]]; then
        mflibs::status::info "$(zen::i18n::translate "vault.credentials_file_found")"
    else
        mflibs::status::error "$(zen::i18n::translate "vault.credentials_file_not_found")"
        return 1
    fi

    export credentials_file
}

# @function zen::vault::create
# @internal
# @description Creates the vault, including the generation and storage of the salt key.
# @global vault_name The name of the vault.
# @note The salt key is stored in a file and the vault is created in the /etc/.mediaease directory.
zen::vault::create() {
    local user_salt salt hash vault_dir vault_file
    declare salt_file="/root/.mediaease/config"
    declare vault_base_dir="/etc/.mediaease"

    read -r -sp "Enter your salt key: " user_salt
    echo

    # Encode user provided salt in base64 and store it
    salt=$(echo -n "$user_salt" | base64)
    echo "$salt" > "$salt_file"
    chmod 600 "$salt_file"
    chattr +i "$salt_file"
    mflibs::status::info "$(zen::i18n::translate "vault.salt_stored")"

    # Hashing to determine vault path
    hash=$(echo -n "${vault_name}${salt}" | sha256sum | cut -d' ' -f1)
    vault_dir="${vault_base_dir}/${hash:0:32}"
    vault_file="${hash:32}.yaml"

    # Create the vault directory and file
    mkdir -p "$vault_dir"
    chmod 700 "$vault_dir"
    declare -g credentials_file="${vault_dir}/${vault_file}"
    touch "$credentials_file"
    zen::vault::permissions "add"

    mflibs::status::success "$(zen::i18n::translate "vault.vault_created")"
}

# @function zen::vault::pass::encode
# @internal
# @description Encodes a given string using base64 encoding.
# @arg $1 string The string to be encoded.
# @return Encoded string in base64 format.
# @note Returns an error if no string is provided.
# @example zen::vault::pass::encode "password"
zen::vault::pass::encode() {
    local string="$1"
    if [[ -z "$string" ]]; then
        mflibs::status::error "$(zen::i18n::translate "vault.encode_no_string")"
        return 1
    fi
    echo -n "$string" | base64
}

# @function zen::vault::pass::decode
# @internal
# @description Finds and decodes the hashed password from the vault.
# @arg $1 string The key for the password entry.
# @return Decoded password if successful.
# @note Returns an error if the key is not found.
# @example zen::vault::pass::decode "username.type"
zen::vault::pass::decode() {
    local key="$1"
    local hashed_key
    hashed_key=$(zen::vault::pass::encode "$key")
    local hashed_password
    hashed_password=$(yq e ".$hashed_key" "$credentials_file")
    if [[ -n "$hashed_password" ]]; then
        echo -n "$hashed_password" | base64 --decode
    else
        return 1
    fi
}

# @function zen::vault::pass::store
# @internal
# @description Stores a new password in the vault.
# @arg $1 string The key for the password entry.
# @arg $2 string The password to store.
# @global credentials_file Path to the credentials file.
# @note Returns an error if the key already exists.
# @example zen::vault::pass::store "username.type" "password"
zen::vault::pass::store() {
    local key="$1"
    local password="$2"
    local username type hashed_password hashed_username
    username=$(echo "$key" | cut -d'.' -f1)
    type=$(echo "$key" | cut -d'.' -f2)
    hashed_type=$(zen::vault::pass::encode "$type")
    hashed_username=$(zen::vault::pass::encode "$username")
    hashed_password=$(zen::vault::pass::encode "$password")

    mflibs::status::info "$(zen::i18n::translate "vault.storing_password" "$username" "$type")"
    if yq e ".$hashed_username.$hashed_type" "$credentials_file" &>/dev/null; then
        mflibs::status::error "$(zen::i18n::translate "vault.key_exists")"
        return 1
    else
        zen::vault::permissions "remove"
        yq e -i ".\"$hashed_username\".\"$hashed_type\" = \"$hashed_password\"" "$credentials_file"
        zen::vault::permissions "add"
        mflibs::status::success "$(zen::i18n::translate "vault.store_success")"
    fi
}

# @function zen::vault::pass::update
# @internal
# @description Updates an existing password in the vault.
# @arg $1 string The key for the password entry.
# @arg $2 string The new password to update.
# @global credentials_file Path to the credentials file.
# @note Returns an error if the key is not found.
# @example zen::vault::pass::update "username.type" "password"
zen::vault::pass::update() {
    local key="$1"
    local password="$2"
    local hashed_key hashed_password
    zen::vault::init
    hashed_key=$(zen::vault::pass::encode "$key")
    hashed_password=$(zen::vault::pass::encode "$password")

    if yq e ".$hashed_key" "$credentials_file" &>/dev/null; then
        zen::vault::permissions "remove"
        yq e -i ".$hashed_key = \"$hashed_password\"" "$credentials_file"
        zen::vault::permissions "add"
    else
        mflibs::status::error "$(zen::i18n::translate "vault.key_not_found")"
        return 1
    fi
}

# @function zen::vault::permissions
# @internal
# @description Updates the permissions of the credentials file.
# @arg $1 string The action to be performed on the file.
# @note Adds or removes permissions based on the action provided.
# @example zen::vault::permissions "add"
# @example zen::vault::permissions "remove"
zen::vault::permissions(){
    local action="$1"
    
    if [[ "$action" == "add" ]]; then
        mflibs::status::info "$(zen::i18n::translate "vault.adding_permissions")"
        mflibs::log "chown -R root:root $credentials_file"
        mflibs::log "chmod -R 700 $credentials_file"
        mflibs::log "chattr +i $credentials_file"
    elif [[ "$action" == "remove" ]]; then
        mflibs::status::info "$(zen::i18n::translate "vault.removing_permissions")"
        mflibs::log "chattr -i $credentials_file"
        mflibs::log "chmod -R 755 $credentials_file"
        mflibs::log "chown -R root:root $credentials_file"
    else
        mflibs::status::error "$(zen::i18n::translate "vault.invalid_action" "$action")"
        return 1
    fi

    mflibs::status::success "$(zen::i18n::translate "vault.permissions_updated")"
}
