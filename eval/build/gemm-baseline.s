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
	addi	sp, sp, -96
	sw	ra, 92(sp)                      # 4-byte Folded Spill
	sw	s0, 88(sp)                      # 4-byte Folded Spill
	sw	s1, 84(sp)                      # 4-byte Folded Spill
	sw	s2, 80(sp)                      # 4-byte Folded Spill
	sw	s3, 76(sp)                      # 4-byte Folded Spill
	sw	s4, 72(sp)                      # 4-byte Folded Spill
	sw	s5, 68(sp)                      # 4-byte Folded Spill
	sw	s6, 64(sp)                      # 4-byte Folded Spill
	sw	s7, 60(sp)                      # 4-byte Folded Spill
	sw	s8, 56(sp)                      # 4-byte Folded Spill
	sw	s9, 52(sp)                      # 4-byte Folded Spill
	sw	s10, 48(sp)                     # 4-byte Folded Spill
	sw	s11, 44(sp)                     # 4-byte Folded Spill
	#APP
	csrr	a4, mhartid
	#NO_APP
	li	a0, -1
	beq	a4, a0, .LBB0_7
# %bb.1:                                # %for.cond1.preheader.lr.ph
	addi	a0, a4, 1
	sw	a0, 4(sp)                       # 4-byte Folded Spill
	lui	a0, %hi(A)
	lw	a0, %lo(A)(a0)
	lui	a1, %hi(B)
	lw	a1, %lo(B)(a1)
	lui	a2, %hi(C)
	lw	a2, %lo(C)(a2)
	sw	a2, 12(sp)                      # 4-byte Folded Spill
	slli	a3, a4, 6
	add	a0, a3, a0
	addi	a0, a0, 128
	sw	a0, 32(sp)                      # 4-byte Folded Spill
	addi	a0, a1, 128
	sw	a0, 0(sp)                       # 4-byte Folded Spill
.LBB0_2:                                # %for.cond1.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
                                        #       Child Loop BB0_4 Depth 3
	li	a1, 0
	sw	a4, 8(sp)                       # 4-byte Folded Spill
	slli	a4, a4, 4
	addi	a0, a4, 16
	sw	a0, 24(sp)                      # 4-byte Folded Spill
	addi	a0, a4, 32
	sw	a0, 20(sp)                      # 4-byte Folded Spill
	sw	a4, 28(sp)                      # 4-byte Folded Spill
	addi	a0, a4, 48
	sw	a0, 16(sp)                      # 4-byte Folded Spill
	lw	t2, 0(sp)                       # 4-byte Folded Reload
.LBB0_3:                                # %for.cond5.preheader
                                        #   Parent Loop BB0_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_4 Depth 3
	li	a2, 0
	li	s11, 0
	li	s9, 0
	li	s8, 0
	li	s6, 0
	li	t3, 0
	li	t4, 0
	li	t6, 0
	li	s0, 0
	li	s1, 0
	li	s2, 0
	li	s3, 0
	li	s4, 0
	li	s5, 0
	li	s7, 0
	li	s10, 0
	sw	a1, 36(sp)                      # 4-byte Folded Spill
	li	a1, 16
	sw	t2, 40(sp)                      # 4-byte Folded Spill
	lw	a3, 32(sp)                      # 4-byte Folded Reload
.LBB0_4:                                # %for.body8
                                        #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	a5, -128(a3)
	lw	a0, -64(a3)
	lw	a7, 0(a3)
	lw	t0, 64(a3)
	lw	t1, -128(t2)
	lw	a6, -64(t2)
	lw	a4, 0(t2)
	lw	t5, 64(t2)
	mul	ra, t1, a5
	add	a2, ra, a2
	mul	ra, a6, a5
	add	s11, ra, s11
	mul	ra, a4, a5
	add	s9, ra, s9
	mul	a5, t5, a5
	add	s8, a5, s8
	mul	a5, t1, a0
	add	s6, a5, s6
	mul	a5, a6, a0
	add	s10, a5, s10
	mul	a5, a4, a0
	add	s7, a5, s7
	mul	a0, t5, a0
	add	s5, a0, s5
	mul	a0, t1, a7
	add	s4, a0, s4
	mul	a0, a6, a7
	add	s3, a0, s3
	mul	a0, a4, a7
	add	s2, a0, s2
	mul	a0, t5, a7
	add	s1, a0, s1
	mul	a0, t1, t0
	add	s0, a0, s0
	mul	a0, a6, t0
	add	t6, a0, t6
	mul	a0, a4, t0
	add	t4, a0, t4
	mul	a0, t5, t0
	add	t3, a0, t3
	addi	a1, a1, -1
	addi	a3, a3, 4
	addi	t2, t2, 4
	bnez	a1, .LBB0_4
