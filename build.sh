
SYSROOT="$(realpath $RISCV/riscv32-unknown-elf)"
# FLAGS="--target=riscv32-unknown-elf -march=rv32imafd -mabi=ilp32 --gcc-toolchain=$(realpath $RISCV)/riscv32-unknown-elf --sysroot=$SYSROOT"
# FLAGS="--target=riscv32-unknown-elf -march=rv32imafd -mabi=ilp32 --gcc-toolchain=$(realpath $RISCV_TOOLCHAIN_PATH) --sysroot=$SYSROOT"
TEST_FLAGS="$FLAGS"

LLVM_BUILD="$1"

cmake -G "Ninja" ../llvm \
-DLLVM_ENABLE_PROJECTS="clang;lld" \
-DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DBUILD_SHARED_LIBS=True \
-DLLVM_BUILD_TESTS=False \
-DLLVM_OPTIMIZED_TABLEGEN=ON \
\ # -DDEFAULT_SYSROOT=$RISCV_TOOLCHAIN_PATH/riscv32-unknown-elf \
\ # -DGCC_INSTALL_PREFIX="$RISCV_TOOLCHAIN_PATH" \
-DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
-DLLVM_TARGETS_TO_BUILD="RISCV" \
-DLIBCXX_INCLUDE_TESTS=False \
-DLIBCXX_INCLUDE_BENCHMARKS=False \
-DCMAKE_BUILD_TYPE=Release \
-DLLVM_ENABLE_ASSERTIONS=ON \
-DCMAKE_INSTALL_PREFIX="$2" \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
-DCLANG_DEFAULT_LINKER=lld \
-DCLANG_DEFAULT_RTLIB=compiler-rt \
-DCMAKE_C_COMPILER=$LLVM_BUILD/clang \
-DCMAKE_CXX_COMPILER=$LLVM_BUILD/clang++ \
-DLLVM_ENABLE_LLD=ON \
-DCMAKE_AR=$LLVM_BUILD/llvm-ar \
-DCMAKE_NM=$LLVM_BUILD/llvm-nm \
-DCMAKE_RANLIB=$LLVM_BUILD/llvm-ranlib \
# -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi" \
# -DLLVM_BUILD_RUNTIME=ON \
# -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
# -DLLVM_ENABLE_SPHINX=ON \
# -DLIBC_INCLUDE_DOCS=ON \
# -DCOMPILER_RT_BUILD_SCUDO_STANDALONE_WITH_LLVM_LIBC=ON \
# -DCOMPILER_RT_BUILD_GWP_ASAN=OFF                       \
# -DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF        \

