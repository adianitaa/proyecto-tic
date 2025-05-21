#!/bin/bash

echo "Iniciando benchmark dentro del contenedor Docker..."

# CPU benchmark con sysbench
cpu_result=$(sysbench cpu --cpu-max-prime=20000 run | grep "events per second" | awk '{print $4}')

# Escritura en disco (medida rápida con dd)
write_speed=$(dd if=/dev/zero of=tempfile bs=1M count=100 conv=fdatasync 2>&1 | grep "copied" | awk '{print $(NF-1), $NF}')

rm tempfile

# Memoria usada
mem_used=$(free -h | grep Mem | awk '{print $3 " / " $2}')

# Estado MySQL
if systemctl is-active mysql >/dev/null 2>&1; then
    mysql_status="active"
else
    mysql_status="inactive"
fi

echo
# Pedir ruta para guardar el resumen (dentro del contenedor en carpeta montada)
read -p "Ingresa la ruta dentro del contenedor donde quieres guardar el resumen (ejemplo: . para la carpeta actual): " save_path

# Componer ruta completa para el archivo resumen
summary_file="${save_path}/benchmark_summary.txt"

echo "Guardando resumen en $summary_file ..."

echo "====== RESUMEN DE BENCHMARK - DOCKER CONTAINER ======" > "$summary_file"
echo "🔸 CPU (sysbench): $cpu_result events/sec" >> "$summary_file"
echo "🔸 Escritura en disco: $write_speed" >> "$summary_file"
echo "🔸 Velocidad de red local (iperf3): No disponible" >> "$summary_file"
echo "🔸 Memoria usada: $mem_used" >> "$summary_file"
echo "🔸 MySQL está corriendo: $mysql_status" >> "$summary_file"
echo "==============================================" >> "$summary_file"

echo "Resumen guardado exitosamente."