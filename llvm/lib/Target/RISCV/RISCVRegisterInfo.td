//===-- RISCVRegisterInfo.td - RISC-V Register defs --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the RISC-V register files
//===----------------------------------------------------------------------===//

let Namespace = "RISCV" in {
class RISCVReg<bits<8> Enc, string n, list<string> alt = []> : Register<n> {
  let HWEncoding{7-0} = Enc;
  let AltNames = alt;
}

class RISCVReg16<bits<8> Enc, string n, list<string> alt = []> : Register<n> {
  let HWEncoding{7-0} = Enc;
  let AltNames = alt;
}

def sub_16 : SubRegIndex<16>;
class RISCVReg32<RISCVReg16 subreg> : Register<""> {
  let HWEncoding{7-0} = subreg.HWEncoding{7-0};
  let SubRegs = [subreg];
  let SubRegIndices = [sub_16];
  let AsmName = subreg.AsmName;
  let AltNames = subreg.AltNames;
}

// Because RISCVReg64 register have AsmName and AltNames that alias with their
// 16/32-bit sub-register, RISCVAsmParser will need to coerce a register number
// from a RISCVReg16/RISCVReg32 to the equivalent RISCVReg64 when appropriate.
def sub_32 : SubRegIndex<32>;
class RISCVReg64<RISCVReg32 subreg> : Register<""> {
  let HWEncoding{7-0} = subreg.HWEncoding{7-0};
  let SubRegs = [subreg];
  let SubRegIndices = [sub_32];
  let AsmName = subreg.AsmName;
  let AltNames = subreg.AltNames;
}

class RISCVRegWithSubRegs<bits<8> Enc, string n, list<Register> subregs,
                          list<string> alt = []>
      : RegisterWithSubRegs<n, subregs> {
  let HWEncoding{7-0} = Enc;
  let AltNames = alt;
}

def ABIRegAltName : RegAltNameIndex;

def sub_vrm4_0 : SubRegIndex<256>;
def sub_vrm4_1 : SubRegIndex<256, 256>;
def sub_vrm2_0 : SubRegIndex<128>;
def sub_vrm2_1 : SubRegIndex<128, 128>;
def sub_vrm2_2 : ComposedSubRegIndex<sub_vrm4_1, sub_vrm2_0>;
def sub_vrm2_3 : ComposedSubRegIndex<sub_vrm4_1, sub_vrm2_1>;
def sub_vrm1_0 : SubRegIndex<64>;
def sub_vrm1_1 : SubRegIndex<64, 64>;
def sub_vrm1_2 : ComposedSubRegIndex<sub_vrm2_1, sub_vrm1_0>;
def sub_vrm1_3 : ComposedSubRegIndex<sub_vrm2_1, sub_vrm1_1>;
def sub_vrm1_4 : ComposedSubRegIndex<sub_vrm2_2, sub_vrm1_0>;
def sub_vrm1_5 : ComposedSubRegIndex<sub_vrm2_2, sub_vrm1_1>;
def sub_vrm1_6 : ComposedSubRegIndex<sub_vrm2_3, sub_vrm1_0>;
def sub_vrm1_7 : ComposedSubRegIndex<sub_vrm2_3, sub_vrm1_1>;

def sub_32_hi  : SubRegIndex<32, 32>;
} // Namespace = "RISCV"

// Integer registers
// CostPerUse is set higher for registers that may not be compressible as they
// are not part of GPRC, the most restrictive register class used by the
// compressed instruction set. This will influence the greedy register
// allocator to reduce the use of registers that can't be encoded in 16 bit
// instructions.

