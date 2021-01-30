! Original code by Chilly Willy

.data

! Draw a vertical column of pixels from a projected wall texture.
! Source is the top of the column to scale.
!
!void I_DrawColumn(int dc_x, int dc_yl, int dc_yh, int light, fixed_t frac,
!                  fixed_t fracstep, inpixel_t *dc_source, int dc_texheight)

        .align  4
        .global _I_DrawColumnPO2A
_I_DrawColumnPO2A:
        add	#1,r6
        cmp/gt  r6,r5
        bf/s    1f
        sub     r5,r6           /* count = dc_yh - dc_yl */

        /* dc_yl >= dc_yh, exit */
        rts
        nop
1:
        mov.l   r8,@-r15
        mov.l   draw_cmap,r0
        mov.l   @r0,r0
        add     r7,r7
        add     r0,r7           /* dc_colormap = colormap + light */
        mov.l   draw_fb,r8
        mov.l   @r8,r8          /* frame buffer start */
        add     r4,r8
        add     r4,r8           /* fb += dc_x*2 */
        shll8   r5
        add     r5,r8
        shlr2   r5
        add     r5,r8           /* fb += (dc_yl*256 + dc_yl*64) */
        mov.l   @(4,r15),r2     /* frac */
        mov.l   @(8,r15),r3     /* fracstep */
        mov.l   @(12,r15),r5    /* dc_source */
        mov.l   @(16,r15),r4
        add     #-1,r4          /* heightmask = texheight - 1 */
        mov.l   draw_width,r1
do_col_loop:
        swap.w  r2,r0
        and     r4,r0           /* (frac >> 16) & heightmask */
        mov.b   @(r0,r5),r0     /* pix = dc_source[(frac >> 16) & heightmask] */
        and     #255,r0
        add     r0,r0
        mov.w   @(r0,r7),r0     /* dpix = dc_colormap[pix] */
        add     r3,r2           /* frac += fracstep */
        mov.w   r0,@r8          /* *fb = dpix */
        dt      r6              /* count-- */
        bf/s    do_col_loop
        add     r1,r8           /* fb += SCREENWIDTH */

        rts
        mov.l   @r15+,r8

! Draw a vertical column of pixels from a projected wall texture.
! Non-power of 2 texture height.
!
!void I_DrawColumnNPO2(int dc_x, int dc_yl, int dc_yh, int light, fixed_t frac,
!                      fixed_t fracstep, inpixel_t *dc_source, int dc_texheight)

        .align  4
        .global _I_DrawColumnNPO2A
_I_DrawColumnNPO2A:
	add	#1,r6
        cmp/gt  r6,r5
        bf/s    1f
        sub     r5,r6           /* count = dc_yh - dc_yl */

        /* dc_yl >= dc_yh, exit */
        rts
        nop
1:
        mov.l   r8,@-r15
        mov.l   draw_cmap,r0
        mov.l   @r0,r0
        add     r7,r7
        add     r0,r7           /* dc_colormap = colormap + light */
        mov.l   draw_fb,r8
        mov.l   @r8,r8          /* frame buffer start */
        add     r4,r8
        add     r4,r8           /* fb += dc_x*2 */
        shll8   r5
        add     r5,r8
        shlr2   r5
        add     r5,r8           /* fb += (dc_yl*256 + dc_yl*64) */
        mov.l   @(4,r15),r2     /* frac */
        mov.l   @(8,r15),r3     /* fracstep */
        mov.l   @(12,r15),r5    /* dc_source */
        mov.l   @(16,r15),r4
        shll16  r4              /* heightmask = texheight << FRACBITS */

        mov     #0,r0
        cmp/ge  r0,r2
        bt      3f
        /* if (frac < 0) */
2:
        add     r4,r2           /* frac += heightmask */
        cmp/ge  r0,r2
        bf      2b
        bt      5f
3:
        cmp/ge  r4,r2
        bf      5f
        /* if (frac >= heightmask) */
4:
        sub     r4,r2           /* frac -= heightmask */
        cmp/ge  r4,r2
        bt      4b
5:
        mov.l   draw_width,r1
do_cnp_loop:
        mov     r2,r0
        shlr16  r0              /* frac >> 16 */
        mov.b   @(r0,r5),r0     /* pix = dc_source[frac >> 16] */
        and     #255,r0
        add     r0,r0
        mov.w   @(r0,r7),r0     /* dpix = dc_colormap[pix] */
        add     r3,r2           /* frac += fracstep */
        mov.w   r0,@r8          /* *fb = dpix */
        cmp/ge  r4,r2
        bf      1f
        /* if (frac >= heightmask) */
        sub     r4,r2           /* frac -= heightmask */
1:
        dt      r6              /* count-- */
        bf/s    do_cnp_loop
        add     r1,r8           /* fb += SCREENWIDTH */

        rts
        mov.l   @r15+,r8

! Draw a horizontal row of pixels from a projected flat (floor/ceiling) texture.
!
!void I_DrawSpan(int ds_y, int ds_x1, int ds_x2, int light, fixed_t ds_xfrac,
!                fixed_t ds_yfrac, fixed_t ds_xstep, fixed_t ds_ystep,
!                inpixel_t *ds_source)

        .align  4
        .global _I_DrawSpanA
_I_DrawSpanA:
        add     #1,r6
        cmp/gt  r6,r5
        bf/s    1f
        sub     r5,r6           /* count = ds_x2 - ds_x1 */

        /* dc_yl >= dc_yh, exit */
        rts
        nop
1:
        mov.l   r8,@-r15
        mov.l   r9,@-r15
        mov.l   draw_cmap,r0
        mov.l   @r0,r0
        add     r7,r7
        add     r0,r7           /* ds_colormap = colormap + light */
        mov.l   draw_fb,r8
        mov.l   @r8,r8          /* frame buffer start */
        add     r5,r8
        add     r5,r8           /* fb += ds_x1*2 */
        shll8   r4
        add     r4,r8
        shlr2   r4
        add     r4,r8           /* fb += (ds_y*256 + ds_y*64) */
        mov.l   @(8,r15),r2     /* xfrac */
        mov.l   @(12,r15),r4    /* yfrac */
        mov.l   @(16,r15),r3    /* xstep */
        mov.l   @(20,r15),r5    /* ystep */
        mov.l   @(24,r15),r9    /* ds_source */

do_span_loop:
        swap.w  r2,r0
        and     #63,r0          /* (xfrac >> 16) & 63 */
        mov     r0,r1
        swap.w  r4,r0
        and     #63,r0          /* (yfrac >> 16) & 63 */
        shll8   r0
        shlr2   r0              /* ((yfrac >> 16) & 63) << 6 */
        or      r1,r0           /* spot = (((yfrac >> 16) & 63) << 6) | ((xfrac >> 16) & 63) */
        mov.b   @(r0,r9),r0     /* pix = ds_source[spot] */
        and     #255,r0
        add     r0,r0
        mov.w   @(r0,r7),r0     /* dpix = ds_colormap[pix] */
        add     r3,r2           /* xfrac += xstep */
        mov.w   r0,@r8          /* *fb = dpix */
        add     r5,r4           /* yfrac += ystep */
        dt      r6              /* count-- */
        bf/s    do_span_loop
        add     #2,r8           /* fb++ */

        mov.l   @r15+,r9
        rts
        mov.l   @r15+,r8

        .align  2
draw_fb:
        .long   _viewportbuffer
draw_cmap:
        .long   _dc_colormaps		/* cached */
/*      .long   colormap|0x20000000   */
draw_width:
        .long   320
