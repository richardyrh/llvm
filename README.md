# Radiance LLVM Toolchain

This repository contains the compiler infrastructure for the Radiance project.
It is derived from Vortex's LLVM compiler stack, with some notable changes:

**Encoding:**
* Instruction words are now 64-bit;
* Each instruction can contain up to 4 source registers and 1 destination register;
* Two more bits for opcode;
* Reserved instruction space for predicates;
* Much larger immediates - up to 32-bit for I-type instructions.

**Registers:**
* Register encoding is now 8-bits, which means up to 256 architectural registers;
* Currently, the compiler defines 128 GPRs;
* Floating point numbers are stored in GPRs through the `zfinx` extension, for which some support is backported from LLVM 20.

**Extended ISA:**
* There are new instruction formats that exploit the extra operands and larger immediates;
* New instructions will be added to support Radiance components such as Neutrino instructions;
* Tentative ISA is documented [here](https://github.com/ucb-bar/radiance/blob/main/docs/isa.md).

### To Build

You might find the guide at
[ucb-bar/radiance-kernels](https://github.com/ucb-bar/radiance-kernels/blob/main/README.md)
to be easier for setting up the toolchain along with some tests to run.

Compiling `clang` is similar to the normal LLVM compilation process. To use `clang`
after compiling it, you must have a functional rv32 GNU toolchain. There should
not be a rv64 toolchain existing in the same place as the rv32 toolchain.

To compile `hello.c` to an object file, for example:

```bash
./bin/clang --target=riscv32-unknown-elf -march=rv32im_zfinx --sysroot=$RV32_TOOLCHAIN/riscv32-unknown-elf --gcc-toolchain=$RV32_TOOLCHAIN ../hello.c -v -c -o hello.o
```

(The LLVM project README follows below)

# The LLVM Compiler Infrastructure

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/llvm/llvm-project/badge)](https://securityscorecards.dev/viewer/?uri=github.com/llvm/llvm-project)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8273/badge)](https://www.bestpractices.dev/projects/8273)
[![libc++](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml/badge.svg?branch=main&event=schedule)](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml?query=event%3Aschedule)

Welcome to the LLVM project!

This repository contains the source code for LLVM, a toolkit for the
construction of highly optimized compilers, optimizers, and run-time
environments.

The LLVM project has multiple components. The core of the project is
itself called "LLVM". This contains all of the tools, libraries, and header
files needed to process intermediate representations and convert them into
object files. Tools include an assembler, disassembler, bitcode analyzer, and
bitcode optimizer.

C-like languages use the [Clang](http://clang.llvm.org/) frontend. This
component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode
-- and from there into object files, using LLVM.

Other components include:
the [libc++ C++ standard library](https://libcxx.llvm.org),
the [LLD linker](https://lld.llvm.org), and more.

## Getting the Source Code and Building LLVM

Consult the
[Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm)
page for information on building and running LLVM.

For information on how to contribute to the LLVM project, please take a look at
the [Contributing to LLVM](https://llvm.org/docs/Contributing.html) guide.

## Getting in touch

Join the [LLVM Discourse forums](https://discourse.llvm.org/), [Discord
chat](https://discord.gg/xS7Z362),
[LLVM Office Hours](https://llvm.org/docs/GettingInvolved.html#office-hours) or
[Regular sync-ups](https://llvm.org/docs/GettingInvolved.html#online-sync-ups).

The LLVM project has adopted a [code of conduct](https://llvm.org/docs/CodeOfConduct.html) for
participants to all modes of communication within the project.
