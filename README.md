# autoSSL_renewal_Proxmox
The script is used to automatically renew the SSL certificate (LE) for a domain assigned to Proxmox. \
Automatic execution of the script can be set as a cron job: \
0 9 * * * root ./renewal.sh -d DOMENA
