//===--- RISCV.cpp - Implement RISC-V target feature support --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements RISC-V TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "clang/Basic/Diagnostic.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/TargetParser/RISCVTargetParser.h"
#include <optional>

using namespace clang;
using namespace clang::targets;

ArrayRef<const char *> RISCVTargetInfo::getGCCRegNames() const {
  // clang-format off
  static const char *const GCCRegNames[] = {
      // Integer registers
      "x0",  "x1",  "x2",  "x3",  "x4",  "x5",  "x6",  "x7",
      "x8",  "x9",  "x10", "x11", "x12", "x13", "x14", "x15",
      "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
      "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31",
      "x32", "x33", "x34", "x35", "x36", "x37", "x38", "x39",
      "x40", "x41", "x42", "x43", "x44", "x45", "x46", "x47",
      "x48", "x49", "x50", "x51", "x52", "x53", "x54", "x55",
      "x56", "x57", "x58", "x59", "x60", "x61", "x62", "x63",
      "x64", "x65", "x66", "x67", "x68", "x69", "x70", "x71",
      "x72", "x73", "x74", "x75", "x76", "x77", "x78", "x79",
      "x80", "x81", "x82", "x83", "x84", "x85", "x86", "x87",
      "x88", "x89", "x90", "x91", "x92", "x93", "x94", "x95",
      "x96", "x97", "x98", "x99", "x100", "x101", "x102", "x103",
      "x104", "x105", "x106", "x107", "x108", "x109", "x110", "x111",
      "x112", "x113", "x114", "x115", "x116", "x117", "x118", "x119",
      "x120", "x121", "x122", "x123", "x124", "x125", "x126", "x127",

      // Floating point registers
      "f0",  "f1",  "f2",  "f3",  "f4",  "f5",  "f6",  "f7",
      "f8",  "f9",  "f10", "f11", "f12", "f13", "f14", "f15",
      "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23",
      "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31",
      "f32", "f33", "f34", "f35", "f36", "f37", "f38", "f39",
      "f40", "f41", "f42", "f43", "f44", "f45", "f46", "f47",
      "f48", "f49", "f50", "f51", "f52", "f53", "f54", "f55",
      "f56", "f57", "f58", "f59", "f60", "f61", "f62", "f63",


      // Vector registers
      "v0",  "v1",  "v2",  "v3",  "v4",  "v5",  "v6",  "v7",
      "v8",  "v9",  "v10", "v11", "v12", "v13", "v14", "v15",
      "v16", "v17", "v18", "v19", "v20", "v21", "v22", "v23",
      "v24", "v25", "v26", "v27", "v28", "v29", "v30", "v31",

      // CSRs
      "fflags", "frm", "vtype", "vl", "vxsat", "vxrm"
    };
  // clang-format on
  return llvm::ArrayRef(GCCRegNames);
}

