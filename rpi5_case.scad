// ============================================================================
//  Raspberry Pi 5 Box Case
//  Modelled from a hand-drawn concept sketch.
//
//  Concept / key details:
//    * Rectangular box - 30 cm long, 17 cm wide, 12 cm tall (flat top)
//    * Front face exposes the RPi 5 USB / Ethernet port holes (the only openings)
//    * The flat top "roof" is a SEPARATE part that slides into a slot
//    * The roof carries an embossed Raspberry Pi logo
//    * Body is two hollow boxes, cut across the middle (15 cm + 15 cm),
//      sharing one interior (open at the cut)
//
//  Render targets (set with -D part="..."):
//    "assembled"   - body + roof in place (visualisation)
//    "body"        - full body (both halves joined)
//    "roof"        - just the sliding roof, laid flat for printing
//    "body_front"  - front half of the body, 0..150 mm  (for printing)
//    "body_back"   - back half of the body, 150..300 mm  (for printing)
//    "exploded"    - assembled view with the roof lifted out of its slot
// ============================================================================

part = "assembled";

/* [Overall dimensions] */
L  = 300;   // length, front -> back  (30 cm)
W  = 170;   // width                  (17 cm)
H  = 120;   // height                 (12 cm)
// The whole case is a rectangular box: the front and back are the same height,
// so the top is flat.  (Give back_h a smaller value if you ever want a wedge.)
front_h = H;
back_h  = H;

/* [Shell] */
wall     = 4;     // side / front / back wall thickness
floor_t  = 4;     // floor thickness
roof_t   = 4;     // sliding roof panel thickness

/* [Sliding roof joint] */
// The roof slides into a C-channel rail along each side: a lip captures it
// from above, a ledge supports it from below.
rail_w  = 9;      // how far each rail juts inward from the side wall
rail_h  = 14;     // rail height (down from the top surface)
lip_t   = 3;      // thickness of the capturing lip above the roof
slot_d  = 5;      // how far the roof edge engages into the rail
clr     = 0.4;    // print clearance for the sliding fit

/* [Raspberry Pi port holes - front face] */
// The only openings in the case: the Pi 5 USB / Ethernet I/O bank.
eth_w    = 16;    // Ethernet (RJ45) opening width
eth_h    = 15;    // Ethernet opening height
usb_w    = 15;    // USB double-stack opening width
usb_h    = 17;    // USB double-stack opening height
port_clr = 1;     // extra clearance around each opening

/* [Raspberry Pi board + mounts] */
pi_w     = 56;    // board width  (along Y)
pi_l     = 85;    // board length (along X, front->back)
pi_hx    = 58;    // mount hole spacing along X
pi_hy    = 49;    // mount hole spacing along Y
pi_front = 2;     // gap from front inner wall to the board edge (ports reach the wall)
standoff_h = 6;   // standoff height
standoff_d = 6;   // standoff diameter

/* [Quality] */
$fn = 56;

// ----------------------------------------------------------------------------
//  Derived geometry
// ----------------------------------------------------------------------------
eps       = 0.01;
slope_dz  = front_h - back_h;
slope_ang = atan2(slope_dz, L);          // tilt of the top surface
slope_len = sqrt(L*L + slope_dz*slope_dz); // length along the slope

// back wall is lowered to leave the slot the roof slides in/out through
back_wall_h = back_h - (lip_t + roof_t) - 2;

// Pi board placement (centred in width, near the front)
pi_x0 = wall + pi_front;
pi_y0 = (W - pi_w) / 2;

// ----------------------------------------------------------------------------
//  Helper: work in the frame of the top surface.  +x runs front -> back,
//  +y is width, z=0 is the top surface, z<0 is into the body.  (With a flat
//  top, slope_ang = 0, so this is just a lift to the top.)
// ----------------------------------------------------------------------------
module on_slope() {
    translate([0, 0, front_h])
        rotate([0, slope_ang, 0])
            children();
}

