# RUN: llvm-mc %s -triple=riscv32 -mattr=+f,+zfh -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc %s -triple=riscv64 -mattr=+f,+zfh -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+f,+zfh < %s \
# RUN:     | llvm-objdump --mattr=+f,+zfh --no-print-imm-hex -M no-aliases -d -r - \
# RUN:     | FileCheck --check-prefix=CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc -filetype=obj -triple=riscv64 -mattr=+f,+zfh < %s \
# RUN:     | llvm-objdump --mattr=+f,+zfh --no-print-imm-hex -M no-aliases -d -r - \
# RUN:     | FileCheck --check-prefix=CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: fpexp.s ft0, ft1, rne
# CHECK-ASM: encoding: [0xdb,0x00,0x10,0x10,0x00,0x00,0xc0,0x02]
fpexp.s ft0, ft1, rne

# CHECK-ASM-AND-OBJ: fpnexp.s ft2, ft3, rtz
# CHECK-ASM: encoding: [0xdb,0x04,0x32,0x20,0x00,0x00,0xc0,0x02]
fpnexp.s ft2, ft3, rtz

# CHECK-ASM-AND-OBJ: fpexp.h ft4, ft5, dyn
# CHECK-ASM: encoding: [0xdb,0x08,0x5e,0x10,0x00,0x00,0xe0,0x02]
fpexp.h ft4, ft5

# CHECK-ASM-AND-OBJ: fpnexp.h ft6, ft7, rne
# CHECK-ASM: encoding: [0xdb,0x0c,0x70,0x20,0x00,0x00,0xe0,0x02]
fpnexp.h ft6, ft7, rne
