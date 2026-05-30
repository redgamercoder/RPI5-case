// ============================================================================
//  Raspberry Pi 5 "Monolith" Wedge Case
//  Modelled from a hand-drawn concept sketch.
//
//  Concept / key details from the sketch:
//    * Long wedge / ramp shape - tall at the front, sloping down to a thin back
//    * 30 cm long, 17 cm wide
//    * Front face exposes "all the side ports" of the RPi 5
//    * A cooling fan vent on one side
//    * The sloping "roof" is a SEPARATE part that slides into a slot
//    * The roof carries an embossed Raspberry Pi logo
//    * Underneath: power button + micro-SD card access
//    * Body is printed in two (mirrored) halves
//
//  Render targets (set with -D part="..."):
//    "assembled"   - body + roof in place (visualisation)
//    "body"        - full body (both halves joined)
//    "roof"        - just the sliding roof, laid flat for printing
//    "body_left"   - left half of the body (for printing)
//    "body_right"  - right half of the body (for printing)
//    "exploded"    - assembled view with the roof lifted out of its slot
// ============================================================================

part = "assembled";

/* [Overall dimensions] */
L        = 300;   // length, front -> back  (30 cm)
W        = 170;   // width                  (17 cm)
front_h  = 120;   // height of the tall front face
back_h   = 35;    // height of the thin back edge

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

/* [Front ports opening] */
port_w   = 62;    // width of the port window
port_h   = 26;    // height of the port window
port_z   = 9;     // height of the bottom of the port window above the floor

/* [Side fan vent] */
fan_d        = 80;   // outer diameter of the fan grille
fan_spokes   = 6;    // number of grille spokes
fan_screw    = 71.5; // fan mounting-hole spacing (80 mm fan)

/* [Underside access] */
pwr_d    = 12;    // power button hole diameter
sd_w     = 16;    // micro-SD slot width
sd_l     = 4;     // micro-SD slot length

/* [Raspberry Pi board + mounts] */
pi_w     = 56;    // board width  (along Y)
pi_l     = 85;    // board length (along X, front->back)
pi_hx    = 58;    // mount hole spacing along X
pi_hy    = 49;    // mount hole spacing along Y
pi_front = 10;    // gap from front inner wall to the board edge
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
//  Helper: work in the frame of the sloping top surface.
//  Local +x runs down-slope (front -> back), +y is width, z=0 is the surface,
//  z<0 is into the body.
// ----------------------------------------------------------------------------
module on_slope() {
    translate([0, 0, front_h])
        rotate([0, slope_ang, 0])
            children();
}

// ----------------------------------------------------------------------------
//  Outer solid wedge: vertical sides + front/back, single sloping top.
// ----------------------------------------------------------------------------
module outer_wedge() {
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
//  Front port window ("all the side ports").
// ----------------------------------------------------------------------------
module front_ports() {
    translate([-eps, (W - port_w)/2, floor_t + port_z])
        cube([wall + 2*eps, port_w, port_h]);
}

// ----------------------------------------------------------------------------
//  Side fan vent (circular grille on the y=0 wall).
// ----------------------------------------------------------------------------
module fan_vent() {
    cz = (front_h*0.55 + back_h)/2 + 18;   // roughly centred on the tall area
    cx = L*0.32;
    translate([cx, -eps, cz])
        rotate([-90, 0, 0]) {
            // open grille: outer ring minus spokes
            difference() {
                cylinder(h = wall + 2*eps, d = fan_d);
                // keep a hub + spokes by removing pie wedges
                for (i = [0 : fan_spokes-1])
                    rotate([0, 0, i*360/fan_spokes + 360/fan_spokes/2])
                        translate([0, 0, -eps])
                            pie(fan_d/2 - 5, 360/fan_spokes - 7, wall + 4*eps);
                // hub hole removed too (leave central hub solid -> re-add below)
            }
            // central hub
            cylinder(h = wall + 2*eps, d = 14);
            // fan screw holes (purely cosmetic mounting bosses pattern)
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*fan_screw/2, sy*fan_screw/2, -eps])
                    cylinder(h = wall + 4*eps, d = 4.5);
        }
}

// a flat pie slice of given radius / angle / height, centred on origin
module pie(r, ang, h) {
    linear_extrude(h)
        polygon(concat([[0, 0]],
            [ for (a = [-ang/2 : ang/ ($fn) : ang/2]) [r*cos(a), r*sin(a)] ]));
}

// ----------------------------------------------------------------------------
//  Under-side access: power button + micro-SD slot.
// ----------------------------------------------------------------------------
module bottom_holes() {
    // power button, near the front under the board edge
    translate([pi_x0 + 14, W/2 - 22, -eps])
        cylinder(h = floor_t + 2*eps, d = pwr_d);
    // micro-SD slot
    translate([pi_x0 + 6, W/2 + 14, -eps])
        cube([sd_l, sd_w, floor_t + 2*eps]);
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
//  Alignment dowel holes across the centre seam (for the two-half print).
//  Holes run along Y through the y=W/2 plane.
// ----------------------------------------------------------------------------
module dowel_holes() {
    pts = [[wall + 14, 16], [L*0.5, 14], [L - wall - 20, back_h*0.5]];
    for (p = pts)
        translate([p[0], W/2, p[1]])
            rotate([-90, 0, 0])
                translate([0, 0, -12])
                    cylinder(h = 24, d = 4.2);
}

// ----------------------------------------------------------------------------
//  Body = shell - cavity - all the cut-outs, + standoffs.
// ----------------------------------------------------------------------------
module body() {
    difference() {
        union() {
            difference() {
                outer_wedge();
                inner_cavity();
                front_ports();
                fan_vent();
                bottom_holes();
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
//  Part selection
// ----------------------------------------------------------------------------
module half(side) {
    // side = +1 keep y < W/2 ; side = -1 keep y > W/2
    intersection() {
        body();
        if (side > 0) translate([-50, -50, -50]) cube([L+100, 50 + W/2, front_h+100]);
        else          translate([-50, W/2, -50]) cube([L+100, 50 + W/2, front_h+100]);
    }
}

if      (part == "assembled") { color("#7f8c8d") body(); roof_in_place(); }
else if (part == "body")       body();
else if (part == "roof")       translate([0, 0, lip_t + roof_t]) roof_panel();  // flat, ready to print
else if (part == "body_left")  half(+1);
else if (part == "body_right") half(-1);
else if (part == "exploded")  { color("#7f8c8d") body();
                                on_slope() translate([0,0,55]) color("#c41e3a") roof_panel(); }
else                           { color("#7f8c8d") body(); roof_in_place(); }
