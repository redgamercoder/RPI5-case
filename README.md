# RPI5-case

A parametric, 3D-printable **Raspberry Pi 5 "monolith" wedge case**, modelled
in [OpenSCAD](https://openscad.org/) from a hand-drawn concept sketch.

![assembled case](renders/hero.png)

## The concept

The case is a long wedge / ramp — tall at the front, sloping down to a thin
back edge — built straight from the sketch's key details:

| Sketch note | In the model |
|---|---|
| 30 cm long, 17 cm wide | `L = 300`, `W = 170` |
| Wedge that slopes down to the back | `front_h = 120` → `back_h = 35` |
| "All the side ports" on the front | rectangular port window in the front face |
| Cooling fan (not to scale) | spoked fan grille on the side wall |
| Raspberry Pi logo on top | stylised berry-and-leaves logo embossed on the roof |
| Underneath: power button + micro-SD | holes in the floor under the board |
| "Print in two halves" | `body_left` + `body_right` (mirror split, with dowel holes) |
| "Roof is separate, slides in/out of a slot" | roof rides in a C-channel; the back is open as the slot |

## Files

```
rpi5_case.scad              parametric source (single file, edit this)
stl/
  rpi5_case_assembled.stl   whole case, roof in place (visualisation)
  rpi5_case_body.stl        the body as one piece
  rpi5_case_body_left.stl   left half  (print this)
  rpi5_case_body_right.stl  right half (print this)
  rpi5_case_roof.stl        the sliding roof, laid flat (print this)
renders/                    reference images
```

All STL parts are watertight, valid 2-manifolds.

## How the roof slot works

Each side wall carries an inner **C-channel rail**: a lip captures the roof
from above and a ledge supports it from below. The roof is a flat panel whose
two long edges slide along these channels. The back wall is lowered, leaving an
open **slot** — you slide the roof in from the back until it stops against the
tall front wall, and slide it back out to open the case. A finger-pull notch on
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

* **Size / bed.** The case is intentionally large (30 × 17 cm). It is split
  into two mirror halves so each half is 300 × 85 mm; the roof is 307 × 153 mm.
  If your bed is smaller, scale the whole model down in your slicer, or lower
  `L` in the source — everything is parametric.
* **Orientation.** Print each body half on its flat outer side wall, and the
  roof flat (logo up). No supports are needed for the roof; the body's fan
  grille and rail lips print cleanly in that orientation.
* **Assembly.** Join the two halves along the centre seam (3 × Ø4 mm dowel
  holes are provided for alignment — glue or pin them). Mount the Pi on the
  four standoffs (`58 × 49 mm`, M2.5), then slide the roof in from the back.
* **Colour.** Print the roof in red and the logo will read as a raised
  Raspberry Pi mark; for the official two-tone look, do a filament change at
  the top of the roof layer so the berries/leaves come out in colour.

## Editing / regenerating

Open `rpi5_case.scad` in OpenSCAD and tweak the variables at the top
(dimensions, wall thickness, fan size, port window, roof-joint clearances,
Pi mount spacing, …). To regenerate the STLs from the command line:

```sh
make            # renders every part into stl/
# or individually:
openscad -o stl/rpi5_case_roof.stl -D 'part="roof"' rpi5_case.scad
```

Valid `part` values: `assembled`, `body`, `body_left`, `body_right`, `roof`,
`exploded`.
