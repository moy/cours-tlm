MODULE = iss

ESOFT_BIN = ../software/cross/a.out

SRCS = sc_main_iss.cpp mb_wrapper.cpp microblaze.cpp

TARGET = run.x

all: $(TARGET) $(ESOFT_BIN)

ROOT=../../..
WITH_SDL=yesPlease
include $(ROOT)/Makefile.common

EXTRALDLIBS += -L../hardware -lhardware -L../elf-loader -lloader
CXXEXTRAFLAGS = -I../hardware
CEXTRAFLAGS = -I. 

$(TARGET): $(OBJS) hardware lib-loader
	$(LD) $(ESOFT_OBJS) $(OBJS) -o $@ $(LDFLAGS) $(EXTRALDLIBS) $(LDLIBS)

%.o: ../software/%.c $(filter-out %.d, $(MAKEFILE_LIST))
	$(CC) -c $< -o $@ $(CPPFLAGS) $(CFLAGS) $(CEXTRAFLAGS)

.PHONY: $(ESOFT_BIN)
$(ESOFT_BIN):
	cd ../software/cross && $(MAKE)

.PHONY: hardware lib-loader
hardware:
	@cd .. && $(MAKE) hardware

lib-loader:
	@cd ../elf-loader/ && $(MAKE)

# Include dependency files
-include $(ESOFT_DEPS)
