.data

; VARIABLES DE ENTRADA: NO MODIFICAR
; Valor inicial para la secuencia (de 1.0 a 5.0)
valor_inicial:  .float 1.0
; Tamanho de la secuencia (multiplo de 5 minimo 10 maximo 30)
tamanho:    .word 30

;;;;; VARIABLES DE SALIDA: NO MODIFICAR ORDEN (TODAS FORMATO FLOAT)
vector:     .space 120
suma:       .float 0.0

; m11 = vector[5], m12 = vector[6]
; m21 = vector[7], m13 = vector[8]
M:          .float 0.0, 0.0
            .float 0.0, 0.0
detM:       .float 0.0
mediaM:     .float 0.0

; v11 = m11/mediaM, v12 = m12/mediaM
; v21 = m21/mediaM, v22 = m22/mediaM
V:          .float 0.0, 0.0
            .float 0.0, 0.0
detV:       .float 0.0
mediaV:     .float 0.0

; Variable para calcular las medias correspondientes
; mediaM = (m11 + m12 + m21 + m22) / 4
; mediaV = (v11 + v12 + v21 + v22) / 4
valorMedia:      .float 4.0

    .text
	.global main

; -------------------- ;
; Registros utilizados ;
; -------------------- ;
; r0 -> 0               r1 -> vector
; r2 -> tamanho         r3 -> M
; r4 -> detM            r5 -> mediaM
; r6 -> V               r7 -> detV
; r8 -> mediaV

inicio_programa:
    lw r2, tamanho       ; Cargamos el registro r2 con el valor de tamanho para iterar en el bucle

    ; Reservamos f0 con el valor 0 (no lo asignamos nunca)
    lf f1, valor_inicial ; Cargamos f1 = valor_inicial
    lf f2, suma          ; Cargamos f2 = suma
    
    addi r1, r0, vector  ; Cargamos la primera posicion del vector en el registro r1


bucle_fibonacci:
    subi r2, r2, #1      ; Decrementamos el valor del registro 2 (tamanho)
    beqz r2, fin_bucle   ; Si r2 = 0, salimos del bucle

    sf 0(r1), f3         ; Guardamos el valor calculado en la posición del registro 1
    addi r1, r1, #4      ; Movemos la posición efectiva de vector

    addf f3, f1, f4      ; Calculamos el siguiente valor = actual + anterior

    addf f2, f2, f3      ; Calculamos la suma = suma + valor
    addf f4, f1, f0      ; Guardamos el valor anterior en f4
    addf f1, f3, f0      ; Guardamos el valor siguiente en f1

    j bucle_fibonacci    ; Saltamos al bucle


fin_bucle:
    sf suma, f2          ; Guardamos en la variable suma el resultado final

    ; -------------------------- ;
    ; Operaciones de la matriz M ;
    ; -------------------------- ;
    addi r3, r0, M       ; Inicializamos la primera posicion de M
    addi r1, r0, vector  ; Reiniciamos el vector en r1 para poder desplazarnos hasta vector[5]
    addi r1, r1, #12     ; Nos movemos hasta la posición efectiva de vector[5]
    lf f5, 0(r1)         ; f5 = vector[5]
    addi r1, r1, #4
    lf f6, 0(r1)         ; f6 = vector[6]
    addi r1, r1, #4
    lf f7, 0(r1)         ; f7 = vector[7]
    addi r1, r1, #4
    lf f8, 0(r1)         ; f8 = vector[8]

    ; Guardamos los datos del vector en el registro de la variable M
    sf 0(r3), f5
    addi r3, r3, #4
    sf 0(r3), f6
    addi r3, r3, #4
    sf 0(r3), f7
    addi r3, r3, #4
    sf 0(r3), f8

    ; Calculo del determinante
    ; detM = (m11 x m22) - (m12 x m21) = (f5 x f8) - (f6 x f7) = f9 - f10 = f11
    addi r4, r0, detM
    multf f9, f5, f8    ; f9 = (f5 x f8)
    multf f10, f6, f7   ; f10 = (f6 x f7)
    subf f11, f9, f10   ; f11 = detM
    sf 0(r4), f11       ; Guardamos el valor del determinante en el registro de la variable detM

    ; Calculo de la media
    ; mediaM = (m11 + m12 + m21 + m22) /4 = (f5 + f6 + f7 + f8) / 4 = (f12 + f13) / 4 = f14 / f15
    addi r5, r0, mediaM
    addf f12, f5, f6    ; f12 = (f5 + f6)
    addf f13, f7, f8    ; f13 = (f7 + f8)
    addf f14, f12, f13  ; f14 = (f12 + f13)
    lf f15, valorMedia  ; f15 = 4
    divf f16, f14, f15  ; f16 = f14 / 4
    sf 0(r5), f16       ; Guardamos el valor de la media en el registro de la variable mediaM


    ; -------------------------- ;
    ; Operaciones de la matriz V ;
    ; -------------------------- ;
    addi r6, r0, V      ; Inicializamos la primera posición de V
    divf f17, f5, f11   ; f17 = v11 = m11 / detM = f5 / f11
    divf f18, f6, f11   ; f18 = v12 = m12 / detM = f6 / f11
    divf f19, f7, f11   ; f19 = v21 = m21 / detM = f7 / f11
    divf f20, f8, f11   ; f20 = v22 = m22 / detM = f8 / f11

    ; Guardamos los datos calculados en el registro de la variable V
    sf 0(r6), f17
    addi r6, r6, #4
    sf 0(r6), f18
    addi r6, r6, #4
    sf 0(r6), f19
    addi r6, r6, #4
    sf 0(r6), f20

    ; Calculo del determinante
    ; detV = (v11 x v22) - (v12 x v21) = (f16 x f17) - (f18 x f19) = f21 - f22 = f23
    addi r7, r0, detV
    multf f21, f17, f20 ; f21 = (f17 x f20)
    multf f22, f18, f19 ; f22 = (f18 x f19)
    subf f23, f21, f22  ; f23 = detV
    sf 0(r7), f23       ; Guardamos el valor del determinante en el registro de la variable detV

    ; Calculo de la media
    ; mediaV = (v11 + v12 + v21 + v22) /4 = (f17 + f18 + f19 + f20) / 4 = (f24 + f25) / 4 = f26 / f15
    addi r8, r0, mediaV
    addf f24, f16, f17  ; f24 = (v11 + v12)
    addf f25, f18, f19  ; f25 = (v21 + v22)
    addf f26, f24, f25  ; f26 = (f24 + f25)
    divf f27, f26, f15  ; f27 = f26 / 4
    sf 0(r8), f27       ; Guardamos el valor de la media en el registro de la variable mediaV


fin_programa:
    trap 0      ; Finalizamos el programa