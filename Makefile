CFLAGS_WO_STD = -W -Wall -pedantic -g
CFLAGS = -std=c11 $(CFLAGS_WO_STD)

SRC =	pffft.c 			\
	midl.c 				\
	mdb.c 			        \
	hash-table.c     		\
	olaf.c 			        \
	olaf_fp_file_writer.c 	        \
	olaf_db.c 			\
	olaf_fp_db_writer.c 		\
	olaf_ep_extractor.c 		\
	olaf_fp_extractor.c 		\
	olaf_reader_stream.c 	        \
	olaf_runner.c 		        \
	olaf_stream_processor.c 	\
	olaf_fp_matcher.c 		\
	olaf_config.c

OBJ := $(SRC:.c=.o)
OUTDIR := bin
EXE := $(OUTDIR)/olaf_c

all: $(EXE)

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(EXE): $(OBJ) $(OUTDIR)
	gcc -o $@ *.o 			-lc -lm -ffast-math -pthread

pffft.o: src/pffft.c
	gcc -c $^ $(CFLAGS_WO_STD) -std=gnu11

%.o: src/%.c
	gcc -c $^ $(CFLAGS)

#The memory database version is equal to the embedded version
mem:
	gcc -c src/pffft.c 					-W -Wall -std=gnu11 -pedantic -O2 #pfft needs M_PI and other constants not in the ANSI c standard
	gcc -c src/hash-table.c     	 	-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf.c 					-W -Wall -std=gnu11 -pedantic -O2
	gcc -c src/olaf_db_mem.c 			-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_fp_db_writer_mem.c 	-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_fp_file_writer.c 	-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_runner.c 			-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_stream_processor.c 	-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_ep_extractor.c 		-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_fp_extractor.c 		-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_reader_stream.c		-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_fp_matcher.c 		-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_config.c 			-W -Wall -std=c11 -pedantic -O2
	mkdir -p bin
	gcc -o bin/olaf_mem *.o 			-lc -lm -ffast-math -pthread

#Compiles the webassembly version: it is similar to the mem version
web:
	emcc -o wasm/js/olaf.html -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS="['_malloc','_free']" -s EXPORTED_RUNTIME_METHODS='["cwrap"]' \
		src/olaf_wasm.c \
		src/pffft.c \
		src/hash-table.c \
		src/olaf_ep_extractor.c \
		src/olaf_fp_extractor.c \
		src/olaf_db_mem.c \
		src/olaf_fp_db_writer_mem.c \
		src/olaf_fp_matcher.c \
		src/olaf_config.c  -O3 -Wall -lm -lc -W -I.

#Cleans the temporary files
clean:
	-rm -f *.o
	-rm -f bin/*
	-rm -f wasm/js/olaf.js
	-rm -f wasm/js/olaf.html
	-rm -f wasm/js/olaf.wasm

#Deletes the database, check your configuration
destroy_db:
	rm ~/.olaf/db/*

#Installs olaf on its default location
install:
	mkdir -p ~/.olaf/db/
	sudo cp bin/olaf_c /usr/local/bin/olaf_c
	sudo chmod +x /usr/local/bin/olaf_c
	sudo cp olaf.rb /usr/local/bin/olaf
	sudo chmod +x /usr/local/bin/olaf

#installs olaf as root user
install-su:
	mkdir -p ~/.olaf/db/
	cp bin/olaf_c /usr/local/bin/olaf_c
	chmod +x /usr/local/bin/olaf_c
	cp olaf.rb /usr/local/bin/olaf
	chmod +x /usr/local/bin/olaf

#removes all installed files
uninstall:
	rm -r ~/.olaf
	sudo rm /usr/local/bin/olaf /usr/local/bin/olaf_c

#Compile and run the tests
test:
	gcc -c src/olaf_config.c -W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_reader_stream.c -W -Wall -std=c11 -pedantic -O2
	gcc -c tests/olaf_tests.c	-Isrc	-W -Wall -std=c11 -pedantic -O2
	gcc -c src/midl.c 					-W -Wall -std=c11 -pedantic -O2
	gcc -c src/mdb.c 					-W -Wall -std=c11 -pedantic -O2
	gcc -c src/olaf_db.c 			-W -Wall -std=c11 -pedantic -O2
	mkdir -p bin
	gcc -o bin/olaf_tests *.o		-lc -lm -ffast-math
	mkdir -p tests/olaf_test_db
	rm tests/olaf_test_db/*
