import os
import re

from defs import reg_pres, reg_ranges 
from defs import ignore_opcode_suffix, ignore_opcode_prefix, ignore_prefix, abi_to_register 

def verify_abi_to_reg():
    for i, id in enumerate(reg_pres):
        for idx in reg_ranges[i]:
            if abi_to_register(id + str(idx)) is None:
                print(f"Error: failed to translate {id+str(idx)}")
                return False
    return True

def verify_opcode_ignore(instrs):
    for instr in instrs:
        opcode = instr["opcode"]
        operands = instr["operands"]
        if (len(operands) in [0,1]):
            print(f"Error: zero or single operand instr {opcode, operands}")
            return False
        if (len(operands) == 2 and opcode not in ['sb', 'sd', 'sh', 'sw']):
            print(f"Error: illegal two operand instr {opcode, operands}")
            return False
    return True

def verify_instrs(instrs):
    return verify_opcode_ignore(instrs)

def parse_instr_args(args):
    # ignoring immediates. can be obtained easily if needed
    pattern = r'(-?\d+)\((\w+)\)'
    operands = []
    for arg in args:
        if arg[0].isalpha():
            operands.append(arg)
        elif arg[0].isdigit() or (arg[0] == '-' and arg[1].isdigit()):
            match = re.match(pattern, arg)
            if match:
                offset = int(match.group(1))
                reg_name = match.group(2)
                operands.append(reg_name)
            else:
                printf("Error: Immediate operand instrs should be ignored")
                return None
        else:
            print(f"Error: Invalid operand '{arg}'")
            return None
    return operands

def parse_asm(file_path):
    """
    Parses a RISC-V assembly file (.s), skipping empty lines and comments.
    Prints the assembly instructions.
    """
    
    assert verify_abi_to_reg(), "Failed to verify reg translator"
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return

    # Check file extension
    file_extension = os.path.splitext(file_path)[1]

    if file_extension != '.s':
        print("Error: Unsupported file type. Please provide a .s assembly file.")
        return

    instrs = []
    try:
        with open(file_path, 'r') as file:
            for line in file:

                line = re.sub(r'#.*$', '', line).strip()
                if not line or line.endswith(':') or any(line.startswith(prefix) for prefix in ignore_prefix):
                    continue

                instr_parts = line.replace(',', '').split()
                opcode = instr_parts[0]
                if any(opcode.endswith(suffix) for suffix in ignore_opcode_suffix) or any(opcode.startswith(prefix) for prefix in ignore_opcode_prefix):
                    continue
                
                operands = parse_instr_args(instr_parts[1:])

                instrs.append({'opcode': opcode, 
                               'operands':[abi_to_register(operand) for operand in operands]})
                
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")

   
    assert verify_instrs(instrs), "Failed instr verification"

    return instrs