let RegAltNameIndices = [ABIRegAltName] in {
  let isConstant = true in
  def X0  : RISCVReg<0, "x0", ["zero"]>, DwarfRegNum<[0]>;
  let CostPerUse = [0, 1] in {
  def X1  : RISCVReg<1, "x1", ["ra"]>, DwarfRegNum<[1]>;
  def X2  : RISCVReg<2, "x2", ["sp"]>, DwarfRegNum<[2]>;
  def X3  : RISCVReg<3, "x3", ["gp"]>, DwarfRegNum<[3]>;
  def X4  : RISCVReg<4, "x4", ["tp"]>, DwarfRegNum<[4]>;
  def X5  : RISCVReg<5, "x5", ["t0"]>, DwarfRegNum<[5]>;
  def X6  : RISCVReg<6, "x6", ["t1"]>, DwarfRegNum<[6]>;
  def X7  : RISCVReg<7, "x7", ["t2"]>, DwarfRegNum<[7]>;
  }
  def X8  : RISCVReg<8, "x8", ["s0", "fp"]>, DwarfRegNum<[8]>;
  def X9  : RISCVReg<9, "x9", ["s1"]>, DwarfRegNum<[9]>;
  def X10 : RISCVReg<10,"x10", ["a0"]>, DwarfRegNum<[10]>;
  def X11 : RISCVReg<11,"x11", ["a1"]>, DwarfRegNum<[11]>;
  def X12 : RISCVReg<12,"x12", ["a2"]>, DwarfRegNum<[12]>;
  def X13 : RISCVReg<13,"x13", ["a3"]>, DwarfRegNum<[13]>;
  def X14 : RISCVReg<14,"x14", ["a4"]>, DwarfRegNum<[14]>;
  def X15 : RISCVReg<15,"x15", ["a5"]>, DwarfRegNum<[15]>;
  let CostPerUse = [0, 1] in {
  def X16 : RISCVReg<16,"x16", ["a6"]>, DwarfRegNum<[16]>;
  def X17 : RISCVReg<17,"x17", ["a7"]>, DwarfRegNum<[17]>;
  def X18 : RISCVReg<18,"x18", ["s2"]>, DwarfRegNum<[18]>;
  def X19 : RISCVReg<19,"x19", ["s3"]>, DwarfRegNum<[19]>;
  def X20 : RISCVReg<20,"x20", ["s4"]>, DwarfRegNum<[20]>;
  def X21 : RISCVReg<21,"x21", ["s5"]>, DwarfRegNum<[21]>;
  def X22 : RISCVReg<22,"x22", ["s6"]>, DwarfRegNum<[22]>;
  def X23 : RISCVReg<23,"x23", ["s7"]>, DwarfRegNum<[23]>;
  def X24 : RISCVReg<24,"x24", ["s8"]>, DwarfRegNum<[24]>;
  def X25 : RISCVReg<25,"x25", ["s9"]>, DwarfRegNum<[25]>;
  def X26 : RISCVReg<26,"x26", ["s10"]>, DwarfRegNum<[26]>;
  def X27 : RISCVReg<27,"x27", ["s11"]>, DwarfRegNum<[27]>;
  def X28 : RISCVReg<28,"x28", ["t3"]>, DwarfRegNum<[28]>;
  def X29 : RISCVReg<29,"x29", ["t4"]>, DwarfRegNum<[29]>;
  def X30 : RISCVReg<30,"x30", ["t5"]>, DwarfRegNum<[30]>;
  def X31 : RISCVReg<31,"x31", ["t6"]>, DwarfRegNum<[31]>;

  def X32 : RISCVReg<32,"x32", ["a8"]>,  DwarfRegNum<[32]>;
  def X33 : RISCVReg<33,"x33", ["a9"]>,  DwarfRegNum<[33]>;
  def X34 : RISCVReg<34,"x34", ["a10"]>, DwarfRegNum<[34]>;
  def X35 : RISCVReg<35,"x35", ["a11"]>, DwarfRegNum<[35]>;
  def X36 : RISCVReg<36,"x36", ["a12"]>, DwarfRegNum<[36]>;
  def X37 : RISCVReg<37,"x37", ["a13"]>, DwarfRegNum<[37]>;
  def X38 : RISCVReg<38,"x38", ["a14"]>, DwarfRegNum<[38]>;
  def X39 : RISCVReg<39,"x39", ["a15"]>, DwarfRegNum<[39]>;
  def X40 : RISCVReg<40,"x40", ["a16"]>, DwarfRegNum<[40]>;
  def X41 : RISCVReg<41,"x41", ["a17"]>, DwarfRegNum<[41]>;
  def X42 : RISCVReg<42,"x42", ["a18"]>, DwarfRegNum<[42]>;
  def X43 : RISCVReg<43,"x43", ["a19"]>, DwarfRegNum<[43]>;
  def X44 : RISCVReg<44,"x44", ["a20"]>, DwarfRegNum<[44]>;
  def X45 : RISCVReg<45,"x45", ["a21"]>, DwarfRegNum<[45]>;
  def X46 : RISCVReg<46,"x46", ["a22"]>, DwarfRegNum<[46]>;
  def X47 : RISCVReg<47,"x47", ["a23"]>, DwarfRegNum<[47]>;

  def X48 : RISCVReg<48,"x48", ["s12"]>, DwarfRegNum<[48]>;
  def X49 : RISCVReg<49,"x49", ["s13"]>, DwarfRegNum<[49]>;
  def X50 : RISCVReg<50,"x50", ["s14"]>, DwarfRegNum<[50]>;
  def X51 : RISCVReg<51,"x51", ["s15"]>, DwarfRegNum<[51]>;
  def X52 : RISCVReg<52,"x52", ["s16"]>, DwarfRegNum<[52]>;
  def X53 : RISCVReg<53,"x53", ["s17"]>, DwarfRegNum<[53]>;
  def X54 : RISCVReg<54,"x54", ["s18"]>, DwarfRegNum<[54]>;
  def X55 : RISCVReg<55,"x55", ["s19"]>, DwarfRegNum<[55]>;
  def X56 : RISCVReg<56,"x56", ["s20"]>, DwarfRegNum<[56]>;
  def X57 : RISCVReg<57,"x57", ["s21"]>, DwarfRegNum<[57]>;
  def X58 : RISCVReg<58,"x58", ["s22"]>, DwarfRegNum<[58]>;
  def X59 : RISCVReg<59,"x59", ["s23"]>, DwarfRegNum<[59]>;

  def X60 : RISCVReg<60,"x60", ["s24"]>, DwarfRegNum<[60]>;
  def X61 : RISCVReg<61,"x61", ["s25"]>, DwarfRegNum<[61]>;
  def X62 : RISCVReg<62,"x62", ["s26"]>, DwarfRegNum<[62]>;
  def X63 : RISCVReg<63,"x63", ["s27"]>, DwarfRegNum<[63]>;
  def X64 : RISCVReg<64,"x64", ["s28"]>, DwarfRegNum<[64]>;
  def X65 : RISCVReg<65,"x65", ["s29"]>, DwarfRegNum<[65]>;
  def X66 : RISCVReg<66,"x66", ["s30"]>, DwarfRegNum<[66]>;
  def X67 : RISCVReg<67,"x67", ["s31"]>, DwarfRegNum<[67]>;
  def X68 : RISCVReg<68,"x68", ["s32"]>, DwarfRegNum<[68]>;
  def X69 : RISCVReg<69,"x69", ["s33"]>, DwarfRegNum<[69]>;

  def X70 : RISCVReg<70,"x70", ["s34"]>, DwarfRegNum<[70]>;
  def X71 : RISCVReg<71,"x71", ["s35"]>, DwarfRegNum<[71]>;
  def X72 : RISCVReg<72,"x72", ["s36"]>, DwarfRegNum<[72]>;
  def X73 : RISCVReg<73,"x73", ["s37"]>, DwarfRegNum<[73]>;
  def X74 : RISCVReg<74,"x74", ["s38"]>, DwarfRegNum<[74]>;
  def X75 : RISCVReg<75,"x75", ["s39"]>, DwarfRegNum<[75]>;
  def X76 : RISCVReg<76,"x76", ["s40"]>, DwarfRegNum<[76]>;
  def X77 : RISCVReg<77,"x77", ["s41"]>, DwarfRegNum<[77]>;
  def X78 : RISCVReg<78,"x78", ["s42"]>, DwarfRegNum<[78]>;
  def X79 : RISCVReg<79,"x79", ["s43"]>, DwarfRegNum<[79]>;
  def X80 : RISCVReg<80,"x80", ["s44"]>, DwarfRegNum<[80]>;
  def X81 : RISCVReg<81,"x81", ["s45"]>, DwarfRegNum<[81]>;
  def X82 : RISCVReg<82,"x82", ["s46"]>, DwarfRegNum<[82]>;
  def X83 : RISCVReg<83,"x83", ["s47"]>, DwarfRegNum<[83]>;
  def X84 : RISCVReg<84,"x84", ["s48"]>, DwarfRegNum<[84]>;
  def X85 : RISCVReg<85,"x85", ["s49"]>, DwarfRegNum<[85]>;
  def X86 : RISCVReg<86,"x86", ["s50"]>, DwarfRegNum<[86]>;
  def X87 : RISCVReg<87,"x87", ["s51"]>, DwarfRegNum<[87]>;
  def X88 : RISCVReg<88,"x88", ["s52"]>, DwarfRegNum<[88]>;
  def X89 : RISCVReg<89,"x89", ["s53"]>, DwarfRegNum<[89]>;
  def X90 : RISCVReg<90,"x90", ["s54"]>, DwarfRegNum<[90]>;
  def X91 : RISCVReg<91,"x91", ["s55"]>, DwarfRegNum<[91]>;
  def X92 : RISCVReg<92,"x92", ["s56"]>, DwarfRegNum<[92]>;
  def X93 : RISCVReg<93,"x93", ["s57"]>, DwarfRegNum<[93]>;
  def X94 : RISCVReg<94,"x94", ["s58"]>, DwarfRegNum<[94]>;
  def X95 : RISCVReg<95,"x95", ["s59"]>, DwarfRegNum<[95]>;

  def X96 : RISCVReg<96,"x96", ["t7"]> , DwarfRegNum<[96]>;
  def X97 : RISCVReg<97,"x97", ["t8"]>,  DwarfRegNum<[97]>;
  def X98 : RISCVReg<98,"x98", ["t9"]>,  DwarfRegNum<[98]>;
  def X99 : RISCVReg<99,"x99", ["t10"]>, DwarfRegNum<[99]>;
  def X100 : RISCVReg<100,"x100", ["t11"]>, DwarfRegNum<[100]>;
  def X101 : RISCVReg<101,"x101", ["t12"]>, DwarfRegNum<[101]>;
  def X102 : RISCVReg<102,"x102", ["t13"]>, DwarfRegNum<[102]>;
  def X103 : RISCVReg<103,"x103", ["t14"]>, DwarfRegNum<[103]>;
  def X104 : RISCVReg<104,"x104", ["t15"]>, DwarfRegNum<[104]>;
  def X105 : RISCVReg<105,"x105", ["t16"]>, DwarfRegNum<[105]>;
  def X106 : RISCVReg<106,"x106", ["t17"]>, DwarfRegNum<[106]>;
  def X107 : RISCVReg<107,"x107", ["t18"]>, DwarfRegNum<[107]>;
  def X108 : RISCVReg<108,"x108", ["t19"]>, DwarfRegNum<[108]>;
  def X109 : RISCVReg<109,"x109", ["t20"]>, DwarfRegNum<[109]>;
  def X110 : RISCVReg<110,"x110", ["t21"]>, DwarfRegNum<[110]>;
  def X111 : RISCVReg<111,"x111", ["t22"]>, DwarfRegNum<[111]>;
  def X112 : RISCVReg<112,"x112", ["t23"]>, DwarfRegNum<[112]>;
  def X113 : RISCVReg<113,"x113", ["t24"]>, DwarfRegNum<[113]>;
  def X114 : RISCVReg<114,"x114", ["t25"]>, DwarfRegNum<[114]>;
  def X115 : RISCVReg<115,"x115", ["t26"]>, DwarfRegNum<[115]>;
  def X116 : RISCVReg<116,"x116", ["t27"]>, DwarfRegNum<[116]>;
  def X117 : RISCVReg<117,"x117", ["t28"]>, DwarfRegNum<[117]>;
  def X118 : RISCVReg<118,"x118", ["t29"]>, DwarfRegNum<[118]>;
  def X119 : RISCVReg<119,"x119", ["t30"]>, DwarfRegNum<[119]>;
  def X120 : RISCVReg<120,"x120", ["t31"]>, DwarfRegNum<[120]>;
  def X121 : RISCVReg<121,"x121", ["t32"]>, DwarfRegNum<[121]>;
  def X122 : RISCVReg<122,"x122", ["t33"]>, DwarfRegNum<[122]>;
  def X123 : RISCVReg<123,"x123", ["t34"]>, DwarfRegNum<[123]>;
  def X124 : RISCVReg<124,"x124", ["t35"]>, DwarfRegNum<[124]>;
  def X125 : RISCVReg<125,"x125", ["t36"]>, DwarfRegNum<[125]>;
  def X126 : RISCVReg<126,"x126", ["t37"]>, DwarfRegNum<[126]>;
  def X127 : RISCVReg<127,"x127", ["t38"]>, DwarfRegNum<[127]>;
  }
}

