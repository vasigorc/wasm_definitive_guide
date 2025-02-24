COMPILER = em++
OPTIONS = -std=c++11 -Wall -Werror -Wextra
LINKER_OPT = -L/usr/lib -lstdc++ -lm
EMSCRIPTEN_OPTS = -s WASM=1 -s EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' -s EXPORTED_FUNCTIONS='["_malloc", "_free"]' -s NO_EXIT_RUNTIME=1 -s TOTAL_MEMORY=16777216 -s ALLOW_MEMORY_GROWTH=1 -s ASSERTIONS=1 --bind

all: image_processor

image_processor: image_processor.cpp
	$(COMPILER) $(OPTIONS) image_processor.cpp -o image_processor.js $(LINKER_OPT) $(EMSCRIPTEN_OPTS) -O3

clean:
	rm -f core *.0 *.bak *stackdump *~ *.wasm image_processor.js
