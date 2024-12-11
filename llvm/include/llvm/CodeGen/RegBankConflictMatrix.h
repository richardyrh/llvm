#ifndef LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H
#define LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/CodeGen/MachineFunctionPass.h"

namespace llvm {

class AnalysisUsage;
class MachineFunction;
class RegisterBankInfo;
class TargetRegisterInfo;

class RegBankConflictMatrix : public MachineFunctionPass {
  const TargetRegisterInfo *TRI = nullptr;
  const RegisterBankInfo *RBI = nullptr;

  // The matrix is represented as a set per register unit.
  DenseMap<Register, SmallSet<Register, 4>> Matrix;

  void identifyBankConstraints(MachineFunction &MF);

public:
  static char ID;
  RegBankConflictMatrix();

  SmallSet<Register, 4> getConflictingRegs(Register reg);
  
  void getAnalysisUsage(AnalysisUsage &) const override;
  bool runOnMachineFunction(MachineFunction &) override;
};


} // end namespace llvm

#endif // LLVM_CODEGEN_REGBANKCONFLICTMATRIX_H