# %bb.5:                                # %for.cond.cleanup7
                                        #   in Loop: Header=BB0_3 Depth=2
	lw	a4, 28(sp)                      # 4-byte Folded Reload
	lw	a5, 36(sp)                      # 4-byte Folded Reload
	add	a1, a5, a4
	slli	a1, a1, 2
	lw	a0, 12(sp)                      # 4-byte Folded Reload
	add	a1, a0, a1
	sw	a2, 0(a1)
	ori	a1, a5, 1
	add	a3, a1, a4
	slli	a3, a3, 2
	add	a3, a0, a3
	sw	s11, 0(a3)
	ori	a3, a5, 2
	add	t2, a3, a4
	slli	t2, t2, 2
	add	t2, a0, t2
	sw	s9, 0(t2)
	ori	t2, a5, 3
	add	s9, t2, a4
	slli	s9, s9, 2
	add	s9, a0, s9
	sw	s8, 0(s9)
	lw	a2, 24(sp)                      # 4-byte Folded Reload
	add	s8, a5, a2
	slli	s8, s8, 2
	add	s8, a0, s8
	sw	s6, 0(s8)
	add	s6, a1, a2
	slli	s6, s6, 2
	add	s6, a0, s6
	sw	s10, 0(s6)
	add	s6, a3, a2
	slli	s6, s6, 2
	add	s6, a0, s6
	sw	s7, 0(s6)
	add	s6, t2, a2
	slli	s6, s6, 2
	add	s6, a0, s6
	sw	s5, 0(s6)
	lw	a2, 20(sp)                      # 4-byte Folded Reload
	add	s5, a5, a2
	slli	s5, s5, 2
	add	s5, a0, s5
	sw	s4, 0(s5)
	add	s4, a1, a2
	slli	s4, s4, 2
	add	s4, a0, s4
	sw	s3, 0(s4)
	add	s3, a3, a2
	slli	s3, s3, 2
	add	s3, a0, s3
	sw	s2, 0(s3)
	add	s2, t2, a2
	slli	s2, s2, 2
	add	s2, a0, s2
	sw	s1, 0(s2)
	lw	a2, 16(sp)                      # 4-byte Folded Reload
	add	s1, a5, a2
	slli	s1, s1, 2
	add	s1, a0, s1
	sw	s0, 0(s1)
	add	a1, a1, a2
	slli	a1, a1, 2
	add	a1, a0, a1
	sw	t6, 0(a1)
	add	a3, a3, a2
	slli	a3, a3, 2
	add	a3, a0, a3
	sw	t4, 0(a3)
	add	t2, t2, a2
	slli	t2, t2, 2
	add	t2, a0, t2
	sw	t3, 0(t2)
	addi	a1, a5, 4
	lw	t2, 40(sp)                      # 4-byte Folded Reload
	addi	t2, t2, 256
	li	a0, 12
	bltu	a5, a0, .LBB0_3
# %bb.6:                                # %for.cond.cleanup3
                                        #   in Loop: Header=BB0_2 Depth=1
	lw	a4, 8(sp)                       # 4-byte Folded Reload
	addi	a4, a4, 4
	lw	a0, 32(sp)                      # 4-byte Folded Reload
	addi	a0, a0, 256
	sw	a0, 32(sp)                      # 4-byte Folded Spill
	lw	a0, 4(sp)                       # 4-byte Folded Reload
	bltu	a4, a0, .LBB0_2
.LBB0_7:                                # %for.cond.cleanup
	lw	ra, 92(sp)                      # 4-byte Folded Reload
	lw	s0, 88(sp)                      # 4-byte Folded Reload
	lw	s1, 84(sp)                      # 4-byte Folded Reload
	lw	s2, 80(sp)                      # 4-byte Folded Reload
	lw	s3, 76(sp)                      # 4-byte Folded Reload
	lw	s4, 72(sp)                      # 4-byte Folded Reload
	lw	s5, 68(sp)                      # 4-byte Folded Reload
	lw	s6, 64(sp)                      # 4-byte Folded Reload
	lw	s7, 60(sp)                      # 4-byte Folded Reload
	lw	s8, 56(sp)                      # 4-byte Folded Reload
	lw	s9, 52(sp)                      # 4-byte Folded Reload
	lw	s10, 48(sp)                     # 4-byte Folded Reload
	lw	s11, 44(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 96
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
	lui	a0, %hi(gemm)
	addi	a0, a0, %lo(gemm)
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

	.ident	"clang version 16.0.6 (git@github.com:richardyrh/llvm.git 58811bfa61a503fd4a5f0dc7b57802fae51c3f5d)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym gemm