ArrayRef<TargetInfo::GCCRegAlias> RISCVTargetInfo::getGCCRegAliases() const {
  static const TargetInfo::GCCRegAlias GCCRegAliases[] = {
      {{"zero"}, "x0"}, {{"ra"}, "x1"},   {{"sp"}, "x2"},    {{"gp"}, "x3"},
      {{"tp"}, "x4"},   {{"t0"}, "x5"},   {{"t1"}, "x6"},    {{"t2"}, "x7"},
      {{"s0"}, "x8"},   {{"s1"}, "x9"},   {{"a0"}, "x10"},   {{"a1"}, "x11"},
      {{"a2"}, "x12"},  {{"a3"}, "x13"},  {{"a4"}, "x14"},   {{"a5"}, "x15"},
      {{"a6"}, "x16"},  {{"a7"}, "x17"},  {{"s2"}, "x18"},   {{"s3"}, "x19"},
      {{"s4"}, "x20"},  {{"s5"}, "x21"},  {{"s6"}, "x22"},   {{"s7"}, "x23"},
      {{"s8"}, "x24"},  {{"s9"}, "x25"},  {{"s10"}, "x26"},  {{"s11"}, "x27"},
      {{"t3"}, "x28"},  {{"t4"}, "x29"},  {{"t5"}, "x30"},   {{"t6"}, "x31"},
      {{"a8"}, "x32"},  {{"a9"}, "x33"},  {{"a10"}, "x34"},  {{"a11"}, "x35"},
      {{"a12"}, "x36"}, {{"a13"}, "x37"}, {{"a14"}, "x38"},  {{"a15"}, "x39"},
      {{"a16"}, "x40"}, {{"a17"}, "x41"}, {{"a18"}, "x42"},  {{"a19"}, "x43"},
      {{"a20"}, "x44"}, {{"a21"}, "x45"}, {{"a22"}, "x46"},  {{"a23"}, "x47"},
      {{"s12"}, "x48"}, {{"s13"}, "x49"}, {{"s14"}, "x50"},  {{"s15"}, "x51"},
      {{"s16"}, "x52"}, {{"s17"}, "x53"}, {{"s18"}, "x54"},  {{"s19"}, "x55"},
      {{"s20"}, "x56"}, {{"s21"}, "x57"}, {{"s22"}, "x58"},  {{"s23"}, "x59"},
      {{"s24"}, "x60"}, {{"s25"}, "x61"}, {{"s26"}, "x62"},  {{"s27"}, "x63"},
      {{"s28"}, "x64"}, {{"s29"}, "x65"}, {{"s30"}, "x66"},  {{"s31"}, "x67"},
      {{"s32"}, "x68"}, {{"s33"}, "x69"}, {{"s34"}, "x70"},  {{"s35"}, "x71"},
      {{"s36"}, "x72"}, {{"s37"}, "x73"}, {{"s38"}, "x74"},  {{"s39"}, "x75"},
      {{"s40"}, "x76"}, {{"s41"}, "x77"}, {{"s42"}, "x78"},  {{"s43"}, "x79"},
      {{"s44"}, "x80"}, {{"s45"}, "x81"}, {{"s46"}, "x82"},  {{"s47"}, "x83"},
      {{"s48"}, "x84"}, {{"s49"}, "x85"}, {{"s50"}, "x86"},  {{"s51"}, "x87"},
      {{"s52"}, "x88"}, {{"s53"}, "x89"}, {{"s54"}, "x90"},  {{"s55"}, "x91"},
      {{"s56"}, "x92"}, {{"s57"}, "x93"}, {{"s58"}, "x94"},  {{"s59"}, "x95"},
      {{"t7"}, "x96"},  {{"t8"}, "x97"},  {{"t9"}, "x98"},   {{"t10"}, "x99"},
      {{"t11"}, "x100"}, {{"t12"}, "x101"},  {{"t13"}, "x102"},  {{"t14"}, "x103"},
      {{"t15"}, "x104"}, {{"t16"}, "x105"},  {{"t17"}, "x106"},  {{"t18"}, "x107"},
      {{"t19"}, "x108"}, {{"t20"}, "x109"},  {{"t21"}, "x110"},  {{"t22"}, "x111"},
      {{"t23"}, "x112"}, {{"t24"}, "x113"},  {{"t25"}, "x114"},  {{"t26"}, "x115"},
      {{"t27"}, "x116"}, {{"t28"}, "x117"},  {{"t29"}, "x118"},  {{"t30"}, "x119"},
      {{"t31"}, "x120"}, {{"t32"}, "x121"},  {{"t33"}, "x122"},  {{"t34"}, "x123"},
      {{"t35"}, "x124"}, {{"t36"}, "x125"},  {{"t37"}, "x126"},  {{"t38"}, "x127"},
      {{"ft0"}, "f0"},  {{"ft1"}, "f1"},  {{"ft2"}, "f2"},   {{"ft3"}, "f3"},
      {{"ft4"}, "f4"},  {{"ft5"}, "f5"},  {{"ft6"}, "f6"},   {{"ft7"}, "f7"},
      {{"fs0"}, "f8"},  {{"fs1"}, "f9"},  {{"fa0"}, "f10"},  {{"fa1"}, "f11"},
      {{"fa2"}, "f12"}, {{"fa3"}, "f13"}, {{"fa4"}, "f14"},  {{"fa5"}, "f15"},
      {{"fa6"}, "f16"}, {{"fa7"}, "f17"}, {{"fs2"}, "f18"},  {{"fs3"}, "f19"},
      {{"fs4"}, "f20"}, {{"fs5"}, "f21"}, {{"fs6"}, "f22"},  {{"fs7"}, "f23"},
      {{"fs8"}, "f24"}, {{"fs9"}, "f25"}, {{"fs10"}, "f26"}, {{"fs11"}, "f27"},
      {{"ft8"}, "f28"}, {{"ft9"}, "f29"}, {{"ft10"}, "f30"}, {{"ft11"}, "f31"},
      {{"fa8"}, "f32"}, {{"fa9"}, "f33"}, {{"fa10"}, "f34"}, {{"fa11"}, "f35"},
      {{"fa12"}, "f36"}, {{"fa13"}, "f37"}, {{"fa14"}, "f38"}, {{"fa15"}, "f39"},
      {{"fs12"}, "f40"}, {{"fs13"}, "f41"}, {{"fs14"}, "f42"}, {{"fs15"}, "f43"},
      {{"fs16"}, "f44"}, {{"fs17"}, "f45"}, {{"fs18"}, "f46"}, {{"fs19"}, "f47"},
      {{"fs20"}, "f48"}, {{"fs21"}, "f49"}, {{"fs22"}, "f50"}, {{"fs23"}, "f51"},
      {{"ft12"}, "f52"}, {{"ft13"}, "f53"}, {{"ft14"}, "f54"}, {{"ft15"}, "f55"},
      {{"ft16"}, "f56"}, {{"ft17"}, "f57"}, {{"ft18"}, "f58"}, {{"ft19"}, "f59"},
      {{"ft20"}, "f60"}, {{"ft21"}, "f61"}, {{"ft22"}, "f62"}, {{"ft23"}, "f63"}};
  return llvm::ArrayRef(GCCRegAliases);
}

