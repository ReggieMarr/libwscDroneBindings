# Set the library version
LIB_MAJOR_VER = 0
LIB_MINOR_VER = 0
LIB_PATCH_VER = 0
LIB_VER = $(LIB_MAJOR_VER).$(LIB_MINOR_VER).$(LIB_PATCH_VER)


# Check for environment variables.
ifndef SHELL
SHELL = /usr/bin/sh
endif

ifndef ARCH
ARCH = $(shell uname -m)
endif

ifndef ARSDK3
ARSDK3=/home/reggiemarr/Projects/wescam_hackathon_2019/github/sdks/out/arsdk-native/staging/usr
endif
ifndef LIBWSCDRONE
LIBWSCDRONE= $HACK19_PATH/libwscDrone
endif

ifndef DIST_DIR
DIST_DIR = $(CURDIR)/dist
endif

ifndef DIST_LIBDIR
DIST_LIBDIR = $(DIST_DIR)/lib/
endif


OBJDIR = $(CURDIR)/obj/
PREFIX = usr/local/include/
DEPDIR = $(CURDIR)/deps/
OUTPUT_DIRS = $(CURDIR)/obj/ $(CURDIR)/dist/lib $(CURDIR)/dist/include/$(TARGET_NAME)
OUTPUT_DIRS += $(CURDIR)/deps $(DIST_DIR)
# OUTPUT_DIRS = $(CURDIR)/deps $(DIST_DIR)/$(PREFIX)
BINDINGS_INCDIR = $(CURDIR)/inc/
BINDINGS_SRCDIR = $(CURDIR)/src/
CC  = $(TOOL_PREFIX)gcc
CXX = $(TOOL_PREFIX)g++
AR = $(TOOL_PREFIX)ar
LD = $(TOOL_PREFIX)ld



TARGET_NAME = wscDroneBindings

DYN_TARGET_LIST    = lib$(TARGET_NAME).so.$(LIB_VER)
STATIC_TARGET_LIST = lib$(TARGET_NAME).a
DYN_TARGET    = $(addprefix $(DIST_LIBDIR), $(DYN_TARGET_LIST))
STATIC_TARGET = $(addprefix $(DIST_LIBDIR), $(STATIC_TARGET_LIST))

FLAGS += -std=c++14 -Wall -pedantic -O2 -Wno-deprecated-declarations
LOC_INC = -I$(DIST_DIR)/$(PREFIX)/include 
LOC_LIB = -L$(DIST_DIR)/$(PREFIX)/lib 

SYS_INC += -I$(ARSDK3)/include
SYS_LIB += -L$(ARSDK3)/lib
SYS_LIB += -L/usr/local/lib
# SYS_LIB += -lpthread -lrtsp -lsdp -lmux -lpomp -ljson-c -lulog -lfutils
SYS_LIB += -L$(LIBWSCDRONE)/dist/lib -Wl,--whole-archive -lwscDrone
SYS_INC += -I/usr/local/include -I/usr/include/python3.6
# SYS_INC += -I$(LIBWSCDRONE)/include


LOCAL_INCDIR = $(CURDIR)/src/
SYS_LIB = -L=/usr/local/lib -L/usr/bin/python3.6
#COMMON_FLAGS += -pedantic -Wall -Wextra -Wno-deprecated-declarations
COMMON_FLAGS += -Wno-deprecated-declarations
# shared library flags
COMMON_FLAGS += -shared -fPIC
CPPFLAGS     += -I$(LOCAL_INCDIR) $(SYS_INC)
# CPPFLAGS     += -L$(LIBWSCDRONE)/dist/lib -Wl,--whole-archive -lwscDrone
CXXFLAGS     += -std=c++14 $(COMMON_FLAGS)
LDFLAGS      += -shared -fPIC
# for Bebop2 SDK
SYS_DYN_LIBS_LIST += arsal arcommands ardiscovery arcontroller armedia arnetwork arnetworkal arstream arstream2
SYS_DYN_LIBS_LIST += pthread rtsp sdp mux pomp json-c ulog futils
#for FFMPEG
SYS_DYN_LIBS_LIST += avformat avcodec avutil swscale

