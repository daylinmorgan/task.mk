MAKEFLAGS += --no-print-directory
EXAMPLES := check embedded recipe-help phonify
GIFS := $(addsuffix /demo.gif, $(EXAMPLES))

all: $(GIFS)

%/demo.gif: %/demo.tape %/Makefile
	cd $* && vhs < demo.tape

clean:
	rm -rf $(GIFS)

.PHONY: all clean
