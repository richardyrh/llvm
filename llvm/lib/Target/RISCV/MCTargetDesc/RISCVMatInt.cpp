//===- RISCVMatInt.cpp - Immediate materialisation -------------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "RISCVMatInt.h"
#include "MCTargetDesc/RISCVMCTargetDesc.h"
#include "llvm/ADT/APInt.h"
#include "llvm/Support/MathExtras.h"
using namespace llvm;

static int getInstSeqCost(RISCVMatInt::InstSeq &Res, bool HasRVC) {
  if (!HasRVC)
    return Res.size();

  int Cost = 0;
  for (auto Instr : Res) {
    // Assume instructions that aren't listed aren't compressible.
    bool Compressed = false;
    switch (Instr.getOpcode()) {
    case RISCV::SLLI:
    case RISCV::SRLI:
      Compressed = true;
      break;
    case RISCV::ADDI:
    case RISCV::ADDIW:
    case RISCV::LUI:
      Compressed = isInt<6>(Instr.getImm());
      break;
    }
    // Two RVC instructions take the same space as one RVI instruction, but
    // can take longer to execute than the single RVI instruction. Thus, we
    // consider that two RVC instruction are slightly more costly than one
    // RVI instruction. For longer sequences of RVC instructions the space
    // savings can be worth it, though. The costs below try to model that.
    if (!Compressed)
      Cost += 100; // Baseline cost of one RVI instruction: 100%.
    else
      Cost += 70; // 70% cost of baseline.
  }
  return Cost;
}

// Recursively generate a sequence for materializing an integer.
static void generateInstSeqImpl(int64_t Val,
                                const FeatureBitset &ActiveFeatures,
                                RISCVMatInt::InstSeq &Res) {
  bool IsRV64 = ActiveFeatures[RISCV::Feature64Bit];

  // Use BSETI for a single bit that can't be expressed by a single LUI or ADDI.
  if (ActiveFeatures[RISCV::FeatureStdExtZbs] && isPowerOf2_64(Val) &&
      (!isInt<32>(Val) || Val == 0x800)) {
    Res.emplace_back(RISCV::BSETI, Log2_64(Val));
    return;
  }

  if (isInt<32>(Val)) {
    // Depending on the active bits in the immediate Value v, the following
    // instruction sequences are emitted:
    //
    // v == 0                        : ADDI
    // v[0,12) != 0 && v[12,32) == 0 : ADDI
    // v[0,12) == 0 && v[12,32) != 0 : LUI
    // v[0,32) != 0                  : LUI+ADDI(W)
    int64_t Hi20 = 0; // ((Val + 0x800) >> 12) & 0xFFFFF;
    int64_t Lo12 = SignExtend64<32>(Val);

    if (Hi20)
      Res.emplace_back(RISCV::LUI, Hi20);

    if (Lo12 || Hi20 == 0) {
      unsigned AddiOpc = (IsRV64 && Hi20) ? RISCV::ADDIW : RISCV::ADDI;
      Res.emplace_back(AddiOpc, Lo12);
    }
    return;
  }

  assert(IsRV64 && "Can't emit >32-bit imm for non-RV64 target");
  assert(false && "rv64 target not currently supported");

  // In the worst case, for a full 64-bit constant, a sequence of 8 instructions
  // (i.e., LUI+ADDIW+SLLI+ADDI+SLLI+ADDI+SLLI+ADDI) has to be emitted. Note
  // that the first two instructions (LUI+ADDIW) can contribute up to 32 bits
  // while the following ADDI instructions contribute up to 12 bits each.
  //
  // On the first glance, implementing this seems to be possible by simply
  // emitting the most significant 32 bits (LUI+ADDIW) followed by as many left
  // shift (SLLI) and immediate additions (ADDI) as needed. However, due to the
  // fact that ADDI performs a sign extended addition, doing it like that would
  // only be possible when at most 11 bits of the ADDI instructions are used.
  // Using all 12 bits of the ADDI instructions, like done by GAS, actually
  // requires that the constant is processed starting with the least significant
  // bit.
  //
  // In the following, constants are processed from LSB to MSB but instruction
  // emission is performed from MSB to LSB by recursively calling
  // generateInstSeq. In each recursion, first the lowest 12 bits are removed
  // from the constant and the optimal shift amount, which can be greater than
  // 12 bits if the constant is sparse, is determined. Then, the shifted
  // remaining constant is processed recursively and gets emitted as soon as it
  // fits into 32 bits. The emission of the shifts and additions is subsequently
  // performed when the recursion returns.

  int64_t Lo12 = SignExtend64<12>(Val);
  Val = (uint64_t)Val - (uint64_t)Lo12;

  int ShiftAmount = 0;
  bool Unsigned = false;

  // Val might now be valid for LUI without needing a shift.
  if (!isInt<32>(Val)) {
    ShiftAmount = llvm::countr_zero((uint64_t)Val);
    Val >>= ShiftAmount;

    // If the remaining bits don't fit in 12 bits, we might be able to reduce the
    // shift amount in order to use LUI which will zero the lower 12 bits.
    if (ShiftAmount > 12 && !isInt<12>(Val)) {
      if (isInt<32>((uint64_t)Val << 12)) {
        // Reduce the shift amount and add zeros to the LSBs so it will match LUI.
        ShiftAmount -= 12;
        Val = (uint64_t)Val << 12;
      } else if (isUInt<32>((uint64_t)Val << 12) &&
                 ActiveFeatures[RISCV::FeatureStdExtZba]) {
        // Reduce the shift amount and add zeros to the LSBs so it will match
        // LUI, then shift left with SLLI.UW to clear the upper 32 set bits.
        ShiftAmount -= 12;
        Val = ((uint64_t)Val << 12) | (0xffffffffull << 32);
        Unsigned = true;
      }
    }

    // Try to use SLLI_UW for Val when it is uint32 but not int32.
    if (isUInt<32>((uint64_t)Val) && !isInt<32>((uint64_t)Val) &&
        ActiveFeatures[RISCV::FeatureStdExtZba]) {
      // Use LUI+ADDI or LUI to compose, then clear the upper 32 bits with
      // SLLI_UW.
      Val = ((uint64_t)Val) | (0xffffffffull << 32);
      Unsigned = true;
    }
  }

  generateInstSeqImpl(Val, ActiveFeatures, Res);

  // Skip shift if we were able to use LUI directly.
  if (ShiftAmount) {
    unsigned Opc = Unsigned ? RISCV::SLLI_UW : RISCV::SLLI;
    Res.emplace_back(Opc, ShiftAmount);
  }

  if (Lo12)
    Res.emplace_back(RISCV::ADDI, Lo12);
}

