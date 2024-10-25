#!/bin/bash

# Définition des fichiers de log
log_file="/var/log/process_monitor.log"
monitor_log_file="/var/log/monitor.log"

# Création des fichiers de log si nécessaire
touch "$log_file" "$monitor_log_file"

# Surveillance de l'utilisation CPU
limite=80
user=$(whoami)

while true; do
    # Vérifier l'utilisation CPU et filtrer les processus
    cpu_limite=$(ps aux | awk -v limite="$limite" '$3 > limite {print $0}')

    if [[ -n "$cpu_limite" ]]; then
        # Traitement des processus avec utilisation CPU élevée
        echo "Anomalie détectée : CPU trop élevé" | tee -a "$log_file"
        echo "$cpu_limite" | while read -r line; do
            pid=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | awk '{print $11}')
            cpu=$(echo "$line" | awk '{print $3}')
            echo "Processus: $pid"
            echo "Nom: $name"
            echo "CPU: $cpu%" | tee -a "$log_file"

            echo "Quel action souhaitez vous faire ?" | tee -a "$log_file"
            echo "1. Terminer le processus"
            echo "2. Baisser la priorité"
            echo "3. Ignorer"

            read action < /dev/tty

            case $action in
                1)
                    kill "$pid"
                    echo "Processus $pid terminé." | tee -a "$log_file"
                    ;;
                2)
                    renice 10 "$pid"
                    echo "Priorité du processus $pid abaissée." | tee -a "$log_file"
                    ;;
                3)
                    echo "Ignorer le processus $pid." | tee -a "$log_file"
                    ;;
                *)
                    echo "Action invalide. Veuillez entrer 1, 2 ou 3." | tee -a "$log_file"
                    ;;
            esac
        done
    fi

    sleep 5  # Attendre avant la prochaine vérification
done