// ----------------------------------------------------------------------------
//  Outer solid shell: a rectangular box (vertical sides, flat top).
// ----------------------------------------------------------------------------
module outer_box() {
    translate([0, W, 0])
        rotate([90, 0, 0])
            linear_extrude(W)
                polygon([[0, 0], [L, 0], [L, back_h], [0, front_h]]);
}

// Same shape, shrunk to form the interior cavity (open through the top).
module inner_cavity() {
    h = W - 2*wall;
    translate([wall, W - wall, floor_t])
        rotate([90, 0, 0])
            linear_extrude(h)
                polygon([[0, 0],
                         [L - 2*wall, 0],
                         [L - 2*wall, back_h + 50],   // run out through the top
                         [0,          front_h + 50]]);
}

// roof Z-levels in the slope frame (roof sits recessed lip_t below the top)
roof_top_z = -lip_t;
roof_bot_z = -lip_t - roof_t;

// ----------------------------------------------------------------------------
//  C-channel rail added to the inner top edge of one side wall.
//  side = +1 -> left (y near 0),  side = -1 -> right (y near W)
// ----------------------------------------------------------------------------
module rail(side) {
    y = (side > 0) ? wall : W - wall - rail_w;
    on_slope()
        translate([wall, y, -rail_h])
            cube([slope_len - wall, rail_w, rail_h]);
}

// the slot carved into a rail that the roof edge slides along (open at back)
module rail_slot(side) {
    y = (side > 0) ? wall + rail_w - slot_d : W - wall - rail_w - eps;
    on_slope()
        translate([wall - eps, y, roof_bot_z - clr])
            cube([slope_len + 50, slot_d + eps, roof_t + 2*clr]);
}

// ----------------------------------------------------------------------------
//  The sliding roof panel (modelled flat in the slope frame).
// ----------------------------------------------------------------------------
module roof_panel() {
    rx0 = wall + clr;                            // butts against the front wall
    rx1 = slope_len - clr;                       // open back end
    ry0 = wall + rail_w - slot_d + clr;          // tongue into left slot
    ry1 = W - wall - rail_w + slot_d - clr;      // tongue into right slot
    difference() {
        translate([rx0, ry0, roof_bot_z])
            cube([rx1 - rx0, ry1 - ry0, roof_t]);
        // finger-pull notch on the back edge so it is easy to grab
        translate([rx1 - 14, W/2 - 13, roof_bot_z - eps])
            cube([20, 26, roof_t + 2*eps]);
    }
    // embossed Raspberry Pi logo, raised from the top surface.
    // rotate(90) so the leaves point up-slope (toward the tall front).
    translate([slope_len*0.54, W/2, roof_top_z])
        rotate([0, 0, 90])
            raspberry_logo(logo_h = 92, emboss = 4);
}

// ----------------------------------------------------------------------------
//  Stylised Raspberry Pi logo: a cluster of distinct berries + two leaves,
//  extruded upward by `emboss`. `logo_h` is the overall height in mm.
//  Drawn with +Y pointing toward the leaves (the "up" of the logo).
// ----------------------------------------------------------------------------
module raspberry_logo(logo_h = 80, emboss = 4) {
    s = logo_h / 7.75;             // unit-height of raspberry_2d() is ~7.75
    linear_extrude(height = emboss)
        scale([s, s])
            raspberry_2d();
}

// a single broad pointed leaf, tip pointing +Y, centred on origin
module leaf2d() {
    intersection() {
        translate([-0.7, 0]) scale([1, 1.35]) circle(1.5);
        translate([ 0.7, 0]) scale([1, 1.35]) circle(1.5);
    }
}

module raspberry_2d() {
    br = 0.95;                      // berry radius (gaps keep them distinct)
    // berry body: hex-packed diamond cluster
    berries = [ [0, 0],
                [-1.1, 1.0], [1.1, 1.0],
                [-2.2, 2.0], [0, 2.0], [2.2, 2.0],
                [-1.1, 3.0], [1.1, 3.0],
                [0, 4.0] ];
    for (p = berries)
        translate([p[0], p[1]]) circle(br);
    // two pointed leaves splayed in a V above the cluster
    for (m = [-1, 1])
        scale([m, 1])
            translate([0.9, 4.6])
                rotate(30)
                    scale(1.15)
                        leaf2d();
}

