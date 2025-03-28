//===-- RISCV.h - Top-level interface for RISC-V ----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// RISC-V back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCV_H
#define LLVM_LIB_TARGET_RISCV_RISCV_H

#include "MCTargetDesc/RISCVBaseInfo.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class ModulePass;
class FunctionPass;
class ModulePass;
class InstructionSelector;
class PassRegistry;
class RISCVRegisterBankInfo;
class RISCVSubtarget;
class RISCVTargetMachine;

FunctionPass *createRISCVCodeGenPreparePass();
void initializeRISCVCodeGenPreparePass(PassRegistry &);

FunctionPass *createRISCVDeadRegisterDefinitionsPass();
void initializeRISCVDeadRegisterDefinitionsPass(PassRegistry &);

FunctionPass *createRISCVISelDag(RISCVTargetMachine &TM,
                                 CodeGenOptLevel OptLevel);

FunctionPass *createRISCVMakeCompressibleOptPass();
void initializeRISCVMakeCompressibleOptPass(PassRegistry &);

FunctionPass *createRISCVGatherScatterLoweringPass();
void initializeRISCVGatherScatterLoweringPass(PassRegistry &);

FunctionPass *createRISCVFoldMasksPass();
void initializeRISCVFoldMasksPass(PassRegistry &);

FunctionPass *createRISCVOptWInstrsPass();
void initializeRISCVOptWInstrsPass(PassRegistry &);

FunctionPass *createRISCVMergeBaseOffsetOptPass();
void initializeRISCVMergeBaseOffsetOptPass(PassRegistry &);

FunctionPass *createRISCVExpandPseudoPass();
void initializeRISCVExpandPseudoPass(PassRegistry &);

FunctionPass *createRISCVPreRAExpandPseudoPass();
void initializeRISCVPreRAExpandPseudoPass(PassRegistry &);

FunctionPass *createRISCVExpandAtomicPseudoPass();
void initializeRISCVExpandAtomicPseudoPass(PassRegistry &);

FunctionPass *createRISCVInsertVSETVLIPass();
void initializeRISCVInsertVSETVLIPass(PassRegistry &);

FunctionPass *createRISCVPostRAExpandPseudoPass();
void initializeRISCVPostRAExpandPseudoPass(PassRegistry &);
FunctionPass *createRISCVInsertReadWriteCSRPass();
void initializeRISCVInsertReadWriteCSRPass(PassRegistry &);

FunctionPass *createRISCVInsertWriteVXRMPass();
void initializeRISCVInsertWriteVXRMPass(PassRegistry &);

FunctionPass *createRISCVRedundantCopyEliminationPass();
void initializeRISCVRedundantCopyEliminationPass(PassRegistry &);

FunctionPass *createRISCVInitUndefPass();
void initializeRISCVInitUndefPass(PassRegistry &);
extern char &RISCVInitUndefID;

FunctionPass *createRISCVMoveMergePass();
void initializeRISCVMoveMergePass(PassRegistry &);

FunctionPass *createRISCVPushPopOptimizationPass();
void initializeRISCVPushPopOptPass(PassRegistry &);

InstructionSelector *createRISCVInstructionSelector(const RISCVTargetMachine &,
                                                    RISCVSubtarget &,
                                                    RISCVRegisterBankInfo &);
void initializeRISCVDAGToDAGISelPass(PassRegistry &);

FunctionPass *createRISCVPostLegalizerCombiner();
void initializeRISCVPostLegalizerCombinerPass(PassRegistry &);

FunctionPass *createRISCVO0PreLegalizerCombiner();
void initializeRISCVO0PreLegalizerCombinerPass(PassRegistry &);

FunctionPass *createVortexBranchDivergence0Pass();
void initializeVortexBranchDivergence0Pass(PassRegistry&);

FunctionPass *createVortexBranchDivergence1Pass(int divergenceMode = 0);
void initializeVortexBranchDivergence1Pass(PassRegistry&);

FunctionPass *createVortexBranchDivergence2Pass(int PassMode);
void initializeVortexBranchDivergence2Pass(PassRegistry&);

ModulePass *createVortexIntrinsicFuncLoweringPass();
void initializeVortexIntrinsicFuncLoweringPass(PassRegistry&);

FunctionPass *createRISCVPreLegalizerCombiner();
void initializeRISCVPreLegalizerCombinerPass(PassRegistry &);
} // namespace llvm

#endif
