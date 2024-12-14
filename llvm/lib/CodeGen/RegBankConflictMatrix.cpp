//===- RegBankConflictMatrix.cpp - Track register interference --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the RegBankConflictMatrix analysis pass.
//
//===----------------------------------------------------------------------===//
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/RegBankConflictMatrix.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>

using namespace llvm;

#define DEBUG_TYPE "regalloc"

char RegBankConflictMatrix::ID = 0;
INITIALIZE_PASS(RegBankConflictMatrix, "reg-bank-conflict-matrix",
                      "Register Bank Conflict Matrix", false, false)

void RegBankConflictMatrix::identifyBankConstraints(MachineFunction &MF) {
    for (auto &BB : MF) {
        for (auto &Instr : BB) {
            llvm::SmallVector<Register, 4> registers;

            for (auto &MO : Instr.operands()) {
                if (MO.isReg() && MO.getReg().isVirtual()) {
                    registers.push_back(MO.getReg());
                }
            }

            if (registers.size() > 1) {
                for (size_t i = 0; i < registers.size(); i++) {
                    for (size_t j = i + 1; j < registers.size(); j++) {
                        Register reg1 = registers[i];
                        Register reg2 = registers[j];

                        if(reg1 == reg2) continue;
                        // Mark interference in both directions
                        Matrix[reg1].insert(reg2);
                        Matrix[reg2].insert(reg1);
                    }
                }
            }
        }
    }
}

SmallSet<Register, 4> RegBankConflictMatrix::getConflictingRegs(Register reg) {
    return Matrix[reg];
}

void RegBankConflictMatrix::releaseMemory() {
   LLVM_DEBUG(dbgs() << "Releasing RegBankConflictMatrix memory\n");
   Matrix.clear();
}

RegBankConflictMatrix::RegBankConflictMatrix() : MachineFunctionPass(ID) {}

void RegBankConflictMatrix::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  MachineFunctionPass::getAnalysisUsage(AU);
}

bool RegBankConflictMatrix::runOnMachineFunction(MachineFunction &MF) {
  TRI = MF.getSubtarget().getRegisterInfo();
  RBI = MF.getSubtarget().getRegBankInfo();

  identifyBankConstraints(MF);

  LLVM_DEBUG(dbgs() << "RegBankConflictMatrix initialized\n");

  LLVM_DEBUG(dbgs() << "Register Bank Conflicts:\n");
  for (auto &Entry : Matrix) {
    Register Reg = Entry.first;
    const SmallSet<Register, 4> &Conflicts = Entry.second;
    if (!Conflicts.empty()) {
      LLVM_DEBUG(dbgs() << "  Reg " << printReg(Reg, TRI) << " conflicts with: ");
      for (Register ConflictReg : Conflicts) {
        LLVM_DEBUG(dbgs() << printReg(ConflictReg, TRI) << " ");
      }
      LLVM_DEBUG(dbgs() << "\n");
    }
  }

  return false;
}
