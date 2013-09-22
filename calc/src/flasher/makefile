PROG		:= flasher
BUILDDIR	:= build

BRASS_FLAGS		:= -t inc/tasm80.tab
TASM_FLAGS		:= -t/tasm80 -i -b
TILEM_FLAGS		:= --rom=inc/ti83plus.rom --model=ti83p --reset --play-macro=tools/run.macro

EXTENSIONS := bin lst exp sym

all: $(BUILDDIR)/flasher.8xp

run: $(BUILDDIR)/$(PROG).8xp
	tilem2 $(TILEM_FLAGS) $(BUILDDIR)/$(PROG).8xp

$(BUILDDIR)/$(PROG).8xp: $(BUILDDIR)/$(PROG).bin inc/
	sudo sysctl -w vm.mmap_min_addr=0 # icky workaround to run MS-DOS
	cd $(BUILDDIR); wine ~/bin/devpac8x/DEVPAC8X.COM $(PROG)

$(BUILDDIR)/$(PROG).bin: build/
	ln -s inc tasm # icky workaround to keep tab file elsewhere
	wine ~/bin/tasm32/TASM.EXE $(TASM_FLAGS) $(PROG).z80 $(foreach EXT,$(EXTENSIONS),$(BUILDDIR)/$(PROG).$(EXT))
	rm -r tasm

build/:
	mkdir build

clean:
	-rm $(foreach EXT,$(EXTENSIONS),$(BUILDDIR)/$(PROG).$(EXT))
	-rm $(BUILDDIR)/$(PROG).8xp

.PHONY: all
