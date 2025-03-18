;Assignment 1
;Write an x86/64 ALP to accept 5 hexadecimal numbers from user and store them in an array and display the accepted numbers

;Uday Pratap Singh
;Date of performance: 20 Jan, 2025

%macro io 4
	mov rax,%1
	mov rdi,%2
	mov rsi,%3
	mov rdx,%4
	syscall
%endmacro

%macro exit 0
	mov rax,60
	mov rdi,0
	syscall
%endmacro

section .data
	msg1 db "Write an x86/64 ALP to accept 5 hexadecimal numbers from user and store them in an array and display the accepted numbers",10
	msg1len equ $-msg1
	msg2 db "Enter 5 64bit hexadecimal numbers (0-9,A-F only): ", 10
	msg2len equ $-msg2
    msg3 db "5 64bit hexadecimal numbers are: ", 10
	msg3len equ $-msg3
    newline db 10
    errMsg db "You entered a wrong hexadecimal number"
    errLen equ $-errMsg

section .bss
	asciinum resb 17
	hexnum resq 5

section .code
	global _start
	_start:
        io 1,1,msg1,msg1len                           ;print msg1
        io 1,1,msg2,msg2len                           ;print msg2
        mov rcx,5                                     ;store 5 in rcx to loop 5 times
        mov rsi,hexnum                                
        next1:
            push rsi                                  ;push rsi and rcx to stack
            push rcx                                  ;to preserve their values
            io 0,0,asciinum,17                        ;take 64 bit hex number as input
                                                      ;(16 hex digits)
            call ascii_hex64                          ;convert ascii input to hex code
            pop rcx                                   ;retrieve rcx and rsi values from stack
            pop rsi
            mov [rsi],rbx                             ;hex number stored in rbx is moved to 
                                                      ;location of rsi pointer
            add rsi,8                                 ;move rsi pointer by 8 bytes (64 bits)
            loop next1
        
        io 1,1,msg3,msg3len                           ;print msg3
        mov rsi,hexnum                                ;move stored hex number to rsi
        mov rcx,5                                     ;store 5 in rcx to loop 5 times
        next2:
            mov rbx,[rsi]                             ;copy rsi value to rbx for operations
            push rsi                                  ;push rsi and rcx values to stack
            push rcx                                  ;in order to preserve them
            
            call hex_ascii64
            pop rcx                                   ;retrieve rcx and rsi values from stack
            pop rsi
            add rsi,8                                 ;move rsi pointer by 8 bytes (64 bits)
            loop next2
        
        exit

        ascii_hex64:
            mov rsi, asciinum                         ;copy ascii input to rsi register
            mov rbx,0                                 ;initialise rbx as 0 
            mov rcx,16                                ;set rcx to 16 since we have 16 hex digits
                                                      ;so our loop needs to run 16 times
            next3:
                rol rbx,4                             ;rotate bits by 4 places to the left
                                                      ;to preserve already processed digits
                mov al,[rsi]                          ;copy 1 character (1byte) from rsi to al to process
                                                      ;1 hex digitrepresented by 8 bit ascii code
                
                                                      ;CHECKING FOR INVALID HEX
                                                      ;valid hex contains 0-9 (30h-39h)
                                                      ;or A-F (41h to 46h)
                                                      ;or a-f (61h to 67h)

                cmp al,29h                            ;if ascii code of character <= 29h it is not valid
                jbe err                               ;jump to err procedure

                cmp al,40h                            ;if ascii code of character == 40h it is not valid
                je err                                ;jump to err procedure

                cmp al,67h                            ;if ascii code of character >=67h it is not valid
                jge err                               ;jump to err procedure

                cmp al,47h                            ;if ascii code of character >=47h we need to
                                                      ;do further checks to verify if it is valid
                jge checkfurther                      
                jmp operations 
                checkfurther:
                    cmp al,60h                        ;if ascii code >= 47h and <=60h then it is invalid
                    jbe err                           ;jump to err procedure

                operations:                           ;CONVERTING VALID ASCII TO HEX
                    cmp al,39h                        ;if ascii code <= 39h (for 0-9) we need 
                                                      ;to subtract 30h
                    jbe sub30h                        ;jump to sub30h procedure

                    cmp al,46h                        ;if ascii code <= 46h (for A-F) we need
                                                      ;to subtract 37h (7h followed by 30h)
                    jbe sub7h                         ;jump to sub7h procedure

                    sub al,20h                        ;if both previous conditions are false then we
                                                      ;have a-f so we need to subtract total 57h
                                                      ;(20h followed by 7h and 30h)

                    sub7h:
                        sub al,7h

                    sub30h:
                        sub al,30h
                    jmp skip                          ;if there is no error then jump to skip procedure

                    err:
                        io 1,1,errMsg,errLen
                        io 1,1,newline,1
                        exit
                    skip:
                        add bl,al
                        inc rsi
                        loop next3
            ret
        hex_ascii64:
            mov rsi,asciinum
            mov rcx,16                                ;set rcx to 16 since we have 16 hex digits
                                                      ;so our loop needs to run 16 times
            next4:
                rol rbx,4                             ;rotate bits by 4 places to the left
                                                      ;to preserve already processed digits

                mov al,bl
                and al,0fh                            ;and with 0000 1111 (0fh) to get 1 hex digit

                cmp al,9                              ;if digit <= 9
                jbe add30h                            ;jump to add30h procedure to convert digit to 
                                                      ;equivalent ascii value

                add al,7h                             ;if digit is (A-F) then we nedd to add 37h
                                                      ;(7h followed by 30h)
                add30h:
                    add al,30h                        ;add 30h to convert hex digit to its equivalent
                                                      ;ascii value
                    mov [rsi],al
                    inc rsi
                    loop next4
            
            io 1,1,asciinum,16
            io 1,1,newline,1
            ret
