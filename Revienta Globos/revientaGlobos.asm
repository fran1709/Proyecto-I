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
  puntos db ":", "$" 
   
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
    
    pintarCuadro:   ;; se encarga de pintar el cuadro donde apareceran los globos
        mov ah, 0ch ;;Configuracion par aun solo pixel
        mov al, 0fh ;; Color blanco
        mov cx, 10  ;; coordenada columna
        mov dx, 60  ;; coordenada fila
        int 21h 
            ;; lineas del cuadro
            izquierda:
                inc dx
                int 10h
                cmp dx, 190
                jne izquierda
                je abajo
            abajo:
                inc cx
                int 10h
                cmp cx, 300
                jne abajo
                je derecha    
            derecha:
                dec dx
                int 10h
                cmp dx, 60
                jne derecha
                je arriba    
            arriba:
                dec cx
                int 10h
                cmp cx, 10
                jne arriba
                .exit 
                           
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
        jmp pintarCuadro
       
        
    nivelUno:  ;; llama los elementos del nivel 1 
        imprime salto
        imprime espacio
        imprime cargandoMatriz
        call pintarNombres
        
                
    playing:
        mov ah, 0    ;; Configura video
        mov al, 13h  ;; 40x25 16 colores
        int 10h       
        
        xor ax,ax
        xor bx,bx
        xor cx,cx
        mov si, 0
        
        call nivelUno
        
                        
          
    juego:  ;; funciona para implementar el juego
      imprime jugando 
      call pedir_nombres 
                 
    salgo:  ;; sale del juego
      imprime despedida
      .exit