#ifndef LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H
#define LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/IR/Analysis.h"
#include "llvm/IR/PassManager.h"
#include <memory>

namespace llvm {

class AnalysisUsage;
class MachineFunction;
class RegisterBankInfo;
class TargetRegisterInfo;

class RegBankConflictMatrix {
  friend class RegBankConflictMatrixWrapperLegacy;
  friend class RegBankConflictMatrixAnalysis;
  const TargetRegisterInfo *TRI = nullptr;
  const RegisterBankInfo *RBI = nullptr;

  // The matrix is represented as a set per register unit.
  DenseMap<Register, SmallSet<Register, 4>> Matrix;

  RegBankConflictMatrix() = default;
  void identifyBankConstraints(MachineFunction &MF);

public:
  RegBankConflictMatrix(RegBankConflictMatrix &&Other)
      : TRI(Other.TRI),
        Matrix(std::move(Other.Matrix)) {}

  void init(MachineFunction &MF);
  SmallSet<Register, 4> getConflictingRegs(Register reg);
};

class RegBankConflictMatrixWrapperLegacy : public MachineFunctionPass {
  RegBankConflictMatrix RBCM;

public:
  static char ID;

  RegBankConflictMatrixWrapperLegacy() : MachineFunctionPass(ID) {}

  RegBankConflictMatrix &getRBCM() { return RBCM; }
  const RegBankConflictMatrix &getRBCM() const { return RBCM; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override {
    RBCM.init(MF);
    return false;
  }

};

class RegBankConflictMatrixAnalysis : public AnalysisInfoMixin<RegBankConflictMatrixAnalysis> {
  friend AnalysisInfoMixin<RegBankConflictMatrixAnalysis>;
  static AnalysisKey Key;

public:
  using Result = RegBankConflictMatrix;

  RegBankConflictMatrix run(MachineFunction &MF, MachineFunctionAnalysisManager &MFAM);
};

} // end namespace llvm

#endif // LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H
