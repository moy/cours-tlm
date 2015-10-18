ifndef SYSTEMCROOT
SYSTEMCROOT = /home/perms/moy/tlm/systemc-2.3.0
endif

minimal: minimal.cpp
	g++ minimal.cpp -Wall -Wno-deprecated \
		-I $(SYSTEMCROOT)/include \
		-L $(SYSTEMCROOT)/lib-gccsparcOS5/ \
		-L $(SYSTEMCROOT)/lib-linux/ \
		-L $(SYSTEMCROOT)/lib-linux64/ \
		-Wl,-Bstatic -lsystemc -Wl,-Bdynamic -pthread \
	-o minimal
