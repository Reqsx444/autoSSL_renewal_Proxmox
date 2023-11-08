#!/bin/bash
#Author: Damian Golał

#Obsługa flagi -d
while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done

#Weryfikacja czy ważność certyfikatu dla domeny jest minimum 5 dniowa
certbot certificates -d $domain |grep -E 'VALID: 1 days|VALID: 2 days|VALID: 3 days|VALID: 4 days|VALID: 5 days|VALID: 6 days|VALID: 7 days'

#Jeśli powyższe polecenie ma exit_code=0 to wykonaj odnowienie, jeśli nie to zamknij skrypt
if [ $? -eq 0 ]
then
# Generowanie certyfikatu
  certbot certonly --standalone -d $domain --non-interactive --agree-tos --email alarmy@infracore.pl --force-renewal
#Przenoszenie certyfikatu
  cp /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/pve/nodes/node-01/pveproxy-ssl.pem
  cp /etc/letsencrypt/live/"$domain"/privkey.pem /etc/pve/nodes/node-01/pveproxy-ssl.key
#Przeładowanie pveproxy
  systemctl restart pveproxy

#Logowanie zdarzenia - sukces
  echo "[$(date)] SSL Certificate for ${domain} properly renewed." >> /var/log/renewal_script
  exit 0
else
  echo "Certificate not yet due for renewal; no action taken."

#Logowanie zdarzenia - pominięcie
  echo "[$(date)] Certificate for ${domain} not yet due for renewal." >> /var/log/renewal_script
  exit 1
fi
