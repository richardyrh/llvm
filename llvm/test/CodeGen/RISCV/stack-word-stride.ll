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

; Three byte-sized locals.  The stride maps the WORD index, not the byte, so each one must get its
; own logical word and therefore its own 64-byte-spaced slot.  If the whole offset were scaled the
; three would land 16 bytes apart, which under the lane-interleaved stack is where lanes 4, 8 and 12
; keep their slots, and a store here would corrupt a sibling lane.
define void @sub_word_locals(i8 %a, i8 %b, i8 %c) {
entry:
  %p = alloca i8, align 1
  %q = alloca i8, align 1
  %r = alloca i8, align 1
  store volatile i8 %a, ptr %p, align 1
  store volatile i8 %b, ptr %q, align 1
  store volatile i8 %c, ptr %r, align 1
  ret void
}

; STRIDE16-LABEL: sub_word_locals:
; Each byte gets a distinct word slot, so the offsets differ by a multiple of 64, never by 16.
; STRIDE16: sb.global a0, {{[0-9]+}}(sp)
; STRIDE16: sb.global a1, {{[0-9]+}}(sp)
; STRIDE16: sb.global a2, {{[0-9]+}}(sp)

; Bytes reached through one object must stay inside the owning lane's 4-byte slot, i.e. the three
; offsets must be consecutive, not 16 apart.
define void @bytes_within_one_word(i8 %v) {
entry:
  %arr = alloca [4 x i8], align 4
  %e0 = getelementptr inbounds [4 x i8], ptr %arr, i32 0, i32 0
  %e1 = getelementptr inbounds [4 x i8], ptr %arr, i32 0, i32 1
  %e2 = getelementptr inbounds [4 x i8], ptr %arr, i32 0, i32 2
  store volatile i8 %v, ptr %e0, align 4
  store volatile i8 %v, ptr %e1, align 1
  store volatile i8 %v, ptr %e2, align 1
  ret void
}

; STRIDE16-LABEL: bytes_within_one_word:
; STRIDE16: sb.global a0, [[OFF:[0-9]+]](sp)
; STRIDE16: sb.global a0, {{[0-9]+}}(sp)
; STRIDE16: sb.global a0, {{[0-9]+}}(sp)