static unsigned extractRotateInfo(int64_t Val) {
  // for case: 0b111..1..xxxxxx1..1..
  unsigned LeadingOnes = countLeadingOnes((uint64_t)Val);
  unsigned TrailingOnes = countTrailingOnes((uint64_t)Val);
  if (TrailingOnes > 0 && TrailingOnes < 64 &&
      (LeadingOnes + TrailingOnes) > (64 - 12))
    return 64 - TrailingOnes;

  // for case: 0bxxx1..1..1...xxx
  unsigned UpperTrailingOnes = countTrailingOnes(Hi_32(Val));
  unsigned LowerLeadingOnes = countLeadingOnes(Lo_32(Val));
  if (UpperTrailingOnes < 32 &&
      (UpperTrailingOnes + LowerLeadingOnes) > (64 - 12))
    return 32 - UpperTrailingOnes;

  return 0;
}

namespace llvm::RISCVMatInt {
InstSeq generateInstSeq(int64_t Val, const FeatureBitset &ActiveFeatures) {
  RISCVMatInt::InstSeq Res;
  generateInstSeqImpl(Val, ActiveFeatures, Res);

  // If the low 12 bits are non-zero, the first expansion may end with an ADDI
  // or ADDIW. If there are trailing zeros, try generating a sign extended
  // constant with no trailing zeros and use a final SLLI to restore them.
  if ((Val & 0xfff) != 0 && (Val & 1) == 0 && Res.size() >= 2) {
    unsigned TrailingZeros = countTrailingZeros((uint64_t)Val);
    int64_t ShiftedVal = Val >> TrailingZeros;
    // If we can use C.LI+C.SLLI instead of LUI+ADDI(W) prefer that since
    // its more compressible. But only if LUI+ADDI(W) isn't fusable.
    // NOTE: We don't check for C extension to minimize differences in generated
    // code.
    bool IsShiftedCompressible =
              isInt<6>(ShiftedVal) && !ActiveFeatures[RISCV::TuneLUIADDIFusion];
    RISCVMatInt::InstSeq TmpSeq;
    generateInstSeqImpl(ShiftedVal, ActiveFeatures, TmpSeq);
    TmpSeq.emplace_back(RISCV::SLLI, TrailingZeros);

    // Keep the new sequence if it is an improvement.
    if (TmpSeq.size() < Res.size() || IsShiftedCompressible)
      Res = TmpSeq;
  }

  // If the constant is positive we might be able to generate a shifted constant
  // with no leading zeros and use a final SRLI to restore them.
  if (Val > 0 && Res.size() > 2) {
    assert(ActiveFeatures[RISCV::Feature64Bit] &&
           "Expected RV32 to only need 2 instructions");
    unsigned LeadingZeros = countLeadingZeros((uint64_t)Val);
    uint64_t ShiftedVal = (uint64_t)Val << LeadingZeros;
    // Fill in the bits that will be shifted out with 1s. An example where this
    // helps is trailing one masks with 32 or more ones. This will generate
    // ADDI -1 and an SRLI.
    ShiftedVal |= maskTrailingOnes<uint64_t>(LeadingZeros);

    RISCVMatInt::InstSeq TmpSeq;
    generateInstSeqImpl(ShiftedVal, ActiveFeatures, TmpSeq);
    TmpSeq.emplace_back(RISCV::SRLI, LeadingZeros);

    // Keep the new sequence if it is an improvement.
    if (TmpSeq.size() < Res.size())
      Res = TmpSeq;

    // Some cases can benefit from filling the lower bits with zeros instead.
    ShiftedVal &= maskTrailingZeros<uint64_t>(LeadingZeros);
    TmpSeq.clear();
    generateInstSeqImpl(ShiftedVal, ActiveFeatures, TmpSeq);
    TmpSeq.emplace_back(RISCV::SRLI, LeadingZeros);

    // Keep the new sequence if it is an improvement.
    if (TmpSeq.size() < Res.size())
      Res = TmpSeq;

    // If we have exactly 32 leading zeros and Zba, we can try using zext.w at
    // the end of the sequence.
    if (LeadingZeros == 32 && ActiveFeatures[RISCV::FeatureStdExtZba]) {
      // Try replacing upper bits with 1.
      uint64_t LeadingOnesVal = Val | maskLeadingOnes<uint64_t>(LeadingZeros);
      TmpSeq.clear();
      generateInstSeqImpl(LeadingOnesVal, ActiveFeatures, TmpSeq);
      TmpSeq.emplace_back(RISCV::ADD_UW, 0);

      // Keep the new sequence if it is an improvement.
      if (TmpSeq.size() < Res.size())
        Res = TmpSeq;
    }
  }

  // Perform optimization with BCLRI/BSETI in the Zbs extension.
  if (Res.size() > 2 && ActiveFeatures[RISCV::FeatureStdExtZbs]) {
    assert(ActiveFeatures[RISCV::Feature64Bit] &&
           "Expected RV32 to only need 2 instructions");

    // 1. For values in range 0xffffffff 7fffffff ~ 0xffffffff 00000000,
    //    call generateInstSeqImpl with Val|0x80000000 (which is expected be
    //    an int32), then emit (BCLRI r, 31).
    // 2. For values in range 0x80000000 ~ 0xffffffff, call generateInstSeqImpl
    //    with Val&~0x80000000 (which is expected to be an int32), then
    //    emit (BSETI r, 31).
    int64_t NewVal;
    unsigned Opc;
    if (Val < 0) {
      Opc = RISCV::BCLRI;
      NewVal = Val | 0x80000000ll;
    } else {
      Opc = RISCV::BSETI;
      NewVal = Val & ~0x80000000ll;
    }
    if (isInt<32>(NewVal)) {
      RISCVMatInt::InstSeq TmpSeq;
      generateInstSeqImpl(NewVal, ActiveFeatures, TmpSeq);
      TmpSeq.emplace_back(Opc, 31);
      if (TmpSeq.size() < Res.size())
        Res = TmpSeq;
    }

    // Try to use BCLRI for upper 32 bits if the original lower 32 bits are
    // negative int32, or use BSETI for upper 32 bits if the original lower
    // 32 bits are positive int32.
    int32_t Lo = Lo_32(Val);
    uint32_t Hi = Hi_32(Val);
    Opc = 0;
    RISCVMatInt::InstSeq TmpSeq;
    generateInstSeqImpl(Lo, ActiveFeatures, TmpSeq);
    // Check if it is profitable to use BCLRI/BSETI.
    if (Lo > 0 && TmpSeq.size() + llvm::popcount(Hi) < Res.size()) {
      Opc = RISCV::BSETI;
    } else if (Lo < 0 && TmpSeq.size() + llvm::popcount(~Hi) < Res.size()) {
      Opc = RISCV::BCLRI;
      Hi = ~Hi;
    }
    // Search for each bit and build corresponding BCLRI/BSETI.
    if (Opc > 0) {
      while (Hi != 0) {
        unsigned Bit = llvm::countr_zero(Hi);
        TmpSeq.emplace_back(Opc, Bit + 32);
        Hi &= (Hi - 1); // Clear lowest set bit.
      }
      if (TmpSeq.size() < Res.size())
        Res = TmpSeq;
    }
  }

  // Perform optimization with SH*ADD in the Zba extension.
  if (Res.size() > 2 && ActiveFeatures[RISCV::FeatureStdExtZba]) {
    assert(ActiveFeatures[RISCV::Feature64Bit] &&
           "Expected RV32 to only need 2 instructions");
    int64_t Div = 0;
    unsigned Opc = 0;
    RISCVMatInt::InstSeq TmpSeq;
    // Select the opcode and divisor.
    if ((Val % 3) == 0 && isInt<32>(Val / 3)) {
      Div = 3;
      Opc = RISCV::SH1ADD;
    } else if ((Val % 5) == 0 && isInt<32>(Val / 5)) {
      Div = 5;
      Opc = RISCV::SH2ADD;
    } else if ((Val % 9) == 0 && isInt<32>(Val / 9)) {
      Div = 9;
      Opc = RISCV::SH3ADD;
    }
    // Build the new instruction sequence.
    if (Div > 0) {
      generateInstSeqImpl(Val / Div, ActiveFeatures, TmpSeq);
      TmpSeq.emplace_back(Opc, 0);
      if (TmpSeq.size() < Res.size())
        Res = TmpSeq;
    } else {
      // Try to use LUI+SH*ADD+ADDI.
      int64_t Hi52 = ((uint64_t)Val + 0x800ull) & ~0xfffull;
      int64_t Lo12 = SignExtend64<12>(Val);
      Div = 0;
      if (isInt<32>(Hi52 / 3) && (Hi52 % 3) == 0) {
        Div = 3;
        Opc = RISCV::SH1ADD;
      } else if (isInt<32>(Hi52 / 5) && (Hi52 % 5) == 0) {
        Div = 5;
        Opc = RISCV::SH2ADD;
      } else if (isInt<32>(Hi52 / 9) && (Hi52 % 9) == 0) {
        Div = 9;
        Opc = RISCV::SH3ADD;
      }
      // Build the new instruction sequence.
      if (Div > 0) {
        // For Val that has zero Lo12 (implies Val equals to Hi52) should has
        // already been processed to LUI+SH*ADD by previous optimization.
        assert(Lo12 != 0 &&
               "unexpected instruction sequence for immediate materialisation");
        assert(TmpSeq.empty() && "Expected empty TmpSeq");
        generateInstSeqImpl(Hi52 / Div, ActiveFeatures, TmpSeq);
        TmpSeq.emplace_back(Opc, 0);
        TmpSeq.emplace_back(RISCV::ADDI, Lo12);
        if (TmpSeq.size() < Res.size())
          Res = TmpSeq;
      }
    }
  }

  // Perform optimization with rori in the Zbb extension.
  if (Res.size() > 2 && ActiveFeatures[RISCV::FeatureStdExtZbb]) {
    if (unsigned Rotate = extractRotateInfo(Val)) {
      RISCVMatInt::InstSeq TmpSeq;
      uint64_t NegImm12 =
          ((uint64_t)Val >> (64 - Rotate)) | ((uint64_t)Val << Rotate);
      assert(isInt<12>(NegImm12));
      TmpSeq.emplace_back(RISCV::ADDI, NegImm12);
      TmpSeq.emplace_back(RISCV::RORI, Rotate);
      Res = TmpSeq;
    }
  }
  return Res;
}

int getIntMatCost(const APInt &Val, unsigned Size,
                  const FeatureBitset &ActiveFeatures, bool CompressionCost) {
  bool IsRV64 = ActiveFeatures[RISCV::Feature64Bit];
  bool HasRVC = CompressionCost && (ActiveFeatures[RISCV::FeatureStdExtC] ||
                                    ActiveFeatures[RISCV::FeatureExtZca]);
  int PlatRegSize = IsRV64 ? 64 : 32;

  // Split the constant into platform register sized chunks, and calculate cost
  // of each chunk.
  int Cost = 0;
  for (unsigned ShiftVal = 0; ShiftVal < Size; ShiftVal += PlatRegSize) {
    APInt Chunk = Val.ashr(ShiftVal).sextOrTrunc(PlatRegSize);
    InstSeq MatSeq = generateInstSeq(Chunk.getSExtValue(), ActiveFeatures);
    Cost += getInstSeqCost(MatSeq, HasRVC);
  }
  return std::max(1, Cost);
}

OpndKind Inst::getOpndKind() const {
  switch (Opc) {
  default:
    llvm_unreachable("Unexpected opcode!");
  case RISCV::LUI:
    return RISCVMatInt::Imm;
  case RISCV::ADD_UW:
    return RISCVMatInt::RegX0;
  case RISCV::SH1ADD:
  case RISCV::SH2ADD:
  case RISCV::SH3ADD:
    return RISCVMatInt::RegReg;
  case RISCV::ADDI:
  case RISCV::ADDIW:
  case RISCV::SLLI:
  case RISCV::SRLI:
  case RISCV::SLLI_UW:
  case RISCV::RORI:
  case RISCV::BSETI:
  case RISCV::BCLRI:
    return RISCVMatInt::RegImm;
  }
}

} // namespace llvm::RISCVMatInt
