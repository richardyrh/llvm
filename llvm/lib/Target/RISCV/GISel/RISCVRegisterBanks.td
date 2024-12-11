//=-- RISCVRegisterBank.td - Describe the RISCV Banks --------*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

/// Banks

/// General Purpose Registers: X.
def GPRBRegBank : RegisterBank<"GPRB", [GPR]>;

/// Floating Point Registers: F.
def FPRBRegBank : RegisterBank<"FPRB", [FPR64]>;

/// Vector Registers : V.
def VRBRegBank : RegisterBank<"VRB", [VRM8]>;

/// Stripes

/// Quad banked (striped) GPRs
def GPRSRegStripe0 : RegisterStripe<"GPRS0", [GPRB0]>;
def GPRSRegStripe1 : RegisterStripe<"GPRS1", [GPRB1]>;
def GPRSRegStripe2 : RegisterStripe<"GPRS2", [GPRB2]>;
def GPRSRegStripe3 : RegisterStripe<"GPRS3", [GPRB3]>;

/// Quad banked (striped) FPRs
def FPRSRegStripe0 : RegisterStripe<"FPRS0", [FPRB0]>;
def FPRSRegStripe1 : RegisterStripe<"FPRS1", [FPRB1]>;
def FPRSRegStripe2 : RegisterStripe<"FPRS2", [FPRB2]>;
def FPRSRegStripe3 : RegisterStripe<"FPRS3", [FPRB3]>;