def XLenVT : ValueTypeByHwMode<[RV32, RV64],
                               [i32,  i64]>;
def XLenRI : RegInfoByHwMode<
      [RV32,              RV64],
      [RegInfo<32,32,32>, RegInfo<64,64,64>]>;

// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPR : RegisterClass<"RISCV", [XLenVT], 32, (add
    (sequence "X%u", 10, 17),  // a0-a7
    (sequence "X%u", 32, 47),  // a8-a23
    (sequence "X%u", 5, 7),    // t0-t2
    (sequence "X%u", 28, 31),  // t3-t6
    (sequence "X%u", 96, 127), // t7-t38
    (sequence "X%u", 8, 9),    // s0-s1
    (sequence "X%u", 18, 27),  // s2-s11
    (sequence "X%u", 48, 95),  // s12-s59
    (sequence "X%u", 0, 4)
  )> {
  let RegInfos = XLenRI;
}

def GPRX0 : RegisterClass<"RISCV", [XLenVT], 32, (add X0)> {
  let RegInfos = XLenRI;
}

def GPRNoX0 : RegisterClass<"RISCV", [XLenVT], 32, (sub GPR, X0)> {
  let RegInfos = XLenRI;
}

def GPRNoX0X2 : RegisterClass<"RISCV", [XLenVT], 32, (sub GPR, X0, X2)> {
  let RegInfos = XLenRI;
}

