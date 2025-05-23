//===-- RISCVCallingConv.td - Calling Conventions RISC-V ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the calling conventions for the RISC-V architecture.
//
//===----------------------------------------------------------------------===//

// The RISC-V calling convention is handled with custom code in
// RISCVISelLowering.cpp (CC_RISCV).

def CSR_ILP32E_LP64E : CalleeSavedRegs<(add X1, X8, X9)>;

def CSR_ILP32_LP64
    : CalleeSavedRegs<(add CSR_ILP32E_LP64E,
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
def CSR_Interrupt : CalleeSavedRegs<(add X1, (sequence "X%u", 5, 127))>;

// Same as CSR_Interrupt, but including all 32-bit FP registers.
def CSR_XLEN_F32_Interrupt: CalleeSavedRegs<(add CSR_Interrupt,
                                             (sequence "F%u_F", 0, 63))>;

// Same as CSR_Interrupt, but including all 64-bit FP registers.
def CSR_XLEN_F64_Interrupt: CalleeSavedRegs<(add CSR_Interrupt,
                                             (sequence "F%u_D", 0, 63))>;

// Same as CSR_Interrupt, but excluding X16-X31.
def CSR_Interrupt_RVE : CalleeSavedRegs<(sub CSR_Interrupt,
                                        (sequence "X%u", 16, 31))>;

// Same as CSR_XLEN_F32_Interrupt, but excluding X16-X31.
def CSR_XLEN_F32_Interrupt_RVE: CalleeSavedRegs<(sub CSR_XLEN_F32_Interrupt,
                                                (sequence "X%u", 16, 31))>;

// Same as CSR_XLEN_F64_Interrupt, but excluding X16-X31.
def CSR_XLEN_F64_Interrupt_RVE: CalleeSavedRegs<(sub CSR_XLEN_F64_Interrupt,
                                                (sequence "X%u", 16, 31))>;
