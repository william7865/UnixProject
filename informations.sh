#!/bin/bash
user=$(whoami)
log_fichier="/var/log/process_monitor.log"
limite=80
utilisateurs_habituels=("root" "$user")

while true; do
    echo -e "\nDate: $(date)" > "$log_fichier"
    echo -e "PID\tUSER\t%CPU\t%MEM\tSTATE" >> "$log_fichier"
    ps aux | grep -w "$user" | awk '{print $2 "\t" $1 "\t" $3 "\t" $4 "\t" $8}' | head -n 6 >> "$log_fichier"
    
    cpu_limite=$(ps aux | awk -v limite="$limite" '$3 > limite {print $0}')
    
    if [ -n "$cpu_limite" ]; then
        echo "Alerte : Utilisation du CPU supérieure à ${limite}% !" >> "$log_fichier"
    fi

    non_habituels=$(ps aux | awk -v user="$user" -v root="root" '$1 != user && $1 != root {print $0}')
    
    if [ -n "$non_habituels" ]; then
        echo "$non_habituels" | head -n 6 | while read -r line; do
            utilisateur=$(echo "$line" | awk '{print $1}')
            echo "Processus exécuté par un utilisateur non habituel : ${utilisateur}" >> "$log_fichier"
        done
    fi

    zombies=$(ps aux | awk '$8 == "Z" {print $0}')
    if [ -n "$zombies" ]; then
        echo "$zombies" | head -n 2 | while read -r line; do
            echo "Processus zombie detecter  : $line" >> "$log_fichier"
        done
    fi

    caches=$(ps aux | awk '$3 == 0 && $8 != "Z" {print $0}') 
    if [ -n "$caches" ]; then
        echo "$caches" | head -n 2 | while read -r line; do
            echo "Processus caché : $line" >> "$log_fichier"
        done
    fi
    
    sleep 5
done