#!/bin/bash

generate_password() {
    local password_length=12
    local password=$(openssl rand -base64 48 | cut -c1-$password_length)
    echo "$password"
}

create_user() {
    local username=$1
    local password=$2
    if id "$username" &>/dev/null; then
        echo "User $username already exists!"
        exit 1
    fi
    sudo useradd -m "$username"
    echo "$username:$password" | sudo chpasswd
}

group_exists() {
    getent group "$1" &>/dev/null
    return $?
}

if ! group_exists "tuf"; then
    sudo groupadd tuf
    echo "Group 'tuf' created."
fi

read -p "Enter the username: " username
password=$(generate_password)

while true; do
    read -p "Enter the group for $username: " groupname
    
    if group_exists "$groupname"; then
        echo "Group $groupname exists."
        break
    else
        echo "Group $groupname does not exist. Please try again."
    fi
done

create_user "$username" "$password"
sudo chown :tuf /path/to/your/file
sudo chmod g+rw /path/to/your/file

echo "User $username will be associated with group $groupname and will have read and write permissions to the file."
