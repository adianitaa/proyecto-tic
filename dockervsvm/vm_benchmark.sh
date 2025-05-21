#!/bin/bash

echo "🚀 Iniciando benchmark en VM Ubuntu..."

# Actualizar sistema e instalar herramientas necesarias
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip sysbench htop curl git iperf3 mysql-server

# Instalar librerías Python necesarias
pip3 install --upgrade pip
pip3 install jupyter matplotlib psutil

echo "✅ Instalación completa."

# Ejecutar benchmark CPU con sysbench
echo "⏳ Ejecutando benchmark CPU..."
sysbench cpu --cpu-max-prime=20000 run > cpu_results.txt

# Ejecutar prueba de escritura en disco con dd
echo "⏳ Ejecutando prueba de escritura en disco..."
dd if=/dev/zero of=testfile bs=1G count=1 oflag=dsync &> disk_results.txt
rm -f testfile

# Ejecutar prueba de velocidad de red (iperf3 cliente y servidor, necesitas otro equipo o VM para server)
echo "⏳ Ejecutando prueba de red (iperf3)..."
# Inicia servidor iperf3 en background en otra terminal o equipo: iperf3 -s
# Aquí solo hacemos cliente hacia localhost para ejemplo (puedes cambiar IP)
iperf3 -c 127.0.0.1 -t 5 > network_results.txt 2>&1

# Obtener uso de memoria
echo "⏳ Capturando uso de memoria..."
free -h > memory_results.txt

# Verificar estado de MySQL
MYSQL_STATUS=$(sudo systemctl is-active mysql)

# Generar resumen
echo "📋 Generando resumen de resultados..."

echo "====== RESUMEN DE BENCHMARK - VM UBUNTU ======" > benchmark_summary.txt

# CPU resumen
CPU_EVENTS=$(grep "events per second:" cpu_results.txt | awk '{print $4}')
echo "🔸 CPU (sysbench): ${CPU_EVENTS:-No disponible} events/sec" >> benchmark_summary.txt

# DISCO resumen
DISK_SPEED=$(grep -Eo '[0-9]+(\.[0-9]+)? [MG]B/s' disk_results.txt | head -1)
if [ -z "$DISK_SPEED" ]; then
  DISK_SPEED=$(grep -Eo '[0-9]+(\.[0-9]+)? [MGK]B/s' disk_results.txt | head -1)
fi
echo "🔸 Escritura en disco: ${DISK_SPEED:-No disponible}" >> benchmark_summary.txt

# RED resumen
NETWORK_SPEED=$(grep "receiver" network_results.txt | grep -Eo '[0-9]+(\.[0-9]+)? (G|M)bits/sec' | head -1)
echo "🔸 Velocidad de red local (iperf3): ${NETWORK_SPEED:-No disponible}" >> benchmark_summary.txt

# RAM resumen
RAM_INFO=$(free -h | grep Mem)
USED_MEM=$(echo $RAM_INFO | awk '{print $3}')
TOTAL_MEM=$(echo $RAM_INFO | awk '{print $2}')
echo "🔸 Memoria usada: $USED_MEM / $TOTAL_MEM" >> benchmark_summary.txt

# MySQL status
echo "🔸 MySQL está corriendo: $MYSQL_STATUS" >> benchmark_summary.txt

echo "==============================================" >> benchmark_summary.txt

cat benchmark_summary.txt