DEBUGFLAGS     = -ggdb3 -O0 -D _DEBUG
RELEASEFLAGS   = -O3 -D NDEBUG
DEFAULTFLAGS   = -O3 -D NDEBUG
#Extra Library Source Files For The Generic API IF
CPP_BINDINGS_HEADER_LIST = Bebop2CtrlIF \
                             Bebop2FrameIF
CPP_BINDINGS_SRC_LIST = Bebop2CtrlIF \
                             Bebop2FrameIF
#Prepend the path
SYS_DYN_LIBS  = -L$(DIST_LIBDIR) $(SYS_LIB) $(addprefix -l, $(SYS_DYN_LIBS_LIST))
SYS_STAT_LIBS = -L$(DIST_LIBDIR) $(SYS_LIB) $(addprefix -l, $(SYS_STAT_LIBS_LIST))
BINDING_HEADERS = $(addsuffix .h, $(addprefix $(BINDINGS_INCDIR), $(CPP_BINDINGS_HEADER_LIST)))
SOURCES_BINDINGS_CPP = $(addsuffix .cpp, $(addprefix $(BINDINGS_SRCDIR), $(CPP_BINDINGS_SRC_LIST)))
OBJECTS_BINDINGS_CPP = $(addsuffix .o, $(addprefix $(OBJDIR), $(CPP_BINDINGS_SRC_LIST)))

# TESTLIBPATH = -L/usr/local/lib -lpthread -lrtsp -lsdp -lmux -lpomp -ljson-c -lulog -lfutils
TESTLIBPATH += -L$(LIBWSCDRONE)/dist/lib -Wl,--whole-archive -lwscDrone

all: directories binding_headers $(DYN_TARGET) $(STATIC_TARGET)  

directories:
	mkdir -p $(OUTPUT_DIRS)


#no longer in use
# binding_sources:
# 	${CC} ${FLAGS} -o ${TARGET_NAME} ${SOURCES_BINDINGS_CPP} ${SYS_INC} ${LOC_INC} ${LOC_LIB} ${SYS_LIB}

binding_headers:
	cp -f $(BINDING_HEADERS) $(DIST_INCDIR)/$(PREFIX)

$(DYN_TARGET):  $(OBJECTS_BINDINGS_CPP) 
	$(CXX) $(LDFLAGS) -o $(DYN_TARGET)  $(OBJECTS_BINDINGS_CPP) $(TESTLIBPATH)  
	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so
	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so.$(LIB_MAJOR_VER)
	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so.$(LIB_MAJOR_VER).$(LIB_MINOR_VER)
# $(DYN_TARGET):  $(OBJECTS_BINDINGS_CPP) 
# 	$(CXX) $(LDFLAGS) -o $(DYN_TARGET)  $(OBJECTS_BINDINGS_CPP)  -Wl,-Bstatic $(SYS_STAT_LIBS) -Wl,-Bdynamic $(SYS_DYN_LIBS)
# 	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so
# 	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so.$(LIB_MAJOR_VER)
# 	ln -f -s lib$(TARGET_NAME).so.$(LIB_VER) $(DIST_LIBDIR)/lib$(TARGET_NAME).so.$(LIB_MAJOR_VER).$(LIB_MINOR_VER)

$(STATIC_TARGET):  $(OBJECTS_BINDINGS_CPP)
	$(AR) $(ARFLAGS) $(STATIC_TARGET)  $(OBJECTS_BINDINGS_CPP) 

$(OBJDIR)%.o: $(BINDINGS_SRCDIR)%.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(DEFAULTFLAGS) -c -o $@ $<

$(OBJDIR)%.o: $(BINDINGS_SRCDIR)%.c

printvar:
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

clean:
	-rm -f  $(OBJECTS_BINDINGS_CPP) 

distclean: clean
	-rm -rf $(DIST_DIR)
	-rm -rf $(OBJDIR)