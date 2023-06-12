# PRÁCTICA 2:
## Implementación y optimización de un cálculo en ensamblador DLX

### 1. Descripción de la práctica

El objetivo de la práctica es el desarrollo y optimización de un código que realice el siguiente cálculo:

a) Calcular una secuencia de números "estilo Fibonacci" partiendo de un valor inicial dado (`valor_inicial` float de 1.0 a 5.0), siendo que si su valor es 1 sería la secuencia de Fibonacci (0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...).

```
vector[0] = 0
vector[1] = valor_inicial
vector[n] = vector[n - 1] + vector[n - 2]
```

b) El número de términos a calcular podrá ser un valor entre 10 y 30 (`tamanho`), incluidos, en múltiplos de 5 y vendrá dado por el valor de una variable (`valor_inicial`), con lo que el resultado se tendrá en un array de datos de tipos float (0 al valor máximo -1) (`vector`).

c) Habrá que calcular la suma de los valores de la secuencia obtenida y almacenarla (`suma`).

d) Se creará una matriz M con los siguientes términos de secuencia (`M`).

```
     ┌  m₁₁ m₁₂  ┐      ┌ vector[5]  vector[6] ┐
M =  │           │  =   │                      │
     └  m₂₁ m₂₂  ┘      └ vector[7]  vector[8] ┘
```

e) Se calculará el determinante de la matriz M (`detM`).

```
detM = (m₁₁ * m₂₂) - (m₁₂ * m₂₁)
```

f) Se calculará la media de los valores de M (`mediaM`).

```
mediaM = (m₁₁ + m₁₂ + m₂₁ + m₂₂) / 4
```

g) Se creará una matriz V a partir de la matriz M (cada término de M dividido por el valor del determinante de M)(`V`).

```
     ┌  v₁₁ v₁₂  ┐      ┌ m₁₁ / detM  m₁₂ / detM ┐
V =  │           │  =   │                        │
     └  v₂₁ v₂₂  ┘      └ m₂₁ / detM  m₂₂ / detM ┘
```

h) Se calculará el determinante de la matriz V (`detV`).

```
detV = (v₁₁ * v₂₂) - (v₁₂ * v₂₁)
```

i) Se calculará la media de los valores de V (`mediaV`).

```
mediaV = (v₁₁ + v₁₂ + v₂₁ + v₂₂) / 4
```

Datos de entrada y salida en DLX:

```assembly
; VARIABLES DE ENTRADA: NO MODIFICAR
; Valor inicial para la secuencia (de 1.0 a 5.0)
valor_inicial:  .float 1.0
; Tamanho de la secuencia (multiplo de 5 minimo 10 maximo 30)
tamanho:    .word 30

;;;;; VARIABLES DE SALIDA: NO MODIFICAR ORDEN (TODAS FORMATO FLOAT)
vector:     .space 120
suma:       .float 0.0

M:          .float 0.0, 0.0
            .float 0.0, 0.0
detM:       .float 0.0
mediaM:     .float 0.0

V:          .float 0.0, 0.0
            .float 0.0, 0.0
detV:       .float 0.0
mediaV:     .float 0.0
```

### 2. Se pide

a) Realizar una versión no optimizada que realice el cálculo pedido

b) Optimizar el cálculo realizado en a) empleando las técnicas habituales de uso de registros adicionales, reordenación de código, desenrollamiento de bucles (si los hay), etc.

c) Se debe mantener el orden de las variables de entrada y salida en memoria. Se deben comprobar las posibles divisiones por 0 (y salir sin que salga el mensaje de error (directamente ir al trap 0)).

d) En ambas versiones el resultado debe ser almacenado en `vector`, `suma`, `M`, `detM`, `mediaM`, `V`, `detV`, `mediaV`.

e) Los valores de entrada `valor_inicial` y `tamanho` se pueden cambiar.

### 3. Se deberá entregar:

a) Las dos versiones del programa (normal y optimizada), comentadas.

b) Se entregará un breve documento explicando las mejoras realizadas y comparación de resultados obtenidos.