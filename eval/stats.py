from defs import num_reg_banks

def get_bank_conflicts(instr):
    cnt = 0
    regs = instr['operands'][1:]
    for i in range(len(regs)):
        for j in range(i + 1, len(regs)):  # Compare with elements after i
            banks = num_reg_banks[regs[i][0]]
            if regs[i][0] == regs[j][0] and int(regs[i][1:]) % banks == int(regs[j][1:]) % banks:
                cnt = cnt + 1

    if cnt > 0:
        print("CONFLICT IN: " + str(instr))
    return cnt

def get_statistics(instrs):
    print("STAT START")
    stack_spills = sum(1 for instr in instrs 
          if instr["opcode"] in ['sb', 'sd', 'sh', 'sw'] and instr["operands"][1] == 'x2')
    bank_conflicts = sum([get_bank_conflicts(instr) 
          for instr in instrs if len(instr["operands"]) > 2])
    print("STAT END")
    return [stack_spills, bank_conflicts]

def get_statistics_strs():
    return ['stack_spills', 'bank_conflicts']
                       
def eval_asm(file_path):
    instrs = parse_asm(file_path)
    stats = get_statistics(instrs)
    return stats