// Don't use X1 or X5 for JALR since that is a hint to pop the return address
// stack on some microarchitectures. Also remove the reserved registers X0, X2,
// X3, and X4 as it reduces the number of register classes that get synthesized
// by tablegen.
def GPRJALR : RegisterClass<"RISCV", [XLenVT], 32, (sub GPR, (sequence "X%u", 0, 5))> {
  let RegInfos = XLenRI;
}

def GPRC : RegisterClass<"RISCV", [XLenVT], 32, (add
    (sequence "X%u", 10, 15),
    (sequence "X%u", 8, 9)
  )> {
  let RegInfos = XLenRI;
}

// For indirect tail calls, we can't use callee-saved registers, as they are
// restored to the saved value before the tail call, which would clobber a call
// address. We shouldn't use x5 since that is a hint for to pop the return
// address stack on some microarchitectures.
def GPRTC : RegisterClass<"RISCV", [XLenVT], 32, (add
    (sequence "X%u", 6, 7),
    (sequence "X%u", 10, 17),
    (sequence "X%u", 32, 47),  // a8-a23
    (sequence "X%u", 28, 31),
    (sequence "X%u", 96, 127) // t7-t38
  )> {
  let RegInfos = XLenRI;
}

// GPR classes for each bank (stripe) of registers (mod 4)
def GPRB0 : RegisterClass<"RISCV", [XLenVT], 32,
  (add X0, X4, X8, X12, X16, X20, X24, X28, X32, X36, X40, X44, X48, X52, X56, X60,
    X64, X68, X72, X76, X80, X84, X88, X92, X96, X100, X104, X108, X112, X116, X120, X124)> {
  let RegInfos = XLenRI;
}
def GPRB1 : RegisterClass<"RISCV", [XLenVT], 32, 
  (add X1, X5, X9, X13, X17, X21, X25, X29, X33, X37, X41, X45, X49, X53, X57, X61,
    X65, X69, X73, X77, X81, X85, X89, X93, X97, X101, X105, X109, X113, X117, X121, X125)> {
  let RegInfos = XLenRI;
}
def GPRB2 : RegisterClass<"RISCV", [XLenVT], 32, 
  (add X2, X6, X10, X14, X18, X22, X26, X30, X34, X38, X42, X46, X50, X54, X58, X62,
    X66, X70, X74, X78, X82, X86, X90, X94, X98, X102, X106, X110, X114, X118, X122, X126)> {
  let RegInfos = XLenRI;
}
def GPRB3 : RegisterClass<"RISCV", [XLenVT], 32, 
  (add X3, X7, X11, X15, X19, X23, X27, X31, X35, X39, X43, X47, X51, X55, X59, X63,
    X67, X71, X75, X79, X83, X87, X91, X95, X99, X103, X107, X111, X115, X119, X123, X127)> {
  let RegInfos = XLenRI;
}

def SP : RegisterClass<"RISCV", [XLenVT], 32, (add X2)> {
  let RegInfos = XLenRI;
}

