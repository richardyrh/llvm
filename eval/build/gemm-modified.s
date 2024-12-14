	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0"
	.file	"gemm.c"
	.section	.text.gemm,"ax",@progbits
	.globl	gemm                            # -- Begin function gemm
	.p2align	2
	.type	gemm,@function
gemm:                                   # @gemm
# %bb.0:                                # %entry
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	#APP
	csrr	a0, mhartid
	#NO_APP
	li	a1, -1
	beq	a0, a1, .LBB0_7
# %bb.1:                                # %for.cond1.preheader.lr.ph
	addi	a1, a0, 1
	lw	a3, %lo(A)(zero)
	lw	a5, %lo(B)(zero)
	lw	a2, %lo(C)(zero)
	slli	a6, a0, 6
	add	a4, a6, a3
	addi	a3, a4, 128
	addi	a4, a5, 128
	li	a5, 12
.LBB0_2:                                # %for.cond1.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
                                        #       Child Loop BB0_4 Depth 3
	li	t3, 0
	slli	a6, a0, 4
	addi	a7, a6, 16
	addi	a9, a6, 32
	addi	a10, a6, 48
	mv	a8, a4
.LBB0_3:                                # %for.cond5.preheader
                                        #   Parent Loop BB0_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_4 Depth 3
	li	t2, 0
	li	t1, 0
	li	a23, 0
	li	a22, 0
	li	a20, 0
	li	a11, 0
	li	a12, 0
	li	a13, 0
	li	a14, 0
	li	a15, 0
	li	a16, 0
	li	a17, 0
	li	a18, 0
	li	a19, 0
	li	a21, 0
	li	t0, 0
	mv	ra, t3
	li	t3, 16
	mv	t4, a8
	mv	t5, a3
.LBB0_4:                                # %for.body8
                                        #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	t6, -128(t5)
	lw	t7, -64(t5)
	lw	t8, 0(t5)
	lw	t10, 64(t5)
	lw	t9, -128(t4)
	lw	t13, -64(t4)
	lw	t17, 0(t4)
	lw	t21, 64(t4)
	mul	t11, t9, t6
	add	t2, t11, t2
	mul	t11, t13, t6
	add	t1, t11, t1
	mul	t11, t17, t6
	add	a23, t11, a23
	mul	t11, t21, t6
	add	a22, t11, a22
	mul	t6, t9, t7
	add	a20, t6, a20
	mul	t6, t13, t7
	add	t0, t6, t0
	mul	t6, t17, t7
	add	a21, t6, a21
	mul	t12, t21, t7
	add	a19, t12, a19
	mul	t6, t9, t8
	add	a18, t6, a18
	mul	t6, t13, t8
	add	a17, t6, a17
	mul	t6, t17, t8
	add	a16, t6, a16
	mul	t7, t21, t8
	add	a15, t7, a15
	mul	t7, t9, t10
	add	a14, t7, a14
	mul	t7, t13, t10
	add	a13, t7, a13
	mul	t8, t17, t10
	add	a12, t8, a12
	mul	t7, t21, t10
	add	a11, t7, a11
	addi	t3, t3, -1
	addi	t5, t5, 4
	addi	t4, t4, 4
	bnez	t3, .LBB0_4
# %bb.5:                                # %for.cond.cleanup7
                                        #   in Loop: Header=BB0_3 Depth=2
	add	t5, ra, a6
	slli	t4, t5, 2
	add	t5, a2, t4
	sw	t2, 0(t5)
	ori	t2, ra, 1
	add	t4, t2, a6
	slli	t5, t4, 2
	add	t4, a2, t5
	sw	t1, 0(t4)
	ori	t6, ra, 2
	add	t1, t6, a6
	slli	t4, t1, 2
	add	t1, a2, t4
	sw	a23, 0(t1)
	ori	a23, ra, 3
	add	t1, a23, a6
	slli	t4, t1, 2
	add	t10, a2, t4
	sw	a22, 0(t10)
	add	a22, ra, a7
	slli	t4, a22, 2
	add	a22, a2, t4
	sw	a20, 0(a22)
	add	a20, t2, a7
	slli	a22, a20, 2
	add	t10, a2, a22
	sw	t0, 0(t10)
	add	a20, t6, a7
	slli	a22, a20, 2
	add	t10, a2, a22
	sw	a21, 0(t10)
	add	a20, a23, a7
	slli	a21, a20, 2
	add	a22, a2, a21
	sw	a19, 0(a22)
	add	a19, ra, a9
	slli	a21, a19, 2
	add	a19, a2, a21
	sw	a18, 0(a19)
	add	a18, t2, a9
	slli	a19, a18, 2
	add	a18, a2, a19
	sw	a17, 0(a18)
	add	a18, t6, a9
	slli	a17, a18, 2
	add	a18, a2, a17
	sw	a16, 0(a18)
	add	a16, a23, a9
	slli	a17, a16, 2
	add	a18, a2, a17
	sw	a15, 0(a18)
	add	a15, ra, a10
	slli	a17, a15, 2
	add	a15, a2, a17
	sw	a14, 0(a15)
	add	a16, t2, a10
	slli	a14, a16, 2
	add	a15, a2, a14
	sw	a13, 0(a15)
	add	a13, t6, a10
	slli	a14, a13, 2
	add	a13, a2, a14
	sw	a12, 0(a13)
	add	a12, a23, a10
	slli	a13, a12, 2
	add	a14, a2, a13
	sw	a11, 0(a14)
	addi	t3, ra, 4
	addi	a8, a8, 256
	bltu	ra, a5, .LBB0_3
# %bb.6:                                # %for.cond.cleanup3
                                        #   in Loop: Header=BB0_2 Depth=1
	addi	a0, a0, 4
	addi	a3, a3, 256
	bltu	a0, a1, .LBB0_2
.LBB0_7:                                # %for.cond.cleanup
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	gemm, .Lfunc_end0-gemm
                                        # -- End function
	.section	.text.startup,"ax",@progbits
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:                                # %entry
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	addi	a0, zero, %lo(gemm)
	li	a1, 4
	#APP
	.insn r 11, 1, 0, zero, a1, a0
	#NO_APP
	call	gemm
	li	a0, 0
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.type	A,@object                       # @A
	.section	.sdata,"aw",@progbits
	.globl	A
	.p2align	2
A:
	.word	2684354560
	.size	A, 4

	.type	B,@object                       # @B
	.globl	B
	.p2align	2
B:
	.word	2701131776
	.size	B, 4

	.type	C,@object                       # @C
	.globl	C
	.p2align	2
C:
	.word	3221225472
	.size	C, 4

	.ident	"clang version 16.0.6 (git@github.com:richardyrh/llvm.git d1f5d3d89a3dc92ac1bd7f9418c45858b07c1a52)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym gemm
