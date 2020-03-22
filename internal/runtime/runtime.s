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

// http://man7.org/linux/man-pages/man2/clone.2.html
// The raw system call interface is:
//       long clone(unsigned long flags, void *stack,
//                  int *parent_tid, int *child_tid,
//                  unsigned long tls);
iruntime.clone:
  #movq %rdi, %rdi # cloneFlag
  #movq %rsi, %rsi # stk

  movq %rdx, %r12 # mstart

  movq $0, %rdx # parent_tid
  movq $0, %r10 # child_tid
  movq $0, %r8  # tls or regs
  movq $0, %r9
  movq $56, %rax # Syscall number (sys_clone)
  syscall
  cmp	$0, %rax
  je	.child # jmp if child
  ret # return if parent

.child:
    call *%r12 # call iruntime.mstart
    mov $0, %rdi
    mov $60, %rax # exit
    syscall


iruntime.mstart:
  call iruntime.getTask
  call *%rax
  ret
