; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)
extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

size_x:		resq	1
size_y:		resq	1

size2_x:		resd	1
size2_y:		resd	1

x:  resd    1
y:  resd    1

c_r:    resq    1
c_i:    resq    1
z_r:    resq    1
z_i:    resq    1
tmp:    resq    1

var:    resq    1

section .data

event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0

size_x1:	dd	-2.1
size_x2:	dd	0.6
size_y1:	dd	-1.2
size_y2:	dd	1.2

zoom:		dd	100.0

iteration_max:	dq	50

i:  dq  0

cpt:    dq  0
cpt2:    dq  0
cpt3:    dq  0

print:	db	"--%f---%f--", 10, 0
printi: db  "----%d----", 10, 0
printi2: db  "----%d----%d---", 10, 0
aled:   db  "aaaaaaaaa", 10, 0

section .text

;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
;calcul size_x
cvtss2sd xmm0, dword[size_x2]
cvtss2sd xmm1, dword[size_x1]
subsd xmm0, xmm1
cvtss2sd xmm1, dword[zoom]
mulsd xmm0, xmm1
movsd qword[size_x], xmm0
movsd xmm0, qword[size_x]
movsd xmm1, qword[size_y]

;calcul size_y
cvtss2sd xmm0, dword[size_y2]
cvtss2sd xmm1, dword[size_y1]
subsd xmm0, xmm1
cvtss2sd xmm1, dword[zoom]
mulsd xmm0, xmm1
movsd qword[size_y], xmm0

cvtsd2si rax, qword[size_x]
mov qword[size_x], rax
cvtsd2si rax, qword[size_y]
mov qword[size_y], rax

push rbp
mov rdi, printi2
mov rsi, qword[size_x]
mov rdx, qword[size_y]
mov rax, 0
call printf
pop rbp

xor    rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,qword[size_x]	; largeur
mov r9,qword[size_y]	; hauteur

push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:

mov dword[x], 0
for_image_x:
mov dword[y], 0
for_image_y:
add qword[cpt], 1
;c_r = size_x / zoom + size_x1
movsd xmm0, qword[size_x]
cvtss2sd xmm1, dword[zoom]
divsd xmm0, xmm1
cvtss2sd xmm1, dword[size_x1]
addsd xmm0, xmm1
movsd qword[c_r], xmm0
        
;c_i = size_y / zoom + size_y1
movsd xmm0, qword[size_y]
cvtss2sd xmm1, dword[zoom]
divsd xmm0, xmm1
cvtss2sd xmm1, dword[size_y1]
addsd xmm0, xmm1
movsd qword[c_i], xmm0

;z_r = 0
mov qword[z_r], 0

;z_i = 0
mov qword[z_i], 0

;i = 0
mov qword[i], 0

do_while:
add qword[cpt2], 1

mov rax, qword[z_r]
mov qword[tmp], rax

;z_r = z_r*z_r - z_i*z_i + c_r
movsd xmm0, qword[z_r]
mulsd xmm0, xmm0
movsd xmm1, qword[z_i]
mulsd xmm1, xmm1
subsd xmm0, xmm1
addsd xmm0, qword[c_r]

movsd xmm0, qword[z_i]
mov qword[var], 2
mulsd xmm0, qword[var]
mulsd xmm0, qword[tmp]
addsd xmm0, qword[c_i]

add qword[i], 1

movsd xmm0, qword[z_r]
mulsd xmm0, xmm0
movsd xmm1, qword[z_i]
mulsd xmm1, xmm1
addsd xmm0, xmm1
mov qword[var], 4
cvtsi2sd xmm1, qword[var]
ucomisd xmm0, xmm1
jae end_while

mov rbx, qword[i]
cmp rbx, qword[iteration_max]
jb do_while

end_while:

mov rbx, qword[i]
;push rbp
;mov rdi, printi2
;mov rsi, rbx
;mov rdx, qword[iteration_max]
;mov rax, 0
;call printf
;pop rbp
cmp rbx, qword[iteration_max]
ja no_if
jb no_if
add qword[cpt3], 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x]	; coordonnée source en x
mov r8d,dword[y]	; coordonnée source en y
call XDrawPoint

no_if:

movsd xmm0, qword[size_y]
cvtsi2sd xmm1, dword[y]
add dword[y], 1
ucomisd xmm1, xmm0
jb for_image_y

movsd xmm0, qword[size_x]
cvtsi2sd xmm1, dword[x]
add dword[x], 1
ucomisd xmm1, xmm0
jb for_image_x

; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall
ret

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
