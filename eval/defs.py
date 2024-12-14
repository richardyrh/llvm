ignore_opcode_prefix = ['amoswap', 'auipc', 'beq', 'bne', 'blt', 'bgt', 'call', 'csr', 'ebreak', 'ecall',
                        'fmv', 'fcvt',
                        'fence', 'j', 'jal', 'jalr', 'l', 'mv', 'sc', 'snez', 'ret']
ignore_opcode_suffix = ['i', 'iw']
ignore_prefix = ['#', '.']

reg_pres = ([ 't',  's',  'a']
          + ['ft', 'fs', 'fa'])
reg_ranges = ([list(range(38)), list(range(59)), list(range(23))] 
            + [list(range(23)), list(range(23)), list(range(15))])

num_reg_banks = {'x': 4, 'f': 4}

def abi_to_register(reg):
    #horrifyingly hardcoded
    table = {
        'zero': 'x0',
        'ra': 'x1',
        'sp': 'x2',
        'gp': 'x3',
        'tp': 'x4',
        'fp': 'x8',
        'ra': 'x31'
    }

    if reg in table:
        return table[reg]
    
    id = reg[0]
    idx = int(reg[2:]) if id == 'f' else int(reg[1:])
    
    if id == 'f':
        id_1 = reg[1]
        if id_1 == 't':
            return 'f' + (str(idx) if idx <= 7 else (str(idx+20) if idx <= 11 else str(idx+40)))
        if id_1 == 's':
            return 'f' + (str(idx + 8) if idx <= 1 else (str(idx+16) if idx <= 11 else str(idx+28)))
        if id_1 == 'a':
            return 'f' + (str(idx + 10) if idx <= 7 else str(idx+24))
    if id == 't':
        return 'x' + (str(idx+5) if idx <= 2 else (str(idx+25) if idx <= 6 else str(idx+89)))
    if id == 's':
        return 'x' + (str(idx+8) if idx <= 1 else (str(idx+16) if idx <= 11 else str(idx+36)))
    if id == 'a':
        return 'x' + (str(idx+10) if idx <= 7 else str(idx+24)) 
    
    return None