bool RISCVTargetInfo::validateAsmConstraint(
    const char *&Name, TargetInfo::ConstraintInfo &Info) const {
  switch (*Name) {
  default:
    return false;
  case 'I':
    printf("I type no longer exists. The immediate bounds might not be accurate\n");
    // A 32-bit signed immediate.
    Info.setRequiresImmediate(-2147483648LL, 2147483647LL);
    return true;
  case 'J':
    // Integer zero.
    Info.setRequiresImmediate(0);
    return true;
  case 'K':
    // A 5-bit unsigned immediate for CSR access instructions.
    Info.setRequiresImmediate(0, 31);
    return true;
  case 'f':
    // A floating-point register.
    Info.setAllowsRegister();
    return true;
  case 'A':
    // An address that is held in a general-purpose register.
    Info.setAllowsMemory();
    return true;
  case 'S': // A symbolic address
    Info.setAllowsRegister();
    return true;
  case 'v':
    // A vector register.
    if (Name[1] == 'r' || Name[1] == 'm') {
      Info.setAllowsRegister();
      Name += 1;
      return true;
    }
    return false;
  }
}

std::string RISCVTargetInfo::convertConstraint(const char *&Constraint) const {
  std::string R;
  switch (*Constraint) {
  case 'v':
    R = std::string("^") + std::string(Constraint, 2);
    Constraint += 1;
    break;
  default:
    R = TargetInfo::convertConstraint(Constraint);
    break;
  }
  return R;
}

static unsigned getVersionValue(unsigned MajorVersion, unsigned MinorVersion) {
  return MajorVersion * 1000000 + MinorVersion * 1000;
}

