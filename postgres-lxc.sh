#!/usr/bin/env bash
# PostgreSQL LXC Setup for Proxmox VE 8.3
# Maintainer: Kevin (updated with GPT-5 assistance)
# Based on tteck community-scripts

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="PostgreSQL"
var_tags="${var_tags:-database}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"   # Debian 12 for PVE 8.x
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info "$APP"
    check_container_storage
    check_container_resources

    if [[ ! -f /etc/apt/sources.list.d/pgdg.list ]]; then
        msg_error "No ${APP} installation found inside this LXC!"
        exit 1
    fi

    msg_info "Updating ${APP} Container"
    $STD apt update
    $STD apt -y upgrade
    msg_ok "Updated successfully!"
    exit 0
}

start
build_container
description

msg_info "Installing Dependencies"
$STD apt update
$STD apt install -y wget gnupg lsb-release
msg_ok "Dependencies installed"

msg_info "Adding PostgreSQL Repository"
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/pgdg.gpg

echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list

$STD apt update
msg_ok "Repository added"

msg_info "Installing PostgreSQL Server"
$STD apt install -y postgresql postgresql-contrib
msg_ok "PostgreSQL installed"

msg_ok "Completed Successfully!"
echo -e "${CREATING}${GN}${APP} has been successfully initialized!${CL}"
echo -e "${INFO}${YW}PostgreSQL is available at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}${IP}:5432${CL}"
