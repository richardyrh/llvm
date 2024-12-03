//===-- RISCVCallingConv.td - Calling Conventions RISCV ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the RISCV architecture.
//
//===----------------------------------------------------------------------===//

// The RISC-V calling convention is handled with custom code in
// RISCVISelLowering.cpp (CC_RISCV).

def CSR_ILP32_LP64
    : CalleeSavedRegs<(add X1, X3, X4, X8, X9,
    (sequence "X%u", 18, 27), // s2-s11
    (sequence "X%u", 48, 95) // s12-s59
    )>;

def CSR_ILP32F_LP64F
    : CalleeSavedRegs<(add CSR_ILP32_LP64,
                       F8_F, F9_F,                 // fs0-fs1
                       (sequence "F%u_F", 18, 27), // fs2-fs11
                       (sequence "F%u_F", 40, 51)  // fs12-fs23
                       )>;

def CSR_ILP32D_LP64D
    : CalleeSavedRegs<(add CSR_ILP32_LP64,
                       F8_D, F9_D,
                       (sequence "F%u_D", 18, 27),
                       (sequence "F%u_D", 40, 51)
                       )>;

// Needed for implementation of RISCVRegisterInfo::getNoPreservedMask()
def CSR_NoRegs : CalleeSavedRegs<(add)>;

// Interrupt handler needs to save/restore all registers that are used,
// both Caller and Callee saved registers.
def CSR_Interrupt : CalleeSavedRegs<(add X1,
    (sequence "X%u", 3, 9),    // gp, tp, t0-t2, s0-s1
    (sequence "X%u", 10, 11),  // a0-a1
    (sequence "X%u", 12, 17),  // a2-a7
    (sequence "X%u", 32, 47),  // a8-a23
    (sequence "X%u", 18, 27),  // s2-s11
    (sequence "X%u", 48, 95),  // s12-s59
    (sequence "X%u", 28, 31),  // t3-t6
    (sequence "X%u", 96, 127)  // t7-t38
    )>;

// Same as CSR_Interrupt, but including all 32-bit FP registers.
def CSR_XLEN_F32_Interrupt: CalleeSavedRegs<(add X1,
    (sequence "X%u", 3, 9),
    (sequence "X%u", 10, 11),
    (sequence "X%u", 12, 17),
    (sequence "X%u", 32, 47),   // a8-a23
    (sequence "X%u", 18, 27),
    (sequence "X%u", 48, 95),   // s12-s59
    (sequence "X%u", 28, 31),
    (sequence "X%u", 96, 127),  // t7-t38
    (sequence "F%u_F", 0, 7),
    (sequence "F%u_F", 10, 11), // fa0-fa1
    (sequence "F%u_F", 12, 17), // fa2-fa7
    (sequence "F%u_F", 32, 39), // fa8-fa15
    (sequence "F%u_F", 28, 31), // ft8-ft11
    (sequence "F%u_F", 52, 63), // ft12-ft23
    (sequence "F%u_F", 8, 9),   // fs0-fs1
    (sequence "F%u_F", 18, 27), // fs2-fs11
    (sequence "F%u_F", 40, 51)  // fs12-fs23
    )>;

// Same as CSR_Interrupt, but including all 64-bit FP registers.
def CSR_XLEN_F64_Interrupt: CalleeSavedRegs<(add X1,
    (sequence "X%u", 3, 9),
    (sequence "X%u", 10, 11),
    (sequence "X%u", 12, 17),
    (sequence "X%u", 32, 47),   // a8-a23
    (sequence "X%u", 18, 27),
    (sequence "X%u", 48, 95),   // s12-s59
    (sequence "X%u", 28, 31),
    (sequence "X%u", 96, 127),  // t7-t38
    (sequence "F%u_D", 0, 7),
    (sequence "F%u_D", 10, 11), // fa0-fa1
    (sequence "F%u_D", 12, 17), // fa2-fa7
    (sequence "F%u_D", 32, 39), // fa8-fa15
    (sequence "F%u_D", 28, 31), // ft8-ft11
    (sequence "F%u_D", 52, 63), // ft12-ft23
    (sequence "F%u_D", 8, 9),   // fs0-fs1
    (sequence "F%u_D", 18, 27), // fs2-fs11
    (sequence "F%u_D", 40, 51)  // fs12-fs23
    )>;
