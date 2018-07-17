; bootloader.asm
; A Simple Bootloader
;******************************************
org 0x7c00
bits 16
start: jmp boot
;;constant and variable definitions
msga db "Welcome to Max OS!", 0h
msgb db "Hihi", 0h
msgc db "A great way to spend a recurse batch...", 0h
msgd db "Kernel to come?", 0h

boot:
	cli ; no interrupts
	cld ; all that we need to init

	; light green on blue background
	mov bl, 0x9a
	; TODO: Why shouldn't this be [ds:si]?
	mov si, msga
	call write_str

	mov bh, 0x00
	mov dh, 0x0d
	mov dl, 0x04

	call move_cursor

	mov si, msgb

	; red on yellow
	mov bl, 0xe4
	call write_str

  mov bh, 0x00
  mov dh, 0x10
  mov dl, 0x08
  
  call move_cursor
  
  mov si, msgc
  
  ; random color
  mov bl, 0x79
  call write_str
  
  mov bh, 0x00
  mov dh, 0x14
  mov dl, 0x0a
  
  call move_cursor
  
  mov si, msgd
  ; random color
  mov bl, 0x5a
  call write_str

	; Interrupt 13 for reading from disk:
	; ah = 02
	; al = number of sectors to read (1-128 dec.)
	; ch = track/cylinder number (0-1023 dec., see below)
	; cl = sector number (1-17 dec.)
	; dh = head number (0-15 dec.)
	; dl = drive number (0=a:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
	; es:bx = pointer to buffer
	; return:
	; ah = status (see int 13,status)
	; al = number of sectors read
	; cf = 0 if successful
	; = 1 if error

	; location in memory for our buffer 
	mov ax, 0x50

	;; set the buffer
	mov es, ax
	xor bx, bx ; zero out bx

	mov al, 2 ; read 2 sector
	mov ch, 0 ; track 0
	mov cl, 2 ; sector to read (The second sector)
	mov dh, 0 ; head number
	mov dl, 0 ; drive number

	mov ah, 0x02 ; read sectors from disk
	int 0x13 ; call the BIOS routine
	jmp 0x500 ; jump and execute the sector!

	hlt ; halt the system

; Prints a character to screen from al
; Saves values from bx and ax
; ah is the 8 bit version of ax(!!)
; al = character, bh = page number, 
; bl = color, cx = number of times to print character
putc:
	push ax
	push cx
	mov bh, 0x00
	mov cx, 0x01
	mov ah, 0x09
	int 10h

	call get_cursor_pos
	inc dl
	call move_cursor

	pop cx
	pop ax

	ret

; Sets cursor position 
; bh = Page Number, dh = Row, dl = Column
move_cursor:
	push ax

	mov ah, 0x02

	int 10h

	pop ax
	
	ret
	
;Get cursor position and shape 	
; ah=03h 	bh = page number 	
; ax = 0, ch = start scan line, 
; cl = end scan line, dh = row, dl = column
get_cursor_pos:

	mov ah, 0x03

	int 10h

	ret

; Writes a string from memory region referenced to by si
write_str:
	; lodsb is really interesting. From http://faydoc.tripod.com/cpu/lodsb.htm:
	; After the byte, word, or doubleword is transferred from the memory location into the AL, AX, or EAX register, 
	; the (E)SI register is incremented or decremented automatically according to the setting of the DF flag in the EFLAGS register. 
	; (If the DF flag is 0, the (E)SI register is incremented; if the DF flag is 1, the ESI register is decremented.) 
	; The (E)SI register is incremented or decremented by 1 for byte operations, by 2 for word operations, or by 4 for doubleword operations.
	lodsb
	; tests al for a null character and if so, jumps to ret, otherwise loads
	; next byte with lodsb
	cmp al, 0x00
	jz end
	call putc
	jmp write_str

end:
	ret

; We have to be 512 bytes. Clear the rest of the bytes with
times 0x0200 - 2 - ($-$$) db 0 ; the -2 is for the 2 bytes of boot signature
dw 0xAA55 ; Boot Signature
