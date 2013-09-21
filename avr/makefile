include inc/make_colors
include inc/make_info

TARGETS := \
	bootloader \
	synthesizer

CLEANERS := $(foreach TARGET,$(TARGETS),clean_$(TARGET))

all: $(TARGETS) success

$(TARGETS):
	@cd ./$@; make

success:
	@echo "$(GREEN)Done!$(NO_COL)"

program:
	sudo avrdude -c usbtiny -p atmega328p -U flash:w:synth_boot.hex

fuses:
	sudo avrdude -c usbtiny -p atmega328p -U lfuse:w:0xe2:m -U hfuse:w:0xdc:m -U efuse:w:0xff:m

$(CLEANERS):
	@cd ./$(subst clean_,,$@); make clean

clean: $(CLEANERS)

#clean$(TARGETS):
#	@cd ./$@; make clean

.PHONY: $(TARGETS) success all clean $(CLEANERS)
