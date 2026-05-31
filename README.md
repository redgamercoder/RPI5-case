# RPI5-case

A parametric, 3D-printable **Raspberry Pi 5 box case**, modelled in
[OpenSCAD](https://openscad.org/) from a hand-drawn concept sketch.

![assembled case](renders/hero.png)

## The concept

The case is a plain rectangular box with a flat sliding-lid top:

| Detail | In the model |
|---|---|
| 30 cm long, 17 cm wide, 12 cm tall | `L = 300`, `W = 170`, `H = 120` |
| Rectangular box, flat top | `front_h = back_h = H` |
| Pi port holes on the front | Ethernet + two USB stacks + one wide (two-USB) hole, the only openings |
| Plain flat roof | no logo |
| Two hollow boxes (15 cm + 15 cm) | `body_front` + `body_back`, cut across the middle, sharing one interior (open at the cut) |
| Separate roof that slides into a slot | flat roof rides in a C-channel; the back is open as the slot |

## Files

```
rpi5_case.scad              parametric source (single file, edit this)
stl/
  rpi5_case_assembled.stl   whole case, roof in place (visualisation)
  rpi5_case_body.stl        the body as one piece
  rpi5_case_body_front.stl  front half, 0..150 mm   (print this)
  rpi5_case_body_back.stl   back half, 150..300 mm  (print this)
  rpi5_case_roof.stl        the sliding roof, laid flat (print this)
renders/                    reference images
```

The three parts you print are **`body_front`**, **`body_back`** and
**`roof`**. All STL parts are watertight, valid 2-manifolds.

## How the roof slot works

Each side wall carries an inner **C-channel rail**: a lip captures the roof
from above and a ledge supports it from below. The roof is a flat panel whose
two long edges slide along these channels. The back wall is lowered, leaving an
open **slot** — you slide the roof in from the back until it stops against the
front wall, and slide it back out to open the case. A finger-pull notch on
the roof's back edge makes it easy to grab.

```
        ___ lip                  cross-section of one side rail
       |   |___  roof panel ___
       |   |_____________________
   rail|                          <- roof slides along here
       |    ____________________
       |___|  ledge
       | wall
```

## Printing notes

* **Size / bed.** The case is intentionally large (30 × 17 × 12 cm). It is cut
  across the middle into two 150 mm halves, so each half is a 150 × 170 ×
  120 mm box; the roof is 295 × 153 mm. If your bed is smaller, scale the whole
  model down in your slicer, or lower `L`/`H` in the source — everything is
  parametric.
* **Orientation.** Print each body half sitting on its flat bottom, and the
  roof flat. No supports are needed for the roof; the rail lips print cleanly
  in that orientation.
* **Assembly.** Join the front and back halves along the mid-length seam
  (4 × Ø3 mm dowel holes in the side walls are provided for alignment — glue or
  pin them). Mount the Pi on the four standoffs (`58 × 49 mm`, M2.5) so its
  USB/Ethernet edge lines up with the front port holes, then slide the roof in
  from the back.
* **Colour.** Print the roof in a contrasting colour (e.g. red) if you want
  the sliding lid to stand out from the body.

## Editing / regenerating

Open `rpi5_case.scad` in OpenSCAD and tweak the variables at the top
(dimensions, wall thickness, port-hole sizes, roof-joint clearances,
Pi mount spacing, …). To regenerate the STLs from the command line:

```sh
make            # renders every part into stl/
# or individually:
openscad -o stl/rpi5_case_roof.stl --export-format binstl -D 'part="roof"' rpi5_case.scad
```

Valid `part` values: `assembled`, `body`, `body_front`, `body_back`, `roof`,
`exploded`.