// ----------------------------------------------------------------------------
//  Raspberry Pi 5 port holes on the front face: Ethernet + two USB stacks,
//  positioned to line up with the board's I/O edge.
// ----------------------------------------------------------------------------
module port_cut(yc, w, h) {
    bz = floor_t + standoff_h;                  // board top surface height
    translate([-1, yc - (w + port_clr)/2, bz - 1])
        cube([wall + 2, w + port_clr, h + port_clr]);
}

module pi_ports() {
    port_cut(pi_y0 +  9, eth_w, eth_h);         // Ethernet (RJ45)
    port_cut(pi_y0 + 27, usb_w, usb_h);         // USB 3.0 double-stack
    port_cut(pi_y0 + 45, usb_w, usb_h);         // USB 2.0 double-stack
}

// ----------------------------------------------------------------------------
//  Pi mounting standoffs (added back as solid posts inside the cavity).
// ----------------------------------------------------------------------------
module standoffs() {
    for (dx = [3.5, 3.5 + pi_hx], dy = [(pi_w - pi_hy)/2, (pi_w + pi_hy)/2])
        translate([pi_x0 + dx, pi_y0 + dy, floor_t - eps])
            difference() {
                cylinder(h = standoff_h, d = standoff_d);
                translate([0, 0, 1])
                    cylinder(h = standoff_h, d = 2.2);  // M2.5 pilot
            }
}

// ----------------------------------------------------------------------------
//  Alignment dowel holes across the mid-length seam (for the two-half print).
//  Holes run along X through the x=L/2 plane, inside the two side walls.
// ----------------------------------------------------------------------------
module dowel_holes() {
    for (y = [wall/2, W - wall/2], z = [22, 55])
        translate([L/2, y, z])
            rotate([0, 90, 0])
                translate([0, 0, -12])
                    cylinder(h = 24, d = 3);
}

// ----------------------------------------------------------------------------
//  Body = shell - cavity - all the cut-outs, + standoffs.
// ----------------------------------------------------------------------------
module body() {
    difference() {
        union() {
            difference() {
                outer_box();
                inner_cavity();
                pi_ports();
                dowel_holes();
                // lower the back wall to open the roof slot
                translate([L - wall - eps, -1, back_wall_h])
                    cube([wall + 2, W + 2, back_h]);
            }
            rail(+1);
            rail(-1);
            standoffs();
        }
        // carve the roof slots into the rails (after they are added)
        rail_slot(+1);
        rail_slot(-1);
    }
}

// roof positioned in place on the slope
module roof_in_place() {
    color("#c41e3a") on_slope() roof_panel();
}

// ----------------------------------------------------------------------------
//  Part selection.  The body is cut across the middle into two 150 mm halves.
// ----------------------------------------------------------------------------
module half(front) {
    // front = true  -> keep x < L/2 ; front = false -> keep x > L/2
    intersection() {
        body();
        if (front) translate([-50, -50, -50]) cube([L/2 + 50, W + 100, front_h + 100]);
        else       translate([L/2, -50, -50]) cube([L/2 + 50, W + 100, front_h + 100]);
    }
}

if      (part == "assembled") { color("#7f8c8d") body(); roof_in_place(); }
else if (part == "body")       body();
else if (part == "roof")       translate([0, 0, lip_t + roof_t]) roof_panel();  // flat, ready to print
else if (part == "body_front") half(true);
else if (part == "body_back")  half(false);
else if (part == "exploded")  { color("#7f8c8d") body();
                                on_slope() translate([0,0,55]) color("#c41e3a") roof_panel(); }
else                           { color("#7f8c8d") body(); roof_in_place(); }
