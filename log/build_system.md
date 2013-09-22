After a day of struggle, I had success making a pleasant build system for the calculator development side of this project. Working on Linux made things harder because most of the calc dev tools I found are written for Windows. 

Before reaching the right mixture I tried: 

* Brass - poor command line options, slow assembly time, unfamiliar syntax, and Mono requirement for Linux. 
* Spasm - differences in syntax + impatience made me look elsewhere. 
* Virtual TI - runs fine and has some good features. But every time I wanted to run my program I had to spend 30 seconds clicking things with the mouse. I test over and over again quickly, so this was unacceptable. Tried many hacky things to try to automate it, like using the xdotool command in my makefile to send keypresses and mouse movements (file picker dialog broke this approach), using binary tools to place my compiled program directly into a .sav calculator state (not useful because file picker still needed to be navigated to load the .sav file), and even cracking the thing open in GDB to try to hack in autoloading on startup (was taking too long, very flaky, and not reproducible enough for other people to be able to use my code). 
* Wabbitemu - a great emulator, but my distro isn't happy using recent versions of Wine, so I couldn't get past the 'Screen not found' error. 

The right mixture: 

* TASM - runs fine under wine and has the options I want (mostly where to place output files, and format selection) 
* DEVPAC8X - also runs fine under wine. Slight hack needed to avoid copying the .tab file. See makefile snippet below. 
* TILEM - I tried and failed to get this working 3 times in the past, so I wrote it off. But after I ran out of options I gave it another shot, this time compiling it from source after using the installation script from the TilP project. It worked after a few package dependency hiccups, and now it's my favorite emulator. It has all kinds of nice command line options and macro support. It gave me what I wanted - not having to click a bunch of things and wait forever to see my program run. 

Here's what it looks like in my makefile: 

	PROG   := flasher 
	BUILDDIR := build 

	BRASS_FLAGS      := -t inc/tasm80.tab 
	TASM_FLAGS      := -t/tasm80 -i -b 
	TILEM_FLAGS      := --rom=inc/ti83plus.rom --model=ti83p --reset --play-macro=tools/run.macro 

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
	
So now I just do `make run` and a few seconds later I see my recompiled, running program. I'm hoping the productivity gain will be worth the time spent. But it was also fun to try to hack around all the annoying problems.
