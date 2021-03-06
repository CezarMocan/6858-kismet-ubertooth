KIS_SRC_DIR ?= /usr/src/kismet
KIS_INC_DIR ?= $(KIS_SRC_DIR)
RXTX_SRC_DIR ?= ../../bluetooth_rxtx
RXTX_INC_DIR ?= $(RXTX_SRC_DIR)
LIBDIR ?= /lib

include $(KIS_SRC_DIR)/Makefile.inc

BLDHOME	= .
top_builddir = $(BLDHOME)

PLUGINLDFLAGS ?= $(LDFLAGS)
PLUGINLDFLAGS += -shared -rdynamic
LIBS	+= -lstdc++ -lbluetooth -lusb-1.0 -lpthread -lbtbb -lubertooth 
CFLAGS	+= -I/usr/include -I$(KIS_INC_DIR) -I$(RXTX_INC_DIR) -g -fPIC
CXXFLAGS	+= -I/usr/include -I$(KIS_INC_DIR) -I$(RXTX_INC_DIR) -g -fPIC

SRVOBJS = packetsource_ubertooth.o packet_btbb.o packet_btbb_types.o \
			tracker_btbb.o kismet_ubertooth.o 
SRVOUT	= ubertooth.so

CLIOBJS = ubertooth_ui.o
CLIOUT  = ubertooth_ui.so

all:	$(SRVOUT) $(CLIOUT)

$(CLIOUT):	$(CLIOBJS)
	$(CC) $(PLUGINLDFLAGS) $(CFLAGS) $(CLIOBJS) -o $(CLIOUT) $(LIBS)

$(SRVOUT):	$(SRVOBJS)
	$(CC) $(PLUGINLDFLAGS) $(CFLAGS) $(SRVOBJS) -o $(SRVOUT) $(LIBS)

install:	$(SRVOUT) $(CLIOUT)
	mkdir -p $(DESTDIR)$(prefix)/$(LIBDIR)/kismet/
	install -o $(INSTUSR) -g $(INSTGRP) -m 644 $(SRVOUT) $(DESTDIR)$(prefix)/$(LIBDIR)/kismet/$(SRVOUT)
	mkdir -p $(DESTDIR)$(prefix)/$(LIBDIR)/kismet_client/
	install -o $(INSTUSR) -g $(INSTGRP) -m 644 $(CLIOUT) $(DESTDIR)$(prefix)/$(LIBDIR)/kismet_client/$(CLIOUT)


userinstall:	$(SRVOUT) $(CLIOUT)
	mkdir -p ${HOME}/.kismet/plugins/
	install -v $(SRVOUT) ${HOME}/.kismet/plugins/$(SRVOUT)
	mkdir -p ${HOME}/.kismet/client_plugins/
	install -v $(CLIOUT) ${HOME}/.kismet/client_plugins/$(CLIOUT)

clean:
	@-rm -f *.o
	@-rm -f *.so

.c.o:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $*.c -o $@ 

.cc.o:
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $*.cc -o $@ 

.SUFFIXES: .c .cc .o
