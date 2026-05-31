// ============================================================================
//  INIU B1-B6 power bank - partial cover / sleeve
//
//  Slides onto the lower "A" region of the power bank and covers it: both
//  large faces, the two long side edges, and the closed bottom end.  The top
//  is open so the black display + ports section stays exposed.
//
//  NOTE: the power bank size below is from published specs (136 x 70 x 15 mm).
//  Measure YOUR unit with calipers and adjust pb_w / pb_t / pb_r / cover_h for
//  a good fit before printing.
//
//  Render targets (set with -D part="..."):
//    "cover" - the printable sleeve
//    "demo"  - sleeve + a ghost of the power bank (visualisation)
// ============================================================================

part = "cover";

/* [Power bank] */
pb_l = 136;   // total length
pb_w = 70;    // width
pb_t = 15;    // thickness
pb_r = 7;     // cross-section corner radius (rounded long edges)

/* [Cover] */
cover_h = 92;   // how far up the bank the sleeve reaches (the white "A" region)
wall    = 2.0;  // side-wall thickness
floor_t = 2.0;  // closed bottom-end thickness
clr     = 0.5;  // fit clearance (per side)

$fn = 96;

// centred rounded rectangle: w x t, corner radius r
module rrect(w, t, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(w/2 - r), sy*(t/2 - r)]) circle(r);
}

// the power bank as a rounded slab of the given length (bottom at z=0)
module powerbank(len) {
    linear_extrude(len) rrect(pb_w, pb_t, pb_r);
}

// the sleeve: a rounded pocket, closed at the bottom, open at the top
module cover() {
    iw = pb_w + 2*clr;   it = pb_t + 2*clr;   ir = pb_r + clr;    // inner cavity
    ow = iw + 2*wall;    ot = it + 2*wall;    or = ir + wall;     // outer shell
    difference() {
        linear_extrude(cover_h + floor_t) rrect(ow, ot, or);
        translate([0, 0, floor_t])
            linear_extrude(cover_h + 1) rrect(iw, it, ir);
    }
}

if (part == "cover")
    cover();
else {                                  // demo / visualisation
    cover();
    color([0.25, 0.25, 0.25, 0.35])
        translate([0, 0, floor_t + clr]) powerbank(pb_l);
}
