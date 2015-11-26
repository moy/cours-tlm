MODULE = native-wrapper

ESOFT_OBJS = ../software/native/main.o

SRCS = sc_main_native.cpp native_wrapper.cpp

TARGET = run.x

ROOT=../../..
WITH_SDL=yesPlease
include $(ROOT)/Makefile.common

EXTRALDLIBS += -L../hardware -lhardware
CXXEXTRAFLAGS = -I../hardware
CEXTRAFLAGS = -I. 

$(TARGET): $(ESOFT_OBJS) $(OBJS) hardware
	$(LD) $(ESOFT_OBJS) $(OBJS) -o $@ $(LDFLAGS) $(EXTRALDLIBS) $(LDLIBS)

.PHONY: hardware
hardware:
	@cd .. && $(MAKE) hardware

.PHONY: $(ESOFT_OBJS)
$(ESOFT_OBJS):
	cd ../software/native/ && $(MAKE)

FORCE:

# Include dependency files
-include $(ESOFT_DEPS)
