.model small
.stack 100h
.data 
  ;; Mensajes de menu principal
  opciones db ,10,13, "Ingrese una opcion numerica: ", "$"
  opcion1 db ,10,13, "1) Iniciar juego.", "$"
  opcion2 db ,10,13, "2) Salir.", "$"
  titulo db ,10,13, "     MENU PRINCIPAL", "$"
  jugando db ,10,13, "Bienvenido Jugador!", "$"
  pedir db ,10,13, "Ingrese un nombre: ", "$" 
  despedida db ,10,13, "Hasta pronto Jugador!", "$"
  cargandoMatriz db , "REVIENTA GLOBOS",10,13, "$"
  jugadores db ,10,13, "  ------ JUGADORES -----", "$"
  nivel1 db ,10,13, " NIVEL 1", "$"
  nivel2 db ,10,13, " NIVEL 2", "$"
  puntos db ":", "$"
  
  ;; cuadro
  arriC db " -------------------------------", 10,13, "$"
  dereC db "|" , "$"
  espC db "                               ", "$" 
  
  ;; globo
  limpiarPix db " ", "$"
  xGlobo dw 0
  yGlobo dw 0
   
  ;; Variables del menu
  opcion db 0
  dato1 db 1
  dato2 db 2
  
  ;; Salto de Linea
  salto db 13,10, '$'
  espacio db " ", "$"
  space db "  ", "$"
  
  ;; Variables de los jugadores   
  jugador1 db 10 dup(?), '$'
  jugador2 db 10 dup(?), '$'
  
  
  ;; matriz de 10x10
  matriz db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         db 10 dup(0)
         
  ;; posiciones de globos nivel 1
  globo1 db 2
  globo2 db 4
  globo3 db 7
  globo4 db 20
  dlobo5 db 30       
      
.code
  imprime macro arg  ;; Macro para imprimir cualquier mensaje por parametro
    push ax
    push dx
        
    mov ah, 09
    lea dx, arg
    int 21h     
        
    pop dx
    pop ax
        
    endm                  
    
             
  inicio: 
    mov ax, @data ;;Accediendo a la base de datos.
    mov ds, ax    
    
    mov ah, 0    ;; Configura video
    mov al, 00h  ;; 40x25 16 colores
    int 10h
    
    mov cx, 10
    mov di, 0
    
    menu: ;; Menu principal               
      imprime titulo 
      imprime salto
      imprime opcion1
      imprime opcion2        
      imprime salto
      imprime opciones 
      ;; finaliza el menu principal
      
    
    obtener: ;; Obtiene la opcion deseada por el usuario
     mov ah, 01h
     int 21h
     sub al, 30h
     mov opcion, al    
        
    evaluar: ;; evalua la opcion ingresada y llama su respectiva funcion  
      cmp al, dato1
      je juego
        
      cmp al, dato2
      je salgo    
            
           
    pedir_nombres: ;;solicita el nombre de los dos jugadores 
        mov cx, 10
        mov di, 0
        
        imprime pedir
        leer_str1:   ;;lee el primer jugador
            mov ah, 1
            int 21h
            
            cmp al, 13
            je imprimir_str1
            mov jugador1[di], al
            inc di
            
          loop leer_str1
        
        imprimir_str1: ;;imprime informacion del jugador 1
            imprime salto
            mov ah, 09
            lea dx, jugador1
            int 21h  
        
        mov cx, 10
        mov di, 0
            
        imprime pedir    
        leer_str2:   ;;lee el segundo jugador
            mov ah, 1
            int 21h
            
            cmp al, 13
            je imprimir_str2
            mov jugador2[di], al
            inc di
            
          loop leer_str2
        
        imprimir_str2:  ;;imprime informacion del jugador 2
            imprime salto
            mov ah, 09
            lea dx, jugador2
            int 21h    
            
        iniciarJuego:  ;; salta a la flag del juego
            jmp playing 
      
    
    borrarGlobo:
        mov ah, 0ch  ;;Configuracion para un solo pixel
        mov al, 02h  ;; Color verde
        mov dx, xGlobo
        mov cx, yGlobo 
        int 10h
        jmp menu    
    
    obtenerClic: ;; lectura del clic derecho  
        xor dx, dx
        xor cx, cx
        mov ax, 3
        int 33h
        cmp bx, 1
        mov yGlobo, cx
        mov xGlobo, dx
        je borrarGlobo
        jmp obtenerClic
    
    iniciarMouse:
        mov ax, 0 ;; se inicia el mouse con el pointer invisible
        int 33h
        
        mov ax, 1 ;; hace visible el pointer
        int 33h
        
        jmp obtenerClic
        
    
    globoYellow:
        mov ah, 0ch  ;;Configuracion para un solo pixel
        mov al, 0eh  ;; Color amarillo
        mov cx, 100  ;; coordenada columna
        mov dx, 80   ;; coordenada fila
        int 10h
            ;; lineas del globo
            ;izqAm:
;                inc dx
;                int 10h
;                cmp dx, 82
;                jne izqAm
;                je abaAm
;            abaAm:
;                inc cx
;                int 10h
;                cmp cx, 102
;                jne abaAm
;                je dereAm    
;            dereAm:
;                dec dx
;                int 10h
;                cmp dx, 80
;                jne dereAm
;                je arriAm    
;            arriAm:
;                dec cx
;                int 10h
;                cmp cx, 100
;                jne arriAm
            
            jmp iniciarMouse
            
                
    globoAzul:
        mov ah, 0ch  ;; Configuracion para un solo pixel
        mov al, 01h  ;; Color azul
        mov cx, 90   ;; coordenada columna
        mov dx, 130  ;; coordenada fila
        int 10h
            ;; lineas del globo
            izqA:
                inc dx
                int 10h
                cmp dx, 132
                jne izqA
                je abaA
            abaA:
                inc cx
                int 10h
                cmp cx, 92
                jne abaA
                je dereA    
            dereA:
                dec dx
                int 10h
                cmp dx, 130
                jne dereA
                je arriA    
            arriA:
                dec cx
                int 10h
                cmp cx, 90
                jne arriA
            jmp globoYellow 
    
    
    globoVerde:
        mov ah, 0ch  ;; Configuracion para un solo pixel
        mov al, 02h  ;; Color verde
        mov cx, 60   ;; coordenada columna
        mov dx, 100  ;; coordenada fila
        int 10h
            ;; lineas del globo
            izqG:
                inc dx
                int 10h
                cmp dx, 102
                jne izqG
                je abaG
            abaG:
                inc cx
                int 10h
                cmp cx, 62
                jne abaG
                je dereG    
            dereG:
                dec dx
                int 10h
                cmp dx, 100
                jne dereG
                je arriG    
            arriG:
                dec cx
                int 10h
                cmp cx, 60
                jne arriG
            jmp globoAzul             
    
    globoRojo:
        mov ah, 0ch ;; Configuracion para un solo pixel
        mov al, 04h ;; Color rojo
        mov cx, 40  ;; coordenada columna
        mov dx, 90  ;; coordenada fila
        int 10h
            ;; lineas del globo
            izquierda1:
                inc dx
                int 10h
                cmp dx, 92
                jne izquierda1
                je abajo1
            abajo1:
                inc cx
                int 10h
                cmp cx, 42
                jne abajo1
                je derecha1    
            derecha1:
                dec dx
                int 10h
                cmp dx, 90
                jne derecha1
                je arriba1    
            arriba1:
                dec cx
                int 10h
                cmp cx, 40
                jne arriba1
            jmp globoVerde 
                 
    pintarGlobos:
           jmp globoRojo
  
    pCuadro:  ;; pinta el cuadro como texto
        imprime salto
        imprime arriC
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime dereC
        imprime espC
        imprime dereC
        
        imprime salto
        imprime arriC
        
      jmp pintarGlobos
      
    ;pintarCuadro:   ;; se encarga de pintar el cuadro donde apareceran los globos
;        mov ah, 0ch ;;Configuracion par aun solo pixel
;        mov al, 0fh ;; Color blanco
;        mov cx, 10  ;; coordenada columna
;        mov dx, 60  ;; coordenada fila
;        int 10h 
;            ;; lineas del cuadro
;            izquierda:
;                inc dx
;                int 10h
;                cmp dx, 190
;                jne izquierda
;                je abajo
;            abajo:
;                inc cx
;                int 10h
;                cmp cx, 200
;                jne abajo
;                je derecha    
;            derecha:
;                dec dx
;                int 10h
;                cmp dx, 60
;                jne derecha
;                je arriba    
;            arriba:
;                dec cx
;                int 10h
;                cmp cx, 10
;                jne arriba
;         jmp pintarGlobos 
                           
    pintarNombres:
        
        imprime jugadores
        imprime salto 
        imprime space 
        imprime space
        imprime space
        imprime jugador1 
        imprime espacio
        imprime jugador2
        imprime salto
        imprime space
        imprime nivel1
        imprime salto
        jmp pCuadro
       
        
    nivelUno:  ;; llama los elementos del nivel 1 
        imprime salto
        imprime espacio
        imprime cargandoMatriz
        jmp pintarNombres
        
                
    playing:
        mov ax, 0013h  ;; 40x25 16 colores
        int 10h       
        
        ;xor ax,ax
;        xor bx,bx
;        xor cx,cx
;        mov si, 0
        
        jmp nivelUno
                             
          
    juego:  ;; funciona para implementar el juego
      imprime jugando 
      jmp pedir_nombres 
                 
    salgo:  ;; sale del juego
      imprime despedida
      .exit