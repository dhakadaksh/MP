;Write an x86/64 ALP to accept the strng from user and display its length
;Uday Pratap Singh
;Date of performance: 27 Jan 2025

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
	msg1 db "Enter some string:",20H
	msg1len equ $-msg1
	msg2 db "The length is: ", 20H
	msg2len equ $-msg2
    msg3 db "Method 1: ", 10
	msg3len equ $-msg3
    msg4 db "Method 2: ", 10
	msg4len equ $-msg4
    newline db 10

section .bss
	strna resb 20
	len1 resb 1
	len2 resb 1
    lenca resb 2

section .code
	global _start
	_start:
		io 1,1,msg1,msg1len                               ;print msg1
        io 0,0,strna,20                                   ;read string input
														  ;length will be stored in rax
		dec rax                                           ;decrement rax by 1 for ignoring enter
		mov [len1],rax                                    ;move length to len1 variable

        io 1,1,msg3,msg3len                               ;print msg3
        io 1,1,msg2,msg2len                               ;print msg2
        mov bl,[len1]
        call hex_ascii64                                  ;call hex_ascii64 to print length value on screen after converting to ascii

        io 1,1,msg4,msg4len
        mov rcx,[len1]                                    ;move len1 value to rcx to run loop for each character
        next1:
            mov rsi,strna
            mov al,[rsi]
            cmp al,10                                     ;compare al value with 10h (newline character)
            jne inby                                      ;if al is not equal to 10 then jump to inby

            inby:
                inc byte[len2]
                loop next1
        io 1,1,msg2,msg2len
        mov bl,[len2]
        call hex_ascii64
		exit

    hex_ascii64:                                           ;convert hex value stored in rbx to ascii characters and print
        mov rsi,lenca                                      ;move length of string into rsi
        mov rcx,2                                          ;store 2 in rcx to loop to 2 times
        
        next2: 	
            rol bl,4                                       ;rotate bl value by 4 to avoid changing already processed value
            mov al,bl                                      ;move bl value to al
            and al,0fh                                     ;get only the last 4 bits by and with 0fh (0000 1111)
            cmp al,9                                       ;check if al value is less than 9   
            jbe add30h                                     ;if al <= 9 then add 30
            add al,7H                                      ;otherwise add 7 before adding 30
            
            add30h: 
                add al,30H
                mov [rsi],al
                inc rsi
        loop next2
            io 1,1,lenca,2
            io 1,1,newline,1
        ret
