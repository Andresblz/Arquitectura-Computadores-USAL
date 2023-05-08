#!/bin/bash

# Ejecución aproximada de todas las pruebas: 28 min

# Compilar programa
programa_c="mpi.c"
programa_mpi="practica"
cmd="mpicc $programa_c -o practica"
eval $cmd

# Lista de valores de -np a probar
np_values=(2 4 8 16 32 64)
time_values=(10 20 40)

for np in "${np_values[@]}"
do
    for time in "${time_values[@]}"
    do
        txt="${np}_${time}_3.txt"
        echo "Ejecutando $programa_mpi con -np $np y tiempo $time"

        # Comando para ejecutar el programa MPI con el valor de -np correspondiente
        cmd="mpirun -np $np $programa_mpi $time 3"

        # Si el valor de -np es mayor que el número de procesadores disponibles, incluimos la opción --oversubscribe
        if [[ $np -ge $(sysctl -n hw.physicalcpu) ]]; then
            cmd="mpirun --oversubscribe -np $np $programa_mpi $time 3"
        fi

        # Ejecutamos el comando y guardamos en fichero
        eval $cmd > $txt
    done
done