void RISCVTargetInfo::getTargetDefines(const LangOptions &Opts,
                                       MacroBuilder &Builder) const {
  Builder.defineMacro("__riscv");
  bool Is64Bit = getTriple().isRISCV64();
  Builder.defineMacro("__riscv_xlen", Is64Bit ? "64" : "32");
  StringRef CodeModel = getTargetOpts().CodeModel;
  unsigned FLen = ISAInfo->getFLen();
  unsigned MinVLen = ISAInfo->getMinVLen();
  unsigned MaxELen = ISAInfo->getMaxELen();
  unsigned MaxELenFp = ISAInfo->getMaxELenFp();
  if (CodeModel == "default")
    CodeModel = "small";

  if (CodeModel == "small")
    Builder.defineMacro("__riscv_cmodel_medlow");
  else if (CodeModel == "medium")
    Builder.defineMacro("__riscv_cmodel_medany");

  StringRef ABIName = getABI();
  if (ABIName == "ilp32f" || ABIName == "lp64f")
    Builder.defineMacro("__riscv_float_abi_single");
  else if (ABIName == "ilp32d" || ABIName == "lp64d")
    Builder.defineMacro("__riscv_float_abi_double");
  else
    Builder.defineMacro("__riscv_float_abi_soft");

  if (ABIName == "ilp32e" || ABIName == "lp64e")
    Builder.defineMacro("__riscv_abi_rve");

  Builder.defineMacro("__riscv_arch_test");

  for (auto &Extension : ISAInfo->getExtensions()) {
    auto ExtName = Extension.first;
    auto ExtInfo = Extension.second;

    Builder.defineMacro(Twine("__riscv_", ExtName),
                        Twine(getVersionValue(ExtInfo.Major, ExtInfo.Minor)));
  }

  if (ISAInfo->hasExtension("m") || ISAInfo->hasExtension("zmmul"))
    Builder.defineMacro("__riscv_mul");

  if (ISAInfo->hasExtension("m")) {
    Builder.defineMacro("__riscv_div");
    Builder.defineMacro("__riscv_muldiv");
  }

  if (ISAInfo->hasExtension("a")) {
    Builder.defineMacro("__riscv_atomic");
    Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1");
    Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2");
    Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4");
    if (Is64Bit)
      Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8");
  }

  if (FLen) {
    Builder.defineMacro("__riscv_flen", Twine(FLen));
    Builder.defineMacro("__riscv_fdiv");
    Builder.defineMacro("__riscv_fsqrt");
  }

  if (MinVLen) {
    Builder.defineMacro("__riscv_v_min_vlen", Twine(MinVLen));
    Builder.defineMacro("__riscv_v_elen", Twine(MaxELen));
    Builder.defineMacro("__riscv_v_elen_fp", Twine(MaxELenFp));
  }

  if (ISAInfo->hasExtension("c"))
    Builder.defineMacro("__riscv_compressed");

  if (ISAInfo->hasExtension("zve32x")) {
    Builder.defineMacro("__riscv_vector");
    // Currently we support the v0.12 RISC-V V intrinsics.
    Builder.defineMacro("__riscv_v_intrinsic", Twine(getVersionValue(0, 12)));
  }

  auto VScale = getVScaleRange(Opts);
  if (VScale && VScale->first && VScale->first == VScale->second)
    Builder.defineMacro("__riscv_v_fixed_vlen",
                        Twine(VScale->first * llvm::RISCV::RVVBitsPerBlock));

  if (FastUnalignedAccess)
    Builder.defineMacro("__riscv_misaligned_fast");
  else
    Builder.defineMacro("__riscv_misaligned_avoid");

  if (ISAInfo->hasExtension("e")) {
    if (Is64Bit)
      Builder.defineMacro("__riscv_64e");
    else
      Builder.defineMacro("__riscv_32e");
  }
}

