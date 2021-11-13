include "emu8086.inc"


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
  simboloGlobo db "@", "$"
   
  ;; Variables del menu
  opcion db 0
  dato1 db 1
  dato2 db 2
  ciclo dw 64h 
  salir db "Salir [$" 
  derrota db "Derrota [$"  
  reiniciar db "Reiniciar [$"
  final db "] $"
  
  ;; Salto de Linea
  salto db 13,10, '$'
  espacio db " ", "$"
  space db "  ", "$"
  
  ;; Variables de los jugadores   
  jugador1 db 10 dup(?), '$'
  jugador2 db 10 dup(?), '$' 
  
  ;Turno de los jugadores
  turno db 0 ;Es 0 para el turno de jugador1, es 1 para jugador2
  
  
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

  define_print_num ;call print_num                            
  define_print_num_uns

  posicionar macro fila, columna; macro para posicionar donde se quiere escribir el caracter 
    mov ah, 2
    mov dh, fila ; la interrupcion pide que en dh vaya la fila
    mov dl, columna ; la interrupcion pide que en dl vaya la columna
    mov bh, 0 ; en la pagina 0
    int 10h
    endm
 

  beep macro ; macro que para que se escuhe un sonido
    mov dl, 07h ; El 07 en ascii corresponde al "beep", la interrupcion pide que eso este en dl
    mov ah, 02h 
    int 21h     ; lee el valor que tiene dl
    
    endm


  imprime macro arg  ;; Macro para imprimir cualquier mensaje por parametro
    push ax
    push dx
        
    mov ah, 09
    lea dx, arg
    int 21h     
        
    pop dx
    pop ax
        
    endm                  
  
  imprimeNumeros macro numero ;; imprime numeros de 2+ cifras
    xor ax,ax
    mov al, numero
    call print_num
    endm
  
  imprimeCaracter macro caracter, colorsito ; macro para imprimer el caracter donde se haya posicionado el cursor
      
     
     mov ah, 0Ah
     mov al, caracter
     mov bh, 0
     mov cx, 1
     int 10h
     
     MOV AH,9H ; Interrupcion que permite pintar el caracter
     MOV AL,caracter
     
       
     MOV BX, colorsito
        
     mov cx, 1
     int 10h 
     
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
    
    ;limpiarDxCx proc