// Floating point registers
let RegAltNameIndices = [ABIRegAltName] in {
  def F0_H  : RISCVReg16<0, "f0", ["ft0"]>, DwarfRegNum<[128]>;
  def F1_H  : RISCVReg16<1, "f1", ["ft1"]>, DwarfRegNum<[129]>;
  def F2_H  : RISCVReg16<2, "f2", ["ft2"]>, DwarfRegNum<[130]>;
  def F3_H  : RISCVReg16<3, "f3", ["ft3"]>, DwarfRegNum<[131]>;
  def F4_H  : RISCVReg16<4, "f4", ["ft4"]>, DwarfRegNum<[132]>;
  def F5_H  : RISCVReg16<5, "f5", ["ft5"]>, DwarfRegNum<[133]>;
  def F6_H  : RISCVReg16<6, "f6", ["ft6"]>, DwarfRegNum<[134]>;
  def F7_H  : RISCVReg16<7, "f7", ["ft7"]>, DwarfRegNum<[135]>;
  def F8_H  : RISCVReg16<8, "f8", ["fs0"]>, DwarfRegNum<[136]>;
  def F9_H  : RISCVReg16<9, "f9", ["fs1"]>, DwarfRegNum<[137]>;
  def F10_H  : RISCVReg16<10, "f10", ["fa0"]>, DwarfRegNum<[138]>;
  def F11_H  : RISCVReg16<11, "f11", ["fa1"]>, DwarfRegNum<[139]>;
  def F12_H  : RISCVReg16<12, "f12", ["fa2"]>, DwarfRegNum<[140]>;
  def F13_H  : RISCVReg16<13, "f13", ["fa3"]>, DwarfRegNum<[141]>;
  def F14_H  : RISCVReg16<14, "f14", ["fa4"]>, DwarfRegNum<[142]>;
  def F15_H  : RISCVReg16<15, "f15", ["fa5"]>, DwarfRegNum<[143]>;
  def F16_H  : RISCVReg16<16, "f16", ["fa6"]>, DwarfRegNum<[144]>;
  def F17_H  : RISCVReg16<17, "f17", ["fa7"]>, DwarfRegNum<[145]>;
  def F18_H  : RISCVReg16<18, "f18", ["fs2"]>, DwarfRegNum<[146]>;
  def F19_H  : RISCVReg16<19, "f19", ["fs3"]>, DwarfRegNum<[147]>;
  def F20_H  : RISCVReg16<20, "f20", ["fs4"]>, DwarfRegNum<[148]>;
  def F21_H  : RISCVReg16<21, "f21", ["fs5"]>, DwarfRegNum<[149]>;
  def F22_H  : RISCVReg16<22, "f22", ["fs6"]>, DwarfRegNum<[150]>;
  def F23_H  : RISCVReg16<23, "f23", ["fs7"]>, DwarfRegNum<[151]>;
  def F24_H  : RISCVReg16<24, "f24", ["fs8"]>, DwarfRegNum<[152]>;
  def F25_H  : RISCVReg16<25, "f25", ["fs9"]>, DwarfRegNum<[153]>;
  def F26_H  : RISCVReg16<26, "f26", ["fs10"]>, DwarfRegNum<[154]>;
  def F27_H  : RISCVReg16<27, "f27", ["fs11"]>, DwarfRegNum<[155]>;
  def F28_H  : RISCVReg16<28, "f28", ["ft8"]>, DwarfRegNum<[156]>;
  def F29_H  : RISCVReg16<29, "f29", ["ft9"]>, DwarfRegNum<[157]>;
  def F30_H  : RISCVReg16<30, "f30", ["ft10"]>, DwarfRegNum<[158]>;
  def F31_H  : RISCVReg16<31, "f31", ["ft11"]>, DwarfRegNum<[159]>;
  def F32_H  : RISCVReg16<32, "f32", ["fa8"]>, DwarfRegNum<[160]>;
  def F33_H  : RISCVReg16<33, "f33", ["fa9"]>, DwarfRegNum<[161]>;
  def F34_H  : RISCVReg16<34, "f34", ["fa10"]>, DwarfRegNum<[162]>;
  def F35_H  : RISCVReg16<35, "f35", ["fa11"]>, DwarfRegNum<[163]>;
  def F36_H  : RISCVReg16<36, "f36", ["fa12"]>, DwarfRegNum<[164]>;
  def F37_H  : RISCVReg16<37, "f37", ["fa13"]>, DwarfRegNum<[165]>;
  def F38_H  : RISCVReg16<38, "f38", ["fa14"]>, DwarfRegNum<[166]>;
  def F39_H  : RISCVReg16<39, "f39", ["fa15"]>, DwarfRegNum<[167]>;
  def F40_H  : RISCVReg16<40, "f40", ["fs12"]>, DwarfRegNum<[168]>;
  def F41_H  : RISCVReg16<41, "f41", ["fs13"]>, DwarfRegNum<[169]>;
  def F42_H  : RISCVReg16<42, "f42", ["fs14"]>, DwarfRegNum<[170]>;
  def F43_H  : RISCVReg16<43, "f43", ["fs15"]>, DwarfRegNum<[171]>;
  def F44_H  : RISCVReg16<44, "f44", ["fs16"]>, DwarfRegNum<[172]>;
  def F45_H  : RISCVReg16<45, "f45", ["fs17"]>, DwarfRegNum<[173]>;
  def F46_H  : RISCVReg16<46, "f46", ["fs18"]>, DwarfRegNum<[174]>;
  def F47_H  : RISCVReg16<47, "f47", ["fs19"]>, DwarfRegNum<[175]>;
  def F48_H  : RISCVReg16<48, "f48", ["fs20"]>, DwarfRegNum<[176]>;
  def F49_H  : RISCVReg16<49, "f49", ["fs21"]>, DwarfRegNum<[177]>;
  def F50_H  : RISCVReg16<50, "f50", ["fs22"]>, DwarfRegNum<[178]>;
  def F51_H  : RISCVReg16<51, "f51", ["fs23"]>, DwarfRegNum<[179]>;
  def F52_H  : RISCVReg16<52, "f52", ["ft12"]>, DwarfRegNum<[180]>;
  def F53_H  : RISCVReg16<53, "f53", ["ft13"]>, DwarfRegNum<[181]>;
  def F54_H  : RISCVReg16<54, "f54", ["ft14"]>, DwarfRegNum<[182]>;
  def F55_H  : RISCVReg16<55, "f55", ["ft15"]>, DwarfRegNum<[183]>;
  def F56_H  : RISCVReg16<56, "f56", ["ft16"]>, DwarfRegNum<[184]>;
  def F57_H  : RISCVReg16<57, "f57", ["ft17"]>, DwarfRegNum<[185]>;
  def F58_H  : RISCVReg16<58, "f58", ["ft18"]>, DwarfRegNum<[186]>;
  def F59_H  : RISCVReg16<59, "f59", ["ft19"]>, DwarfRegNum<[187]>;
  def F60_H  : RISCVReg16<60, "f60", ["ft20"]>, DwarfRegNum<[188]>;
  def F61_H  : RISCVReg16<61, "f61", ["ft21"]>, DwarfRegNum<[189]>;
  def F62_H  : RISCVReg16<62, "f62", ["ft22"]>, DwarfRegNum<[190]>;
  def F63_H  : RISCVReg16<63, "f63", ["ft23"]>, DwarfRegNum<[191]>;

  foreach Index = 0-63 in {
    def F#Index#_F : RISCVReg32<!cast<RISCVReg16>("F"#Index#"_H")>,
      DwarfRegNum<[!add(Index, 128)]>;
  }

  foreach Index = 0-63 in {
    def F#Index#_D : RISCVReg64<!cast<RISCVReg32>("F"#Index#"_F")>,
      DwarfRegNum<[!add(Index, 128)]>;
  }
}

// The order of registers represents the preferred allocation sequence,
// meaning caller-save regs are listed before callee-save.
def FPR16 : RegisterClass<"RISCV", [f16], 16, (add
    (sequence "F%u_H", 0, 7),   // ft0-ft7
    (sequence "F%u_H", 10, 17), // fa0-fa7
    (sequence "F%u_H", 28, 31), // ft8-ft11
    (sequence "F%u_H", 52, 63), // ft12-ft23
    (sequence "F%u_H", 32, 39), // fa8-fa15
    (sequence "F%u_H", 8, 9),   // fs0-fs1
    (sequence "F%u_H", 18, 27), // fs2-fs11
    (sequence "F%u_H", 40, 51)  // fs12-fs23
)>;

def FPR32 : RegisterClass<"RISCV", [f32], 32, (add
    (sequence "F%u_F", 0, 7),   // ft0-ft7
    (sequence "F%u_F", 10, 17), // fa0-fa7
    (sequence "F%u_F", 28, 31), // ft8-ft11
    (sequence "F%u_F", 52, 63), // ft12-ft23
    (sequence "F%u_F", 32, 39), // fa8-fa15
    (sequence "F%u_F", 8, 9),   // fs0-fs1
    (sequence "F%u_F", 18, 27), // fs2-fs11
    (sequence "F%u_F", 40, 51)  // fs12-fs23
)>;

