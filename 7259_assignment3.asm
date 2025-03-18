;Assignment 3
;Write x86/64 ALP to perform the following arithmetic operations:
; 1. Addition
; 2. Subtraction
; 3. Multiplication
; 4. division

%macro io 4                                            ;macro for input/output operations
	mov rax,%1
	mov rdi,%2
	mov rsi,%3
	mov rdx,%4
	syscall
%endmacro

%macro exit 0                                          ;macro to exit program
	mov rax,60
	mov rdi,0
	syscall
%endmacro

section .data
	msg1 db "Enter first 64-bit number:",10
	msg1len equ $-msg1
	
	msg2 db "Enter second 64-bit number:",10
	msg2len equ $-msg2
	
	menu db "Menu:",10,"1. Addition",10,"2. Subtraction",10,"3. Multiplication",10,"4. Division",10,"5. Exit",10
	menulen equ $-menu
	
	msg4 db "Enter your choice: ",10
	msg4len equ $-msg4
	
	newline db 10
	
section .bss
	num resb 17
	choice resb 2
	num1 resq 1
	num2 resq 1
	
section .code
	global _start
	_start:
		io 1,1,msg1,msg1len		                        ;print msg1
		io 0,0,num,17                                   ;take input in num variable		
		call ascii_hex64
		mov qword[num1], rbx
		
		call hex_ascii64                                ;print num1
		io 1,1,newline,1
		
		io 1,1,msg2,msg2len                             ;print msg2
		
		io 0,0,num,17                                   ;take input in num variable
		call ascii_hex64
		mov qword[num2], rbx
		
		call hex_ascii64                                ;print num2
		io 1,1,newline,1
		
		io 1,1,menu,menulen                             ;print the menu
		io 0,0,choice,2                                 ;take input in variable choice
		
		case1:
			cmp byte[choice], "1"
			jne case2
			io 1,1,"1.",2
			
		case2:
			cmp byte[choice], "2"
			jne case3
			io 1,1,"2.",2
		
		case3:
			cmp byte[choice], "3"
			jne case4
			io 1,1,"3.",2
		
		case4:
			cmp byte[choice], "4"
			jne case5
			io 1,1,"4.",2			
			
		case5:
			exit
		
		ascii_hex64:
            mov rsi, num                                ;copy ascii input to rsi register
            mov rbx,0                                   ;initialise rbx as 0 
            mov rcx,16                                  ;set rcx to 16 since we have 16 hex digits
                                                        ;so our loop needs to run 16 times
            next3:
                rol rbx,4                               ;rotate bits by 4 places to the left
                                                        ;to preserve already processed digits
                mov al,[rsi]                            ;copy 1 character (1byte) from rsi to al to process
                                                        ;1 hex digitrepresented by 8 bit ascii code
                
                   

                operations:                           
                    cmp al,39h                          ;if ascii code <= 39h (for 0-9) we need 
                                                        ;to subtract 30h
                    jbe sub30h                          ;jump to sub30h procedure

                    cmp al,46h                          ;if ascii code <= 46h (for A-F) we need
                                                        ;to subtract 37h (7h followed by 30h)
                    jbe sub7h                           ;jump to sub7h procedure

                    sub al,20h                          ;if both previous conditions are false then we
                                                        ;have a-f so we need to subtract total 57h
                                                        ;(20h followed by 7h and 30h)

                    sub7h:
                        sub al,7h

                    sub30h:
                        sub al,30h

                    skip:
                        add bl,al
                        inc rsi
                        loop next3
            ret
        hex_ascii64:
            mov rsi,num
            mov rcx,16                                  ;set rcx to 16 since we have 16 hex digits
                                                        ;so our loop needs to run 16 times
            next4:
                rol rbx,4                               ;rotate bits by 4 places to the left
                                                        ;to preserve already processed digits

                mov al,bl
                and al,0fh                              ;and with 0000 1111 (0fh) to get 1 hex digit

                cmp al,9                                ;if digit <= 9
                jbe add30h                              ;jump to add30h procedure to convert digit to 
                                                        ;equivalent ascii value

                add al,7h                               ;if digit is (A-F) then we nedd to add 37h
                                                        ;(7h followed by 30h)
                add30h:
                    add al,30h                          ;add 30h to convert hex digit to its equivalent
                                                        ;ascii value
                    mov [rsi],al
                    inc rsi
                    loop next4
                    
            io 1,1,num,16
            ret
