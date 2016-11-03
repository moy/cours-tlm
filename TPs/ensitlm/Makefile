MODULE = ensitlm

TARGET = ensitlm.h.gch

ROOT=..
include $(ROOT)/Makefile.common

FILES=${wildcard *.h *.cpp}

clang-format:
	$(CLANG_FORMAT) -i $(FILES)