def FPR32C : RegisterClass<"RISCV", [f32], 32, (add
  (sequence "F%u_F", 10, 15),
  (sequence "F%u_F", 8, 9)
)>;

// The order of registers represents the preferred allocation sequence,
// meaning caller-save regs are listed before callee-save.
def FPR64 : RegisterClass<"RISCV", [f64], 64, (add
    (sequence "F%u_D", 0, 7),
    (sequence "F%u_D", 10, 17),
    (sequence "F%u_D", 28, 31),
    (sequence "F%u_D", 52, 63), // ft12-ft23
    (sequence "F%u_D", 32, 39), // fa8-fa15
    (sequence "F%u_D", 8, 9),
    (sequence "F%u_D", 18, 27),
    (sequence "F%u_D", 40, 51)  // fs12-fs23
)>;

def FPR64C : RegisterClass<"RISCV", [f64], 64, (add
  (sequence "F%u_D", 10, 15),
  (sequence "F%u_D", 8, 9)
)>;

// FPR classes for each bank (stripe) of registers (mod 4)
def FPRB0 : RegisterClass<"RISCV", [f32], 32, (add F0_F, F4_F, F8_F, F12_F, F16_F, F20_F, F24_F, F28_F, F32_F, F36_F, F40_F, F44_F, F48_F, F52_F, F56_F, F60_F)>;
def FPRB1 : RegisterClass<"RISCV", [f32], 32, (add F1_F, F5_F, F9_F, F13_F, F17_F, F21_F, F25_F, F29_F, F33_F, F37_F, F41_F, F45_F, F49_F, F53_F, F57_F, F61_F)>;
def FPRB2 : RegisterClass<"RISCV", [f32], 32, (add F2_F, F6_F, F10_F, F14_F, F18_F, F22_F, F26_F, F30_F, F34_F, F38_F, F42_F, F46_F, F50_F, F54_F, F58_F, F62_F)>;
def FPRB3 : RegisterClass<"RISCV", [f32], 32, (add F3_F, F7_F, F11_F, F15_F, F19_F, F23_F, F27_F, F31_F, F35_F, F39_F, F43_F, F47_F, F51_F, F55_F, F59_F, F63_F)>;

//===----------------------------------------------------------------------===//
// Vector type mapping to LLVM types.
//
// The V vector extension requires that VLEN >= 128 and <= 65536.
// Additionally, the only supported ELEN values are 32 and 64,
// thus `vscale` can be defined as VLEN/64,
// allowing the same types with either ELEN value.
//
//         MF8    MF4     MF2     M1      M2      M4       M8
// i64*    N/A    N/A     N/A     nxv1i64 nxv2i64 nxv4i64  nxv8i64
// i32     N/A    N/A     nxv1i32 nxv2i32 nxv4i32 nxv8i32  nxv16i32
// i16     N/A    nxv1i16 nxv2i16 nxv4i16 nxv8i16 nxv16i16 nxv32i16
// i8      nxv1i8 nxv2i8  nxv4i8  nxv8i8  nxv16i8 nxv32i8  nxv64i8
// double* N/A    N/A     N/A     nxv1f64 nxv2f64 nxv4f64  nxv8f64
// float   N/A    N/A     nxv1f32 nxv2f32 nxv4f32 nxv8f32  nxv16f32
// half    N/A    nxv1f16 nxv2f16 nxv4f16 nxv8f16 nxv16f16 nxv32f16
// * ELEN=64

defvar vint8mf8_t = nxv1i8;
defvar vint8mf4_t = nxv2i8;
defvar vint8mf2_t = nxv4i8;
defvar vint8m1_t = nxv8i8;
defvar vint8m2_t = nxv16i8;
defvar vint8m4_t = nxv32i8;
defvar vint8m8_t = nxv64i8;

defvar vint16mf4_t = nxv1i16;
defvar vint16mf2_t = nxv2i16;
defvar vint16m1_t  = nxv4i16;
defvar vint16m2_t  = nxv8i16;
defvar vint16m4_t  = nxv16i16;
defvar vint16m8_t  = nxv32i16;

defvar vint32mf2_t = nxv1i32;
defvar vint32m1_t  = nxv2i32;
defvar vint32m2_t  = nxv4i32;
defvar vint32m4_t  = nxv8i32;
defvar vint32m8_t  = nxv16i32;

defvar vint64m1_t = nxv1i64;
defvar vint64m2_t = nxv2i64;
defvar vint64m4_t = nxv4i64;
defvar vint64m8_t = nxv8i64;

defvar vfloat16mf4_t = nxv1f16;
defvar vfloat16mf2_t = nxv2f16;
defvar vfloat16m1_t  = nxv4f16;
defvar vfloat16m2_t  = nxv8f16;
defvar vfloat16m4_t  = nxv16f16;
defvar vfloat16m8_t  = nxv32f16;

defvar vfloat32mf2_t = nxv1f32;
defvar vfloat32m1_t  = nxv2f32;
defvar vfloat32m2_t  = nxv4f32;
defvar vfloat32m4_t  = nxv8f32;
defvar vfloat32m8_t  = nxv16f32;

defvar vfloat64m1_t = nxv1f64;
defvar vfloat64m2_t = nxv2f64;
defvar vfloat64m4_t = nxv4f64;
defvar vfloat64m8_t = nxv8f64;

defvar vbool1_t  = nxv64i1;
defvar vbool2_t  = nxv32i1;
defvar vbool4_t  = nxv16i1;
defvar vbool8_t  = nxv8i1;
defvar vbool16_t = nxv4i1;
defvar vbool32_t = nxv2i1;
defvar vbool64_t = nxv1i1;

// There is no need to define register classes for fractional LMUL.
def LMULList {
  list<int> m = [1, 2, 4, 8];
}