;        xor dx, dx
;        xor cx, cx
;        ret
;    limpiarDxCx endp
;    
;    return:
;        ret
;    
;    posicionarCx proc
;        dec cx
;        cmp cx, ciclo
;        je return
;        jmp posicionarCx
;        
;    posicionarCx endp

    ; Posible random
    
    salirJuego:
        .exit
    
    
    beepC proc
        mov dl, 07h ; El 07 en ascii corresponde al "beep", la interrupcion pide que eso este en dl
        mov ah, 02h 
        int 21h     ; lee el valor que tiene dl 
        ret   
        endp
    
    borrarGlobo:
            
    
    funcionesClic:
        ;comparar x,y con variable
        
        
        ;; Coordenada 'X' para salir
        cmp cx,161 
        je salirY
        cmp cx,162 
        je salirY
        cmp cx,163 
        je salirY
        cmp cx,164 
        je salirY
        cmp cx,165 
        je salirY
        jmp derrotaX
        
        salirY: ;; Coordenada 'Y' para salir
        cmp dx,190
        je salirJuego
        cmp dx,189
        je salirJuego
        cmp dx,188
        je salirJuego
        cmp dx,187
        je salirJuego
        cmp dx,186
        je salirJuego
        cmp dx,185
        je salirJuego
        jne derrotaX ;; No dio click en el boton salir
         
        ; Coordenada 'X' para derrota
        derrotaX:
        cmp cx,217
        je derrotaY
        cmp cx,218
        je derrotaY
        cmp cx,219
        je derrotaY
        cmp cx,220
        je derrotaY
        cmp cx,221
        je derrotaY
        cmp cx,222
        je derrotaY
        cmp cx,223
        je derrotaY
        jne reiniciarX ;; No dio click en el boton derrota
                                                           
        ; Coordenada 'Y' para derrota
        derrotaY:
        cmp dx,168
        je salirJuego
        cmp dx,169
        je salirJuego
        cmp dx,170
        je salirJuego
        cmp dx,171
        je salirJuego
        cmp dx,172
        je salirJuego
        cmp dx,173
        je salirJuego
        cmp dx,174
        jne reiniciarX ;; No dio click en el boton derrota                                                   
              
        reiniciarX:
        ; Coordenada 'X' para reiniciar
        cmp cx,113
        je reiniciarY
        cmp cx,114
        je reiniciarY
        cmp cx,115
        je reiniciarY
        cmp cx,116
        je reiniciarY
        cmp cx,117
        je reiniciarY
        cmp cx,118
        je reiniciarY
        cmp cx,119
        je reiniciarY
        jne globoSelec ;; No dio click en el boton reiniciar
        
        ; Coordenada 'Y' para reiniciar
        reiniciarY:
        cmp dx,168
        je salirJuego
        cmp dx,169
        je salirJuego
        cmp dx,170
        je salirJuego
        cmp dx,171
        je salirJuego
        cmp dx,172
        je salirJuego
        cmp dx,173
        je salirJuego
        cmp dx,174
        jne globoSelec ;; No dio click en el boton reiniciar      
                                                           
        globoSelec:
            ;; globo
            cmp cx,131 
            jne isBip
            cmp dx,166
            jne isBip
            je salirJuego
        
        isBip:
            call beepC
            jmp obtenerClic
    
    obtenerClic: ;; lectura del clic derecho  
        ;call limpiarDxCx
        mov ax, 3
        int 33h
        cmp bx, 1 
        je funcionesClic      
        jmp obtenerClic
    
    iniciarMouse:
        mov ax, 0 ;; se inicia el mouse con el pointer invisible
        int 33h
        
        mov ax, 1 ;; hace visible el pointer
        int 33h
        
        jmp obtenerClic
        
         
    salirButton proc
        mov ah,02h
        mov bh,00
        mov dl,13d ;cordenada en x donde va posicionada
        mov dh,17h ;cordenada en y donde va posicionada
        int 10h
        ; imprimimos el caracter de la S de salir debajo del cuadro
        imprime salir
        mov ah,02h
        mov dl,'S'
        int 21h 
        imprime final
     salirButton endp
    
;    botonSalir:
;        posicionar 20, 16
;        imprime salir
    
    derrotaButton proc
        mov ah,02h
        mov bh,00
        mov dl,18d ;cordenada en x donde va posicionada
        mov dh,15h ;cordenada en y donde va posicionada
        int 10h
        ; imprimimos el caracter de la D de derrota debajo del cuadro
        imprime derrota
        mov ah,02h
        mov dl,'D'
        int 21h 
        imprime final
     derrotaButton endp
        
    reiniciarButton proc
        mov ah,02h
        mov bh,00
        mov dl,3d ;cordenada en x donde va posicionada
        mov dh,15h  ;cordenada en y donce va posicionada
        int 10h
        ; imprimimos el caracter de la R de reinicio debajo del cuadro
        imprime reiniciar
        mov ah,02h
        mov dl,'R'
        int 21h
        imprime final
     reiniciarButton endp
    
    globoYellow proc  ;; proceso de pintar globo amarillo
        posicionar 12, 4
        imprimeCaracter simboloGlobo, 14       
            
    globoYellow endp
            
                
    globoAzul proc  ;; proceso de pintar globo azul
        ;; hace falta implementar random
        ;; cambiar variables en dx, cx
        posicionar 13, 9
        imprimeCaracter simboloGlobo, 1 
        
        
        ;; Guardo en la matriz el objeto. 
        mov si, 11
        mov matriz[si], "f"  
            ret
    
    globoAzul endp 
    
    
    globoVerde proc   ;; proceso de pintar globo verde
         posicionar 12, 7
         imprimeCaracter simboloGlobo, 2
         ret
    globoVerde endp             
     
     
    globoRojo proc  ;; proceso de pintar globo rojo
         posicionar 10, 5
         imprimeCaracter simboloGlobo, 4  
        
            ret    
     globoRojo endp         
 
                 
    pintarGlobos:   ;; se llaman los procesos de pintado
           call globoRojo
           call globoVerde
           call globoAzul
           call globoYellow
           call derrotaButton
           call reiniciarButton 
           call salirButton
           jmp iniciarMouse 
  
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
        imprime salto
        imprime space 
        imprime space
        imprime space
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
        mov ax, 0003h  ;; 40x25 16 colores
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