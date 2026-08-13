#!/bin/bash
# Thêm GPG key
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | \
sudo gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg

# Thêm repository
echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | \
sudo tee /etc/apt/sources.list.d/dbeaver.list

# Cập nhật package
sudo apt update

# Cài DBeaver Community
sudo apt install dbeaver-ce
