// ============================================================================
//  FolderMini Micro SD Card Holder  –  6 slots, 3 columns × 2 rows
//
//  Holds 6 FolderMini Mac-folder-styled micro SD card holders.
//  Card dimensions (measured from STL): 60 × 9.2 × 47 mm.
//  Cards slide in from the top; the bottom 28 mm is cradled inside the
//  pocket while the top ~19 mm stays exposed so the folder art is visible
//  and the card is easy to pull out.
//
//  Print flat on the base (no supports needed).
// ============================================================================

/* [Card dimensions] */
card_w = 60;    // card width  (X)
card_d = 9.2;   // card depth  (Y, thickness)
card_h = 47;    // card height (Z)

/* [Layout] */
cols = 3;       // columns (left → right)
rows = 2;       // rows    (front → back)

/* [Holder] */
clr      = 0.5;  // clearance per side
wall     = 3.0;  // outer wall thickness
div_x    = 2.0;  // divider width between columns
div_y    = 2.0;  // divider width between rows
floor_t  = 4.0;  // base plate thickness
pocket_h = 28.0; // how far each card is inserted (card protrudes ~19 mm above)
chamfer  = 1.5;  // lead-in chamfer at the top of each pocket

$fn = 48;

// derived slot inner dimensions
sw = card_w + 2*clr;
sd = card_d + 2*clr;

// outer block dimensions
ow = wall + cols*sw + (cols-1)*div_x + wall;
od = wall + rows*sd + (rows-1)*div_y + wall;
oh = floor_t + pocket_h;

module holder() {
    difference() {
        // solid base block
        cube([ow, od, oh]);

        // card pockets + top chamfer
        for (c = [0:cols-1], r = [0:rows-1]) {
            x0 = wall + c*(sw + div_x);
            y0 = wall + r*(sd + div_y);

            // main pocket (breaks through the top face)
            translate([x0, y0, floor_t])
                cube([sw, sd, pocket_h + 1]);

            // 45° lead-in chamfer around the pocket opening
            translate([x0 - chamfer, y0 - chamfer, oh - chamfer])
                cube([sw + 2*chamfer, sd + 2*chamfer, chamfer + 1]);
            // inner chamfer (hull between top face rect and pocket rect)
            translate([x0, y0, oh - chamfer]) {
                hull() {
                    cube([sw, sd, 0.01]);
                    translate([-chamfer, -chamfer, chamfer])
                        cube([sw + 2*chamfer, sd + 2*chamfer, 0.01]);
                }
            }
        }
    }
}

holder();
