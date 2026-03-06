; RUN: llc -mtriple=riscv32 < %s | FileCheck %s --check-prefix=DEFAULT
; RUN: llc -mtriple=riscv32 -riscv-max-allocatable-gprs=32 < %s | FileCheck %s --check-prefix=MAX32
; RUN: not llc -mtriple=riscv32 -riscv-max-allocatable-gprs=48 < %s 2>&1 | FileCheck %s --check-prefix=BADVAL

@var = global [64 x i32] zeroinitializer

define void @foo() {
  %v = load volatile [64 x i32], ptr @var
  store volatile [64 x i32] %v, ptr @var
  ret void
}

; DEFAULT-LABEL: foo:
; DEFAULT: lw.global a8,

; MAX32-LABEL: foo:
; MAX32-NOT: a8
; MAX32: Folded Spill

; BADVAL: riscv-max-allocatable-gprs must be one of 32, 64, 128