//===----------------------------------------------------------------------===//
// Utility classes for segment load/store.
//===----------------------------------------------------------------------===//
// The set of legal NF for LMUL = lmul.
// LMUL == 1, NF = 2, 3, 4, 5, 6, 7, 8
// LMUL == 2, NF = 2, 3, 4
// LMUL == 4, NF = 2
class NFList<int lmul> {
  list<int> L = !cond(!eq(lmul, 1): [2, 3, 4, 5, 6, 7, 8],
                      !eq(lmul, 2): [2, 3, 4],
                      !eq(lmul, 4): [2],
                      !eq(lmul, 8): []);
}

// Generate [start, end) SubRegIndex list.
class SubRegSet<int nf, int lmul> {
  list<SubRegIndex> L = !foldl([]<SubRegIndex>,
                               [0, 1, 2, 3, 4, 5, 6, 7],
                               AccList, i,
                               !listconcat(AccList,
                                 !if(!lt(i, nf),
                                   [!cast<SubRegIndex>("sub_vrm" # lmul # "_" # i)],
                                   [])));
}

// Collect the valid indexes into 'R' under NF and LMUL values from TUPLE_INDEX.
// When NF = 2, the valid TUPLE_INDEX is 0 and 1.
// For example, when LMUL = 4, the potential valid indexes is
// [8, 12, 16, 20, 24, 28, 4]. However, not all these indexes are valid under
// NF = 2. For example, 28 is not valid under LMUL = 4, NF = 2 and TUPLE_INDEX = 0.
// The filter is
//   (tuple_index + i) x lmul <= (tuple_index x lmul) + 32 - (nf x lmul)
//
// Use START = 0, LMUL = 4 and NF = 2 as the example,
//   i x 4 <= 24
// The class will return [8, 12, 16, 20, 24, 4].
// Use START = 1, LMUL = 4 and NF = 2 as the example,
//   (1 + i) x 4 <= 28
// The class will return [12, 16, 20, 24, 28, 8].
//
class IndexSet<int tuple_index, int nf, int lmul, bit isV0 = false> {
  list<int> R =
    !foldl([]<int>,
              !if(isV0, [0],
                !cond(
                  !eq(lmul, 1):
                  [8, 9, 10, 11, 12, 13, 14, 15,
                   16, 17, 18, 19, 20, 21, 22, 23,
                   24, 25, 26, 27, 28, 29, 30, 31,
                   1, 2, 3, 4, 5, 6, 7],
                  !eq(lmul, 2):
                  [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1, 2, 3],
                  !eq(lmul, 4):
                  [2, 3, 4, 5, 6, 7, 1])),
              L, i,
              !listconcat(L,
                          !if(!le(!mul(!add(i, tuple_index), lmul),
                                  !sub(!add(32, !mul(tuple_index, lmul)), !mul(nf, lmul))),
                              [!mul(!add(i, tuple_index), lmul)], [])));
}

// This class returns a list of vector register collections.
// For example, for NF = 2 and LMUL = 4,
// it will return
//   ([ V8M4, V12M4, V16M4, V20M4, V24M4, V4M4],
//    [V12M4, V16M4, V20M4, V24M4, V28M4, V8M4])
//
class VRegList<list<dag> LIn, int start, int nf, int lmul, bit isV0> {
  list<dag> L =
    !if(!ge(start, nf),
        LIn,
        !listconcat(
          [!dag(add,
                !foreach(i, IndexSet<start, nf, lmul, isV0>.R,
                  !cast<Register>("V" # i # !cond(!eq(lmul, 2): "M2",
                                                  !eq(lmul, 4): "M4",
                                                  true: ""))),
                !listsplat("",
                  !size(IndexSet<start, nf, lmul, isV0>.R)))],
          VRegList<LIn, !add(start, 1), nf, lmul, isV0>.L));
}

// Vector registers
let RegAltNameIndices = [ABIRegAltName] in {
  foreach Index = 0-31 in {
    def V#Index : RISCVReg<Index, "v"#Index, ["v"#Index]>, DwarfRegNum<[!add(Index, 96)]>;
  }

  foreach Index = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22,
                   24, 26, 28, 30] in {
    def V#Index#M2 : RISCVRegWithSubRegs<Index, "v"#Index,
                       [!cast<Register>("V"#Index),
                        !cast<Register>("V"#!add(Index, 1))],
                       ["v"#Index]>,
                     DwarfRegAlias<!cast<Register>("V"#Index)> {
      let SubRegIndices = [sub_vrm1_0, sub_vrm1_1];
    }
  }

  foreach Index = [0, 4, 8, 12, 16, 20, 24, 28] in {
    def V#Index#M4 : RISCVRegWithSubRegs<Index, "v"#Index,
                       [!cast<Register>("V"#Index#"M2"),
                        !cast<Register>("V"#!add(Index, 2)#"M2")],
                       ["v"#Index]>,
                     DwarfRegAlias<!cast<Register>("V"#Index)> {
      let SubRegIndices = [sub_vrm2_0, sub_vrm2_1];
    }
  }

  foreach Index = [0, 8, 16, 24] in {
    def V#Index#M8 : RISCVRegWithSubRegs<Index, "v"#Index,
                       [!cast<Register>("V"#Index#"M4"),
                        !cast<Register>("V"#!add(Index, 4)#"M4")],
                       ["v"#Index]>,
                     DwarfRegAlias<!cast<Register>("V"#Index)> {
      let SubRegIndices = [sub_vrm4_0, sub_vrm4_1];
    }
  }

  def VTYPE  : RISCVReg<0, "vtype", ["vtype"]>;
  def VL     : RISCVReg<0, "vl", ["vl"]>;
  def VXSAT  : RISCVReg<0, "vxsat", ["vxsat"]>;
  def VXRM   : RISCVReg<0, "vxrm", ["vxrm"]>;
  let isConstant = true in
  def VLENB  : RISCVReg<0, "vlenb", ["vlenb"]>,
               DwarfRegNum<[!add(4096, SysRegVLENB.Encoding)]>;
}

def VCSR : RegisterClass<"RISCV", [XLenVT], 32,
                          (add VTYPE, VL, VLENB)> {
  let RegInfos = XLenRI;
}


foreach m = [1, 2, 4] in {
  foreach n = NFList<m>.L in {
    def "VN" # n # "M" # m # "NoV0": RegisterTuples<
                                       SubRegSet<n, m>.L,
                                       VRegList<[], 0, n, m, false>.L>;
    def "VN" # n # "M" # m # "V0" : RegisterTuples<
                                       SubRegSet<n, m>.L,
                                       VRegList<[], 0, n, m, true>.L>;
  }
}

class VReg<list<ValueType> regTypes, dag regList, int Vlmul>
  : RegisterClass<"RISCV",
                  regTypes,
                  64, // The maximum supported ELEN is 64.
                  regList> {
  int VLMul = Vlmul;
  int Size = !mul(Vlmul, 64);
}

defvar VMaskVTs = [vbool1_t, vbool2_t, vbool4_t, vbool8_t, vbool16_t,
                   vbool32_t, vbool64_t];

defvar VM1VTs = [vint8m1_t, vint16m1_t, vint32m1_t, vint64m1_t,
                 vfloat16m1_t, vfloat32m1_t, vfloat64m1_t,
                 vint8mf2_t, vint8mf4_t, vint8mf8_t,
                 vint16mf2_t, vint16mf4_t, vint32mf2_t,
                 vfloat16mf4_t, vfloat16mf2_t, vfloat32mf2_t];

defvar VM2VTs = [vint8m2_t, vint16m2_t, vint32m2_t, vint64m2_t,
                 vfloat16m2_t, vfloat32m2_t, vfloat64m2_t];

defvar VM4VTs = [vint8m4_t, vint16m4_t, vint32m4_t, vint64m4_t,
                 vfloat16m4_t, vfloat32m4_t, vfloat64m4_t];

defvar VM8VTs = [vint8m8_t, vint16m8_t, vint32m8_t, vint64m8_t,
                 vfloat16m8_t, vfloat32m8_t, vfloat64m8_t];

def VR : VReg<!listconcat(VM1VTs, VMaskVTs),
              (add (sequence "V%u", 8, 31),
                   (sequence "V%u", 0, 7)), 1>;

def VRNoV0 : VReg<!listconcat(VM1VTs, VMaskVTs),
                  (add (sequence "V%u", 8, 31),
                       (sequence "V%u", 1, 7)), 1>;

def VRM2 : VReg<VM2VTs, (add (sequence "V%uM2", 8, 31, 2),
                             (sequence "V%uM2", 0, 7, 2)), 2>;

def VRM2NoV0 : VReg<VM2VTs, (add (sequence "V%uM2", 8, 31, 2),
                                 (sequence "V%uM2", 2, 7, 2)), 2>;

def VRM4 : VReg<VM4VTs,
             (add V8M4, V12M4, V16M4, V20M4, V24M4, V28M4, V0M4, V4M4), 4>;

def VRM4NoV0 : VReg<VM4VTs,
             (add V8M4, V12M4, V16M4, V20M4, V24M4, V28M4, V4M4), 4>;

def VRM8 : VReg<VM8VTs, (add V8M8, V16M8, V24M8, V0M8), 8>;

def VRM8NoV0 : VReg<VM8VTs, (add V8M8, V16M8, V24M8), 8>;

def VMV0 : RegisterClass<"RISCV", VMaskVTs, 64, (add V0)> {
  let Size = 64;
}

let RegInfos = XLenRI in {
def GPRF16  : RegisterClass<"RISCV", [f16], 16, (add GPR)>;
def GPRF32  : RegisterClass<"RISCV", [f32], 32, (add GPR)>;
def GPRF64  : RegisterClass<"RISCV", [f64], 64, (add GPR)>;
} // RegInfos = XLenRI

let RegAltNameIndices = [ABIRegAltName] in {
  foreach Index = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22,
                   24, 26, 28, 30] in {
    defvar Reg = !cast<Register>("X"#Index);
    def X#Index#_PD : RISCVRegWithSubRegs<Index, Reg.AsmName,
                                          [!cast<Register>("X"#Index),
                                           !cast<Register>("X"#!add(Index, 1))],
                                           Reg.AltNames> {
      let SubRegIndices = [sub_32, sub_32_hi];
    }
  }
}


// TODO (richard): this is defining floating points in GPRs,
// need to enable storing floats in all the new GPRs
let RegInfos = RegInfoByHwMode<[RV64], [RegInfo<64, 64, 64>]> in
def GPRPF64 : RegisterClass<"RISCV", [f64], 64, (add
    X10_PD, X12_PD, X14_PD, X16_PD,
    X6_PD,
    X28_PD, X30_PD,
    X8_PD,
    X18_PD, X20_PD, X22_PD, X24_PD, X26_PD,
    X0_PD, X2_PD, X4_PD
)>;

// The register class is added for inline assembly for vector mask types.
def VM : VReg<VMaskVTs,
           (add (sequence "V%u", 8, 31),
                (sequence "V%u", 0, 7)), 1>;

foreach m = LMULList.m in {
  foreach nf = NFList<m>.L in {
    def "VRN" # nf # "M" # m # "NoV0": VReg<[untyped],
                               (add !cast<RegisterTuples>("VN" # nf # "M" # m # "NoV0")),
                                    !mul(nf, m)>;
    def "VRN" # nf # "M" # m: VReg<[untyped],
                               (add !cast<RegisterTuples>("VN" # nf # "M" # m # "NoV0"),
                                    !cast<RegisterTuples>("VN" # nf # "M" # m # "V0")),
                                    !mul(nf, m)>;
  }
}

// Special registers
def FFLAGS : RISCVReg<0, "fflags">;
def FRM    : RISCVReg<0, "frm">;

// Any type register. Used for .insn directives when we don't know what the
// register types could be.
// NOTE: The alignment and size are bogus values. The Size needs to be non-zero
// or tablegen will use "untyped" to determine the size which will assert.
let isAllocatable = 0 in
def AnyReg : RegisterClass<"RISCV", [untyped], 32,
                           (add (sequence "X%u", 0, 127),
                                (sequence "F%u_D", 0, 63),
                                (sequence "V%u", 0, 31))> {
  let Size = 32;
}
