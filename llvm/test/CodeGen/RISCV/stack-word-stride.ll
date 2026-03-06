; RUN: llc -mtriple=riscv32 < %s | FileCheck %s --check-prefix=DEFAULT
; RUN: llc -mtriple=riscv32 -riscv-stack-word-stride=16 < %s | FileCheck %s --check-prefix=STRIDE16

define i32 @stack_word_stride(i32 %x) {
entry:
  %p = alloca i32, align 4
  store volatile i32 %x, ptr %p, align 4
  %y = load volatile i32, ptr %p, align 4
  ret i32 %y
}

; DEFAULT-LABEL: stack_word_stride:
; DEFAULT: addi sp, sp, -16
; DEFAULT: sw.global a0, 12(sp)
; DEFAULT: lw.global a0, 12(sp)
; DEFAULT: addi sp, sp, 16

; STRIDE16-LABEL: stack_word_stride:
; STRIDE16: addi sp, sp, -256
; STRIDE16: sw.global a0, 192(sp)
; STRIDE16: lw.global a0, 192(sp)
; STRIDE16: addi sp, sp, 256
