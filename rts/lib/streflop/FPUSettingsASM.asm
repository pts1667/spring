; masm file

.CODE

_streflop_fstcw PROC PUBLIC input:QWORD
  fstcw WORD PTR input
  ret
_streflop_fstcw ENDP

_streflop_fldcw PROC PUBLIC input:QWORD
  fclex
  fldcw WORD PTR input
  ret
_streflop_fldcw ENDP

_streflop_stmxcsr PROC PUBLIC input:QWORD
  stmxcsr DWORD PTR input
  ret
_streflop_stmxcsr ENDP

_streflop_ldmxcsr PROC PUBLIC input:QWORD
  ldmxcsr DWORD PTR input
  ret
_streflop_ldmxcsr ENDP
END