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
	.global inicio_programa

; -------------------- ;
; Registros utilizados ;
; -------------------- ;
; r0 -> 0               r1 -> vector
; r2 -> tamanho         r3 -> M
; r4 -> detM            r5 -> mediaM
; r6 -> V               r7 -> detV
; r8 -> mediaV

inicio_programa:
    lw r2, tamanho       
    addi r1, r0, vector  

    lf f1, valor_inicial 
    lf f2, suma          

bucle_fibonacci:
    sf 0(r1), f3        
    addi r1, r1, 4

    addf f3, f1, f4
    addf f2, f2, f3
    addf f4, f1, f0
    addf f1, f3, f0

    sf 0(r1), f3         
    addi r1, r1, 4      

    addf f3, f1, f4      
    addf f2, f2, f3      
    addf f4, f1, f0      
    addf f1, f3, f0     

    sf 0(r1), f3         
    addi r1, r1, 4      

    addf f3, f1, f4      
    addf f2, f2, f3      
    addf f4, f1, f0      
    addf f1, f3, f0

    sf 0(r1), f3         
    addi r1, r1, 4      

    addf f3, f1, f4      
    addf f2, f2, f3      
    addf f4, f1, f0      
    addf f1, f3, f0

    subi r2, r2, #5
    beqz r2, fin_bucle

    sf 0(r1), f3         
    addi r1, r1, 4      

    addf f3, f1, f4      
    addf f2, f2, f3      
    addf f4, f1, f0      
    addf f1, f3, f0

    j bucle_fibonacci

fin_bucle:
    sf suma, f2         

    addi r3, r0, M       
    addi r1, r0, vector
    lf f15, valorMedia
    addi r4, r0, detM
    addi r5, r0, mediaM
    addi r6, r0, V
    addi r7, r0, detV  
    lf f5, 12(r1)        
    lf f6, 16(r1)       
    lf f7, 20(r1)        
    lf f8, 24(r1)        

    multf f9, f5, f8    
    sf 0(r3), f5
    sf 4(r3), f6
    sf 8(r3), f7
    sf 12(r3), f8
    multf f10, f6, f7   
    subf f11, f9, f10
    divf f17, f5, f11   
          
    addf f12, f5, f6    
    addf f13, f7, f8    
    addf f14, f12, f13  
    divf f16, f14, f15  
       
    divf f18, f6, f11  
    divf f19, f7, f11   
    divf f20, f8, f11   

    multf f21, f17, f20 
    sf 0(r6), f17
    sf 4(r6), f18
    sf 8(r6), f19
    sf 12(r6), f20
    multf f22, f18, f19 
      
    addi r8, r0, mediaV
    addf f24, f17, f18  
    addf f25, f19, f20  
    addf f26, f24, f25
    divf f27, f26, f15
    subf f23, f21, f22
    sf 0(r5), f16
    sf 0(r4), f11  
    sf 0(r8), f27
    sf 0(r7), f23

fin_programa:
    trap 0