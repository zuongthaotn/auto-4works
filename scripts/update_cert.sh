#!/bin/bash
#
sudo cp fortinet_ca_ssl.cer /usr/local/share/ca-certificates/fortinet_ca_ssl.crt
#
sudo update-ca-certificates
