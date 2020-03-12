// iruntime
.text
iruntime.makeSlice:
  FUNC_PROLOGUE

  PUSH_ARG_2 # -8
  PUSH_ARG_1 # -16
  PUSH_ARG_0 # -24
  LOAD_8_FROM_LOCAL -16 # newcap
  PUSH_8
  LOAD_8_FROM_LOCAL -8 # unit
  PUSH_8
  IMUL_FROM_STACK
  ADD_NUMBER 1 # 1 byte buffer
  PUSH_8
  POP_TO_ARG_0
  FUNCALL iruntime.malloc
  mov -24(%rbp), %rbx # newlen
  mov -16(%rbp), %rcx # newcap
  LEAVE_AND_RET

// copied from https://sys.readthedocs.io/en/latest/doc/07_calling_system_calls.html
iruntime.Syscall:
  movq %rdi, %rax # Syscall number
  movq %rsi, %rdi # set arg1
  movq %rdx, %rsi # set arg2
  movq %rcx, %rdx # set arg3
  movq $0, %r10
  movq $0, %r8
  movq $0, %r9
  syscall
  cmpq $-4095, %rax
  ret
