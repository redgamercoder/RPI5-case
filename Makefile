# Regenerate the STL parts from the parametric source.
#   make            build every part into stl/
#   make renders    re-render the reference PNGs
#   make clean      remove generated STLs
#
# OpenSCAD 2021.x renders STLs from the command line; on a headless box wrap
# the call in `xvfb-run -a` (only needed for the PNG renders).

SCAD    := rpi5_case.scad
OPENSCAD?= openscad
PARTS   := assembled body body_left body_right roof
STLS    := $(addprefix stl/rpi5_case_,$(addsuffix .stl,$(PARTS)))

all: $(STLS)

stl/rpi5_case_%.stl: $(SCAD)
	@mkdir -p stl
	$(OPENSCAD) -o $@ --export-format binstl -D 'part="$*"' $(SCAD)

renders: $(SCAD)
	@mkdir -p renders
	xvfb-run -a $(OPENSCAD) -o renders/hero.png --imgsize=1200,850 \
	  -D 'part="assembled"' --camera=0,0,0,62,0,28,0 --viewall --autocenter \
	  --colorscheme=Tomorrow $(SCAD)
	xvfb-run -a $(OPENSCAD) -o renders/exploded.png --imgsize=1200,850 \
	  -D 'part="exploded"' --camera=0,0,0,58,0,26,0 --viewall --autocenter \
	  --colorscheme=Tomorrow $(SCAD)

clean:
	rm -f $(STLS)

.PHONY: all renders clean
