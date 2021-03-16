TARGET = libsecp256k1

# Paths
LIB_DIR = secp256k1-zkp
BUILD_DIR = build

# Tools
TOOLCHAIN_PREFIX ?= x86_64-w64-mingw32-
CC := $(TOOLCHAIN_PREFIX)gcc
ifeq ($(OS),Windows_NT)
MKDIR_P = mkdir
RM_R = rmdir /s /q
else
MKDIR_P = mkdir -p
RM_R = rm -r
endif

# C sources
C_SOURCES = $(addprefix $(LIB_DIR)/src/,\
	secp256k1.c \
	)

# C includes
C_INCLUDES =  \
	$(LIB_DIR) \
	$(LIB_DIR)/src \
	config

# C defines
C_DEFS =  \
	HAVE_CONFIG_H \
	SECP256K1_BUILD \
	_WIN32

OBJS := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

DEPS := $(OBJS:.o=.d)

CFLAGS = -O2 -std=c99 -MMD -MP -Werror -Wno-unused-function \
	$(addprefix -I,$(C_INCLUDES)) $(addprefix -D,$(C_DEFS))

LDFLAGS = -shared -s \
	-Wl,--subsystem,windows,--out-implib,$(BUILD_DIR)/$(TARGET).a

$(BUILD_DIR)/$(TARGET).dll: $(OBJS) Makefile
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(MKDIR_P) "$(dir $@)"
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(RM_R) "$(BUILD_DIR)"

-include $(DEPS)
