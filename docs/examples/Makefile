MAKEFLAGS += --no-print-directory
COLS ?= 60
ROWS ?= 20
EXAMPLES := check embedded
CASTS := $(addsuffix /demo.cast, $(EXAMPLES))

all: $(CASTS)

%/demo.cast: %/record.sh
	asciinema rec --cols $(COLS) --rows $(ROWS) --overwrite -c $< $@

check/demo.cast: COLS = 48
check/demo.cast: ROWS = 12

clean:
	rm -rf $(CASTS)

.PHONY:all clean
