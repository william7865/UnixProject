#!/bin/bash

log_file="/var/log/process_suspects.log"

# Vérifier et créer le fichier de log si nécessaire
if [ ! -f "$log_file" ]; then
    touch "$log_file"
fi
#-b et -n 1 pour windows ou linux et pour  macOS -l 1.

# Vérification de l'utilisation excessive du CPU
top -l 1 | awk 'NR>7 && $9 > 80 {print $1, $2, $9}' | while read -r pid name cpu; do
    echo "Anomalie détectée : CPU trop élevé" | tee -a "$log_file"
    echo "Processus: $pid" | tee -a "$log_file"
    echo "Nom: $name" | tee -a "$log_file"
    echo "CPU: $cpu%" | tee -a "$log_file"
    echo "Quelle action souhaitez-vous faire ?" | tee -a "$log_file"
    echo "1. Tuer le processus"
    echo "2. Baisser la priorité"
    echo "3. Ignorer"
    
    read -p "Entrez votre choix (1-3) : " action < /dev/tty

    if [ "$action" -eq 1 ]; then
        kill "$pid"
        echo "Processus tué" | tee -a "$log_file"
    elif [ "$action" -eq 2 ]; then
        renice 19 "$pid"
        echo "Priorité baissée" | tee -a "$log_file"
    fi
done

# Vérification d'utilisation excessive de la mémoire
top -l 1 | awk 'NR>7 && $10 > 80 {print $1, $2, $10}' | while read -r pid name mem; do
    echo "Anomalie détectée : Utilisation excessive de la mémoire" | tee -a "$log_file"
    echo "Processus: $pid" | tee -a "$log_file"
    echo "Nom: $name" | tee -a "$log_file"
    echo "Mémoire: $mem%" | tee -a "$log_file"
    echo "Quelle action souhaitez-vous faire ?" | tee -a "$log_file"
    echo "1. Tuer le processus"
    echo "2. Baisser la priorité"
    echo "3. Ignorer"
    
    read -p "Entrez votre choix (1-3) : " action < /dev/tty

    if [ "$action" -eq 1 ]; then
        kill -9 "$pid"
        echo "Processus tué" | tee -a "$log_file"
    elif [ "$action" -eq 2 ]; then
        renice 19 "$pid"
        echo "Priorité baissée" | tee -a "$log_file"
    fi
done
