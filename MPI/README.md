# PRÁCTICA 1: MPI

Se desean realizar unas "medidas de rendimiento" de iteraciones por segundo empleando 4 funciones de la biblioteca math.h:

- Compute hypotenuse: `long double hypotl (long double x, long double y);`
- Compute cubic root: `long double cbrt (long double x);`
- Compute error function: `long double erf (long double x);`
- Compute square root: `long double sqrtl (long double x);`

En este caso una posible manera de seleccionar la función a la que se va a llamar podría ser la siguiente, de manera que el tiempo obtenido será el de las operaciones y llamadas incluidas en la iteración, que además incluye la llamada a la función seleccionada.

```c
// INICIO ITERACION: MANTENER EN MPI
tIni=Wtime();
ldParam=0.5;
switch(t)
{
    case 0: ldResult=hypotl(ldParam,ldParam); break; 
    case 1: ldResult=cbrtl(ldParam); break;
    case 2: ldResult=erfl(ldParam); break;
    case 3: ldResult=sqrtl(ldParam); break;
}
uiIter++;
tAcumLD+=Wtime()-tIni;
// FIN ITERACION
```

En vez de realizar un número de llamadas predefinida a la iteración, se llamará repetidamente durante un tiempo. Se tendrá un bucle que irá llamando a esta iteración todo lo rápido posible hasta que se llegue a un determinado tiempo.

Al final se desea obtener el número total de iteraciones realizadas (cuidado con el tipo de datos empleado), el tiempo de cálculo empleado al realizar las llamadas a la iteración, y el tiempo total de ejecución. A partir de ahí, se obtendrán valores totales de tiempos, y valores de llamadas por segundo relativas al tiempo acumulado en las llamadas a las iteraciones y al tiempo total de la prueba, etc. Todo esto, para cada una de las funciones.

A partir de esto, se va a emplear MPI para realizar iteraciones de manera paralela en diferentes procesos y máquinas y ver la ganancia obtenida.

Se tendrá:

**Proceso de entrada salida:**

- En este caso como parámetros de entrada se tendrán el tiempo total de la prueba y el tiempo de actualización. Mandará ejecutar la prueba para cada una de las cuatro funciones.

    - Para cada una de las funciones:

        - Notifica a los procesos calculadores la función dentro de la iteración que deben llamar.

        - Controla el tiempo total de la prueba.

        - Controla el tiempo de actualización y cuando se cumple:

            - Envía un mensaje a los procesos calculadores requiriendo la información actual (iteraciones, tiempo de cálculo acumulado, consultas/llamadas a funciones de MPI, etc.).

            - Acumula y muestra por pantalla los resultados parciales, remitidos por cada proceso, así como el tiempo actual de la prueba.

        - Una vez vencido el tiempo total de la prueba:

            - Notifica a los procesos calculadores que deben dejar de iterar.

            - Les solicita la información final.

        - Muestra los resultados finales de la prueba para una función seleccionada.

        - Si no se ha realizado la prueba para todas las funciones vuelve al principio.

    - Una vez realizadas todas las pruebas notifica a los procesos calculadores que deben terminar.

    - Finalizar el programa.

**Proceso calculador:**

- Espera a que el proceso de E/S le indique la función a iterar, o bien, que ha terminado las pruebas.

- Si le indica una función:

    - Comenzará a iterar hasta que el proceso E/S le indique que debe parar.

        - Iterará e irá actualizando sus estadísticas internas.

        - Debe de consultar si tiene o no mensajes del proceso de E/S.

            - Actualizar.

                - Le manda la información actual y sigue iterando.

            - Parar.

                - Manda la información final y vuelve a esperar si tiene que iterar o terminar.

- Si le indica finalizar:

    - Finaliza su ejecución.

La información debe de ser como mínimo, el número de iteraciones, el tiempo de cálculo acumulado, las consultas y/o operaciones de MPI realizadas durante el tiempo que está iterando.

Con esta información se elaborarán estadísticas para conocer el tiempo de calculo acumulado y el de la prueba total, el número de iteraciones que se han realizado y como puede afectar las consultas a MPI.

Observando los tiempos parciales de cada proceso también se podrían detectar anomalías en la distribución. 

Se realizarán pruebas para ver como aumenta el rendimiento a medida que se ejecuta en paralelo.

**Una vez se ha realizado el programa realizar un estudio de rendimiento en el cual se vea que:**

- Aumentando el número de procesos se reduce el tiempo de cálculo hasta un cierto momento, en este caso no se consigue un mayor número de iteraciones, (por ej.: 2, 3, 4, ... , 8, 16, 64), teniendo en cuenta las características de las máquinas empleadas.

- Una vez alcanzado el tope de una máquina probar con varias máquinas en red. 

- Interpretar y representar los resultados obtenidos.

- El tiempo de la prueba debe de ser lo suficientemente alto.

**SE DEBERÁ ENTREGAR:**

- Código fuente del programa realizado.

- Presentación empleada en el Seminario.

    - Breve descripción del trabajo realizado:

        - Aspectos relevantes.

        - Estructura de comunicación empleada.

        - Tipos de datos empleados.
        
        - ...

    - Estudio del rendimiento obtenido, con gráficas.

    - Todo aquello que se estime oportuno para explicar el trabajo realizado.

    - Conclusiones.