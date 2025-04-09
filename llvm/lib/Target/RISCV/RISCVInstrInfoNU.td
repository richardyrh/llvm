// Neutrino instruction definitions

class NeutrinoInst<bits<2> ret_mode, bits<2> part_mode, bits<1> sync, bits<2> ext2, dag outs,
                   dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR5> {

  // bits<4> pred;
  bits<6> elems;

  bits<8> rs4; /* dep 2 */
  bits<8> rs3; /* dep 1 */
  bits<8> rs2; /* dep 0 */
  bits<8> rs1; /* task id */
  bits<8> rd;  /* job id */

  let Inst{63-60} = 0; // pred;
  let Inst{59-54} = elems;
  let Inst{53-52} = part_mode;
  let Inst{51-44} = rs4;
  let Inst{43-36} = rs3;
  let Inst{35-28} = rs2;
  let Inst{27-20} = rs1;
  let Inst{19-18} = ret_mode;
  let Inst{17} = sync;
  let Inst{16-9} = rd;
  let Inst{8-7} = ext2;
  let Inst{6-0} = 0b1011011; // custom2
}

class NuInvokeInst<bits<2> ret_mode, bits<2> part_mode, bits<1> sync, bits<2> ext2, string opcodestr>
    : NeutrinoInst<ret_mode, part_mode, sync, ext2,
                   (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems),
                   opcodestr, "$rd, $rs1, $rs2, $rs3, $rs4, $elems">, Sched<[]>;

let hasSideEffects = 1, mayStore = 0 , mayLoad = 0 in {

def NU_INVOKE_RI_PT_ASYNC : NuInvokeInst<0, 0, 0, 0, "nu.invoke.ri.pt.async">;
def NU_INVOKE_RH_PT_ASYNC : NuInvokeInst<1, 0, 0, 0, "nu.invoke.rh.pt.async">;
def NU_INVOKE_RM_PT_ASYNC : NuInvokeInst<2, 0, 0, 0, "nu.invoke.rm.pt.async">;
def NU_INVOKE_RI_PW_ASYNC : NuInvokeInst<0, 1, 0, 0, "nu.invoke.ri.pw.async">;
def NU_INVOKE_RH_PW_ASYNC : NuInvokeInst<1, 1, 0, 0, "nu.invoke.rh.pw.async">;
def NU_INVOKE_RM_PW_ASYNC : NuInvokeInst<2, 1, 0, 0, "nu.invoke.rm.pw.async">;
def NU_INVOKE_RI_PC_ASYNC : NuInvokeInst<0, 2, 0, 0, "nu.invoke.ri.pc.async">;
def NU_INVOKE_RH_PC_ASYNC : NuInvokeInst<1, 2, 0, 0, "nu.invoke.rh.pc.async">;
def NU_INVOKE_RM_PC_ASYNC : NuInvokeInst<2, 2, 0, 0, "nu.invoke.rm.pc.async">;
def NU_INVOKE_RI_PT_SYNC  : NuInvokeInst<0, 0, 1, 0, "nu.invoke.ri.pt.sync">;
def NU_INVOKE_RH_PT_SYNC  : NuInvokeInst<1, 0, 1, 0, "nu.invoke.rh.pt.sync">;
def NU_INVOKE_RM_PT_SYNC  : NuInvokeInst<2, 0, 1, 0, "nu.invoke.rm.pt.sync">;
def NU_INVOKE_RI_PW_SYNC  : NuInvokeInst<0, 1, 1, 0, "nu.invoke.ri.pw.sync">;
def NU_INVOKE_RH_PW_SYNC  : NuInvokeInst<1, 1, 1, 0, "nu.invoke.rh.pw.sync">;
def NU_INVOKE_RM_PW_SYNC  : NuInvokeInst<2, 1, 1, 0, "nu.invoke.rm.pw.sync">;
def NU_INVOKE_RI_PC_SYNC  : NuInvokeInst<0, 2, 1, 0, "nu.invoke.ri.pc.sync">;
def NU_INVOKE_RH_PC_SYNC  : NuInvokeInst<1, 2, 1, 0, "nu.invoke.rh.pc.sync">;
def NU_INVOKE_RM_PC_SYNC  : NuInvokeInst<2, 2, 1, 0, "nu.invoke.rm.pc.sync">;

}

def : Pat<(int_riscv_nu_invoke_ri_pt_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PT_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pt_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PT_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pt_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PT_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_ri_pw_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PW_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pw_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PW_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pw_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PW_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_ri_pc_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PC_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pc_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PC_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pc_async GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PC_ASYNC GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;

def : Pat<(int_riscv_nu_invoke_ri_pt_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PT_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pt_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PT_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pt_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PT_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_ri_pw_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PW_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pw_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PW_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pw_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PW_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_ri_pc_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RI_PC_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rh_pc_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RH_PC_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;
def : Pat<(int_riscv_nu_invoke_rm_pc_sync  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems), (NU_INVOKE_RM_PC_SYNC  GPR:$rs1, GPR:$rs2, GPR:$rs3, GPR:$rs4, uimm6_plus1:$elems)>;

