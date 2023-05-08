#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>
#include <stdbool.h>
#include <time.h>
#include <sys/time.h>
#include <mpi.h>

/* Algunas variables */
#define ROOT 0
#define NUM_FUNCIONES 4

#define TAG_STATS 1
#define TAG_STOP 2
#define TAG_END 3

/* Estructura utilizada */
typedef struct {
    unsigned long long iteraciones;
    double tiempoAcumulado;
    unsigned long long numeroOperacionesMPI;
} datos;

/* Prototipos */
bool procesoCalculador(datos, MPI_Datatype);
MPI_Datatype getMPI_Struct(datos *);
double myGetTime(void);

/*
 * Main del programa
 */
int main(int argc, char **argv) {
    int id, numProcs, i, proceso;
    bool estado = true;
    unsigned long long iteracionesTotales, numeroOperacionesMPITotales;
    double tiempoInicioPrograma, tiempoInicioProgramaMGT,
           tiempoFinPrograma, tiempoFinProgramaMGT,
           tiempoInicioPrueba, tiempoAcumuladoTotal,
           tiempoTotalPrueba, tiempoActualizacion, actualizacion;
    MPI_Status status;
    MPI_Request request;
    datos datos;
    MPI_Datatype structDatos;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &id);
    MPI_Comm_size(MPI_COMM_WORLD, &numProcs);

    structDatos = getMPI_Struct(&datos); // Generamos el struct

    /* El id 0 obtiene los datos */
    if (id == ROOT) {
        if (numProcs < 2) {
            fprintf(stderr, "\nERROR: Debes ejecutar el programa con al menos 2 procesos.");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        if (argc != 3) {
            fprintf(stderr, "\n\nUtiliza: \'mpirun practica <tiempo total prueba> <tiempo de actualización>\'\n\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        tiempoTotalPrueba = atof(argv[1]);
        tiempoActualizacion = atof(argv[2]);

        if (tiempoTotalPrueba <= 0) {
            fprintf(stderr, "\nERROR: El tiempo de la prueba debe ser mayor que 0.");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        
        if (tiempoActualizacion <= 0) {
            fprintf(stderr, "\nERROR: El tiempo de actualización debe ser mayor que 0.");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        
        if (tiempoActualizacion >= tiempoTotalPrueba) {
            fprintf(stderr, "\nERROR: El tiempo de actualización no puede ser mayor o igual al tiempo total de la prueba.");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        actualizacion = tiempoActualizacion;
    }

    tiempoInicioPrograma = MPI_Wtime();  
    tiempoInicioProgramaMGT = myGetTime();

    if (id == ROOT) { /* Proceso E/S */
        for (i = 0; i < NUM_FUNCIONES; i++) {
            iteracionesTotales = 0;
            numeroOperacionesMPITotales = 0;
            tiempoAcumuladoTotal = 0;
            tiempoActualizacion = actualizacion;

            for (proceso = 1; proceso < numProcs; proceso++) 
                MPI_Send(&i, 1, MPI_INT, proceso, 0, MPI_COMM_WORLD);

            tiempoInicioPrueba = MPI_Wtime();
            while (MPI_Wtime() - tiempoInicioPrueba < tiempoTotalPrueba) {
                if (MPI_Wtime() - tiempoInicioPrueba >= tiempoActualizacion) {
                    for (proceso = 1; proceso < numProcs; proceso++) /* Enviamos petición de información */
                        MPI_Isend(NULL, 0, MPI_INT, proceso, TAG_STATS, MPI_COMM_WORLD, &request);

                    for (proceso = 1; proceso < numProcs; proceso++) { /* Información parcial */
                        MPI_Recv(&datos, 1, structDatos, MPI_ANY_SOURCE, 1, MPI_COMM_WORLD, &status);
                        fprintf(stdout,
                        "IP => PROCESO: %d | ITERACIONES: %llu | TIEMPO: %f | OPERACIONES MPI: %llu\n",
                        status.MPI_SOURCE, datos.iteraciones, datos.tiempoAcumulado, datos.numeroOperacionesMPI);
                    }
                    fprintf(stdout, "\n\n");
                    tiempoActualizacion += actualizacion;
                }
            }

            for (proceso = 1; proceso < numProcs; proceso++) /* Enviamos notificacion finalizacion prueba */
                MPI_Send(NULL, 0, MPI_INT, proceso, TAG_STOP, MPI_COMM_WORLD);

            for (proceso = 1; proceso < numProcs; proceso++) { /* Información final */
                MPI_Recv(&datos, 1, structDatos, MPI_ANY_SOURCE, 1, MPI_COMM_WORLD, &status);
                fprintf(stdout,
                "IF => PROCESO: %d | ITERACIONES: %llu | TIEMPO: %f | OPERACIONES MPI: %llu\n",
                status.MPI_SOURCE, datos.iteraciones, datos.tiempoAcumulado, datos.numeroOperacionesMPI);
                
                iteracionesTotales += datos.iteraciones;
                tiempoAcumuladoTotal += datos.tiempoAcumulado;
                numeroOperacionesMPITotales += datos.numeroOperacionesMPI;
            }

            fprintf(stdout, 
            "\n\nGENERAL => PRUEBA: %d | ITERACIONES: %llu | TIEMPO ACUMULADO: %f | OPERACIONES MPI: %llu\n\n", 
            i, iteracionesTotales, tiempoAcumuladoTotal, numeroOperacionesMPITotales);
        }

        /* Prueba finalizada */
        for (proceso = 1; proceso < numProcs; proceso++)
            MPI_Send(NULL, 0, MPI_INT, proceso, TAG_END, MPI_COMM_WORLD);
    } else {    /* Proceso calculador */
        while (estado) {
            estado = procesoCalculador(datos, structDatos);
        }
    }

    tiempoFinPrograma = MPI_Wtime(); 
    tiempoFinProgramaMGT = myGetTime();

    if (id == ROOT) { /* Resultados finales de la ejecución */
        fprintf(stdout, "\n\nEJECUCIÓN FINALIZADA:");
		fprintf(stdout, "\nNúmero de Procesos: %d \n", numProcs) ;
		fprintf(stdout, "Tiempo Procesamiento MPI_Wtime(): %f \n", tiempoFinPrograma-tiempoInicioPrograma);
		fprintf(stdout, "Tiempo Procesamiento myGetTime(): %f \n", tiempoFinProgramaMGT-tiempoInicioProgramaMGT);
    }

    MPI_Finalize();
    puts("");
    return 0;
}


/*
 * Proceso calculador
 */
bool procesoCalculador(datos datos, MPI_Datatype structDatos) {
    double ldParam = 0.5, ldResult, tiempoInicio;
    bool prueba = true;
    int funcionMathEjecutar, mensaje;
    MPI_Request request;
    MPI_Status status;

    datos.iteraciones = 0;
    datos.tiempoAcumulado = 0;
    datos.numeroOperacionesMPI = 0;

    MPI_Recv(&funcionMathEjecutar, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
    if (status.MPI_TAG == TAG_END) return false;

    while (prueba) {
        tiempoInicio = MPI_Wtime();
        datos.numeroOperacionesMPI++;
        switch (funcionMathEjecutar) {
            case 0: ldResult = hypotl(ldParam, ldParam); break;
            case 1: ldResult = cbrtl(ldParam); break;
            case 2: ldResult = erfl(ldParam); break;
            case 3: ldResult = sqrtl(ldParam); break;
        }
        datos.iteraciones++;
        datos.tiempoAcumulado += MPI_Wtime() - tiempoInicio;
        datos.numeroOperacionesMPI++;

        MPI_Iprobe(0, MPI_ANY_TAG, MPI_COMM_WORLD, &mensaje, &status);
        datos.numeroOperacionesMPI++;

        if(mensaje == 1) {
            MPI_Recv(NULL, 0, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
            datos.numeroOperacionesMPI++;

            if (status.MPI_TAG == TAG_STATS) {
                MPI_Isend(&datos, 1, structDatos, 0, 1, MPI_COMM_WORLD, &request);
                datos.numeroOperacionesMPI++;
            } else if (status.MPI_TAG == TAG_STOP) {
                prueba = false;
            }
        }
    }

    MPI_Send(&datos, 1, structDatos, 0, 1, MPI_COMM_WORLD);

    return true;
}


/* 
 * Creación del struct 
 */
MPI_Datatype getMPI_Struct(datos *sDatos) {
    MPI_Datatype structDatos;
    int longitudes[3];
    MPI_Aint desplazamiento[3];
    MPI_Aint direcciones[4];
    MPI_Datatype tipos[3];

    /* Elementos de cada tipo */
    tipos[0] = MPI_UNSIGNED_LONG_LONG;
    tipos[1] = MPI_DOUBLE;
    tipos[2] = MPI_UNSIGNED_LONG_LONG;

    /* Numero de elementos de cada tipo */
    longitudes[0] = 1; // Un long long
    longitudes[1] = 1; // Un double
    longitudes[2] = 1; // Un long long

    /* Calculamos los desplazamientos */
    MPI_Get_address(sDatos, &direcciones[0]);
    MPI_Get_address(&(sDatos->iteraciones), &direcciones[1]);
    MPI_Get_address(&(sDatos->tiempoAcumulado), &direcciones[2]);
    MPI_Get_address(&(sDatos->numeroOperacionesMPI), &direcciones[3]);

    desplazamiento[0] = direcciones[1] - direcciones[0];
    desplazamiento[1] = direcciones[2] - direcciones[0];
    desplazamiento[2] = direcciones[3] - direcciones[0];

    /* Creamos el tipo derivado */
    MPI_Type_create_struct(3, longitudes, desplazamiento, tipos, &structDatos);
    MPI_Type_commit(&structDatos);

    return structDatos;
}


/*
 * Calculo de tiempo
 */
double myGetTime(void) {
    struct timeval tv;
    if (gettimeofday(&tv, 0) < 0) perror("oops");
    return (double)tv.tv_sec + (0.000001 * (double)tv.tv_usec);
}