#!/bin/bash
#Script desarrollado por Alexis Milano para la verificaci#n de los servicios y la escritura sobre un archivo
#Versi#n 1.0
#11-09-23

# Ruta del archivo de salida
archivo_salida="/home/sas/serviciosSAS.txt" 

# Obtener la hora y la fecha actual
fecha_hora=$(date +"%Y-%m-%d %H:%M:%S")

# Inicializar una variable para el estado general (todos los servicios están activos)
estado_general="Plataforma Ok: Todos los servicios están activos."

# Lista de servicios excluidos
servicios_excluidos=("sas-viya-all-services")

# Función para verificar el estado de un servicio
verificar_servicio() {
    local servicio="$1"

    # Verificar si el servicio está en la lista de excluidos
    if [[ " ${servicios_excluidos[*]} " =~ " $servicio " ]]; then
       #echo "[$fecha_hora] Excluido: El servicio $servicio está excluido."
        return
    fi

    if sudo systemctl is-active --quiet "$servicio"; then
        echo "[$fecha_hora] Ok: El servicio $servicio está activo."
    else
        echo "[$fecha_hora] Down: El servicio $servicio no está activo."
        estado_general="Down: Al menos un servicio no está activo."
        servicios_no_activos+=("$servicio")
    fi
}

# Obtener la lista de servicios que comienzan con "sas-"
servicios=($(ls /etc/init.d/sas-viya*))

# Verificar el estado de cada servicio
for servicio in "${servicios[@]}"; do
    verificar_servicio "$(basename "$servicio")"
done

# Escribir el estado general en el archivo de salida
echo "[$fecha_hora] $estado_general" | sudo tee -a "$archivo_salida" >/dev/null

# Imprimir el estado general en la pantalla (opcional)
echo "[$fecha_hora] $estado_general"

# Si hay servicios no activos, listarlos en el archivo y en la pantalla
if [ ${#servicios_no_activos[@]} -gt 0 ]; then
    echo "[$fecha_hora] Servicios no activos: ${servicios_no_activos[*]}" | sudo tee -a "$archivo_salida" >/dev/null
    echo "[$fecha_hora] Servicios no activos: ${servicios_no_activos[*]}"
fi

# Notificar al usuario
echo "El resultado se ha escrito en $archivo_salida"