static constexpr Builtin::Info BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  {#ID, TYPE, ATTRS, nullptr, HeaderDesc::NO_HEADER, ALL_LANGUAGES},
#define TARGET_BUILTIN(ID, TYPE, ATTRS, FEATURE)                               \
  {#ID, TYPE, ATTRS, FEATURE, HeaderDesc::NO_HEADER, ALL_LANGUAGES},
#include "clang/Basic/BuiltinsRISCVVector.def"
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  {#ID, TYPE, ATTRS, nullptr, HeaderDesc::NO_HEADER, ALL_LANGUAGES},
#define TARGET_BUILTIN(ID, TYPE, ATTRS, FEATURE)                               \
  {#ID, TYPE, ATTRS, FEATURE, HeaderDesc::NO_HEADER, ALL_LANGUAGES},
#include "clang/Basic/BuiltinsRISCV.def"
};

ArrayRef<Builtin::Info> RISCVTargetInfo::getTargetBuiltins() const {
  return llvm::ArrayRef(BuiltinInfo,
                        clang::RISCV::LastTSBuiltin - Builtin::FirstTSBuiltin);
}

bool RISCVTargetInfo::initFeatureMap(
    llvm::StringMap<bool> &Features, DiagnosticsEngine &Diags, StringRef CPU,
    const std::vector<std::string> &FeaturesVec) const {

  unsigned XLen = 32;

  if (getTriple().isRISCV64()) {
    Features["64bit"] = true;
    XLen = 64;
  } else {
    Features["32bit"] = true;
  }

  // If a target attribute specified a full arch string, override all the ISA
  // extension target features.
  const auto I = llvm::find(FeaturesVec, "__RISCV_TargetAttrNeedOverride");
  if (I != FeaturesVec.end()) {
    std::vector<std::string> OverrideFeatures(std::next(I), FeaturesVec.end());

    // Add back any non ISA extension features, e.g. +relax.
    auto IsNonISAExtFeature = [](StringRef Feature) {
      assert(Feature.size() > 1 && (Feature[0] == '+' || Feature[0] == '-'));
      StringRef Ext = Feature.substr(1); // drop the +/-
      return !llvm::RISCVISAInfo::isSupportedExtensionFeature(Ext);
    };
    llvm::copy_if(llvm::make_range(FeaturesVec.begin(), I),
                  std::back_inserter(OverrideFeatures), IsNonISAExtFeature);

    return TargetInfo::initFeatureMap(Features, Diags, CPU, OverrideFeatures);
  }

  // Otherwise, parse the features and add any implied extensions.
  std::vector<std::string> AllFeatures = FeaturesVec;
  auto ParseResult = llvm::RISCVISAInfo::parseFeatures(XLen, FeaturesVec);
  if (!ParseResult) {
    std::string Buffer;
    llvm::raw_string_ostream OutputErrMsg(Buffer);
    handleAllErrors(ParseResult.takeError(), [&](llvm::StringError &ErrMsg) {
      OutputErrMsg << ErrMsg.getMessage();
    });
    Diags.Report(diag::err_invalid_feature_combination) << OutputErrMsg.str();
    return false;
  }

  // Append all features, not just new ones, so we override any negatives.
  llvm::append_range(AllFeatures, (*ParseResult)->toFeatures());
  return TargetInfo::initFeatureMap(Features, Diags, CPU, AllFeatures);
}

std::optional<std::pair<unsigned, unsigned>>
RISCVTargetInfo::getVScaleRange(const LangOptions &LangOpts) const {
  // RISCV::RVVBitsPerBlock is 64.
  unsigned VScaleMin = ISAInfo->getMinVLen() / llvm::RISCV::RVVBitsPerBlock;

  if (LangOpts.VScaleMin || LangOpts.VScaleMax) {
    // Treat Zvl*b as a lower bound on vscale.
    VScaleMin = std::max(VScaleMin, LangOpts.VScaleMin);
    unsigned VScaleMax = LangOpts.VScaleMax;
    if (VScaleMax != 0 && VScaleMax < VScaleMin)
      VScaleMax = VScaleMin;
    return std::pair<unsigned, unsigned>(VScaleMin ? VScaleMin : 1, VScaleMax);
  }

  if (VScaleMin > 0) {
    unsigned VScaleMax = ISAInfo->getMaxVLen() / llvm::RISCV::RVVBitsPerBlock;
    return std::make_pair(VScaleMin, VScaleMax);
  }

  return std::nullopt;
}

/// Return true if has this feature, need to sync with handleTargetFeatures.
bool RISCVTargetInfo::hasFeature(StringRef Feature) const {
  bool Is64Bit = getTriple().isRISCV64();
  auto Result = llvm::StringSwitch<std::optional<bool>>(Feature)
                    .Case("riscv", true)
                    .Case("riscv32", !Is64Bit)
                    .Case("riscv64", Is64Bit)
                    .Case("32bit", !Is64Bit)
                    .Case("64bit", Is64Bit)
                    .Case("experimental", HasExperimental)
                    .Default(std::nullopt);
  if (Result)
    return *Result;

  return ISAInfo->hasExtension(Feature);
}

/// Perform initialization based on the user configured set of features.
bool RISCVTargetInfo::handleTargetFeatures(std::vector<std::string> &Features,
                                           DiagnosticsEngine &Diags) {
  unsigned XLen = getTriple().isArch64Bit() ? 64 : 32;
  auto ParseResult = llvm::RISCVISAInfo::parseFeatures(XLen, Features);
  if (!ParseResult) {
    std::string Buffer;
    llvm::raw_string_ostream OutputErrMsg(Buffer);
    handleAllErrors(ParseResult.takeError(), [&](llvm::StringError &ErrMsg) {
      OutputErrMsg << ErrMsg.getMessage();
    });
    Diags.Report(diag::err_invalid_feature_combination) << OutputErrMsg.str();
    return false;
  } else {
    ISAInfo = std::move(*ParseResult);
  }

  if (ABI.empty())
    ABI = ISAInfo->computeDefaultABI().str();

  if (ISAInfo->hasExtension("zfh") || ISAInfo->hasExtension("zhinx"))
    HasLegalHalfType = true;

  FastUnalignedAccess = llvm::is_contained(Features, "+fast-unaligned-access");

  if (llvm::is_contained(Features, "+experimental"))
    HasExperimental = true;

  if (ABI == "ilp32e" && ISAInfo->hasExtension("d")) {
    Diags.Report(diag::err_invalid_feature_combination)
        << "ILP32E cannot be used with the D ISA extension";
    return false;
  }
  return true;
}

bool RISCVTargetInfo::isValidCPUName(StringRef Name) const {
  bool Is64Bit = getTriple().isArch64Bit();
  return llvm::RISCV::parseCPU(Name, Is64Bit);
}

void RISCVTargetInfo::fillValidCPUList(
    SmallVectorImpl<StringRef> &Values) const {
  bool Is64Bit = getTriple().isArch64Bit();
  llvm::RISCV::fillValidCPUArchList(Values, Is64Bit);
}

bool RISCVTargetInfo::isValidTuneCPUName(StringRef Name) const {
  bool Is64Bit = getTriple().isArch64Bit();
  return llvm::RISCV::parseTuneCPU(Name, Is64Bit);
}

void RISCVTargetInfo::fillValidTuneCPUList(
    SmallVectorImpl<StringRef> &Values) const {
  bool Is64Bit = getTriple().isArch64Bit();
  llvm::RISCV::fillValidTuneCPUArchList(Values, Is64Bit);
}

static void handleFullArchString(StringRef FullArchStr,
                                 std::vector<std::string> &Features) {
  Features.push_back("__RISCV_TargetAttrNeedOverride");
  auto RII = llvm::RISCVISAInfo::parseArchString(
      FullArchStr, /* EnableExperimentalExtension */ true);
  if (llvm::errorToBool(RII.takeError())) {
    // Forward the invalid FullArchStr.
    Features.push_back("+" + FullArchStr.str());
  } else {
    // Append a full list of features, including any negative extensions so that
    // we override the CPU's features.
    std::vector<std::string> FeatStrings =
        (*RII)->toFeatures(/* AddAllExtensions */ true);
    Features.insert(Features.end(), FeatStrings.begin(), FeatStrings.end());
  }
}

ParsedTargetAttr RISCVTargetInfo::parseTargetAttr(StringRef Features) const {
  ParsedTargetAttr Ret;
  if (Features == "default")
    return Ret;
  SmallVector<StringRef, 1> AttrFeatures;
  Features.split(AttrFeatures, ";");
  bool FoundArch = false;

  for (auto &Feature : AttrFeatures) {
    Feature = Feature.trim();
    StringRef AttrString = Feature.split("=").second.trim();

    if (Feature.starts_with("arch=")) {
      // Override last features
      Ret.Features.clear();
      if (FoundArch)
        Ret.Duplicate = "arch=";
      FoundArch = true;

      if (AttrString.starts_with("+")) {
        // EXTENSION like arch=+v,+zbb
        SmallVector<StringRef, 1> Exts;
        AttrString.split(Exts, ",");
        for (auto Ext : Exts) {
          if (Ext.empty())
            continue;

          StringRef ExtName = Ext.substr(1);
          std::string TargetFeature =
              llvm::RISCVISAInfo::getTargetFeatureForExtension(ExtName);
          if (!TargetFeature.empty())
            Ret.Features.push_back(Ext.front() + TargetFeature);
          else
            Ret.Features.push_back(Ext.str());
        }
      } else {
        // full-arch-string like arch=rv64gcv
        handleFullArchString(AttrString, Ret.Features);
      }
    } else if (Feature.starts_with("cpu=")) {
      if (!Ret.CPU.empty())
        Ret.Duplicate = "cpu=";

      Ret.CPU = AttrString;

      if (!FoundArch) {
        // Update Features with CPU's features
        StringRef MarchFromCPU = llvm::RISCV::getMArchFromMcpu(Ret.CPU);
        if (MarchFromCPU != "") {
          Ret.Features.clear();
          handleFullArchString(MarchFromCPU, Ret.Features);
        }
      }
    } else if (Feature.starts_with("tune=")) {
      if (!Ret.Tune.empty())
        Ret.Duplicate = "tune=";

      Ret.Tune = AttrString;
    }
  }
  return Ret;
}
