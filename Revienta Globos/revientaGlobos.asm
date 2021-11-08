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
   
  ;; Variables del menu
  opcion db 0
  dato1 db 1
  dato2 db 2
  
  ;; Salto de Linea
  salto db 13,10, '$'
  
  
  ;; Variables de los jugadores   
  jugador1 db 10 dup(?), '$'
  jugador2 db 10 dup(?), '$'
      
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
        
        imprimir_str1:
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
        
        imprimir_str2:
            imprime salto
            mov ah, 09
            lea dx, jugador2
            int 21h    
            
        salir:
            jmp menu       
          
    juego:  ;; funciona para implementar el juego
      imprime jugando 
      je pedir_nombres 
                 
    salgo:  ;; sale del juego
      imprime despedida
      .exit