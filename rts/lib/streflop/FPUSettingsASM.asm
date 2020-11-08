; msvc doesn't allowed inline asm in x64 compiles

section .text
global _streflop_fstcw
global _streflop_fldcw

_streflop_fstcw:
  push    rbp
  mov     rbp, rsp
  fstcw   [rbp-2]
  movzx   eax, WORD [rbp-2]
  pop     rbp
  ret

_streflop_fldcw:
  push    rbp
  mov     rbp, rsp
  mov     eax, edi
  mov     [rbp-20], ax
  movzx   eax, WORD [rbp-20]
  mov     [rbp-2], ax
  fclex 
  fldcw   [rbp-2]
  nop
  pop     rbp
  ret