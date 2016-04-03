#include "ghcconfig.h"
#include "rts/Constants.h"

#if defined(powerpc64le_HOST_ARCH)
# ifdef linux_HOST_OS
# define STACK_FRAME_SIZE (RESERVED_C_STACK_BYTES+288+15) & ~15
	.file	"StgCRun.c"
	.abiversion 2
	.section	".toc","aw"
	.section	".text"
	.align 2
        .globl StgRun
        .hidden StgRun
        .type StgRun,@function
StgRun:
        .localentry StgRun,.-StgRun
	mflr 0
        addi 12,1,-(8*18)
        bl _savegpr1_14
        bl _savefpr_14
	stdu 1, -(STACK_FRAME_SIZE)(1)
	mr 27, 4
	mtctr 3
	mr 12, 3
	bctr

        .globl StgReturn
        .type StgReturn,@function
StgReturn:
        addis 2,12,.TOC.-StgReturn@ha
        addi 2,2,.TOC.-StgReturn@l
        .localentry StgReturn,.-StgReturn
	mr 3,14
	la 1, STACK_FRAME_SIZE(1)
        addi 12,1,-(8*18)
        bl _restgpr1_14
        b _restfpr_14

	.section	.note.GNU-stack,"",@progbits
# else // linux_HOST_OS
# error Only Linux support for power64 little endian right now.
# endif

#elif defined(powerpc_HOST_ARCH)
# if defined(aix_HOST_OS)
# define STACK_FRAME_SIZE RESERVED_C_STACK_BYTES+224
	.toc
	.csect StgRun[DS]
	.globl StgRun[DS]
	.long .StgRun, TOC[TC0], 0
	.csect .text[PR]
	.globl .StgRun
.StgRun:
	mflr  0
	mr    5,1
	stw   0,8(1)
	stwu  1,-(STACK_FRAME_SIZE)(1)
	stw   2,-224(5)
	stmw 13,-220(5)
	stfd 14,-144(5)
	stfd 15,-136(5)
	stfd 16,-128(5)
	stfd 17,-120(5)
	stfd 18,-112(5)
	stfd 19,-104(5)
	stfd 20,-96(5)
	stfd 21,-88(5)
	stfd 22,-80(5)
	stfd 23,-72(5)
	stfd 24,-64(5)
	stfd 25,-56(5)
	stfd 26,-48(5)
	stfd 27,-40(5)
	stfd 28,-32(5)
	stfd 29,-24(5)
	stfd 30,-16(5)
	stfd 31,-8(5)
	mr   27,4
	mtctr 3
	bctr

	.globl StgReturn
StgReturn:
	mr   3,14
	la   5,(STACK_FRAME_SIZE)(1)
	lwz  2,-224(5)
	lmw 13,-220(5)
	lfd 14,-144(5)
	lfd 15,-136(5)
	lfd 16,-128(5)
	lfd 17,-120(5)
	lfd 18,-112(5)
	lfd 19,-104(5)
	lfd 20,-96(5)
	lfd 21,-88(5)
	lfd 22,-80(5)
	lfd 23,-72(5)
	lfd 24,-64(5)
	lfd 25,-56(5)
	lfd 26,-48(5)
	lfd 27,-40(5)
	lfd 28,-32(5)
	lfd 29,-24(5)
	lfd 30,-16(5)
	lfd 31,-8(5)
	mr   1,5
	lwz  0,8(1)
	mtlr 0
	blr

# endif // aix_HOST_OS
#endif
