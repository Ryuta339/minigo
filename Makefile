# All the commands are supposed to run on Linux.
# I use Docker. Please see README.md
# test

all: minigo /tmp/tmpfs

/tmp/tmpfs:
	mkdir -p /tmp/tmpfs

# 1st gen compiler
minigo: *.go internal/*/* stdlib/*/* /tmp/tmpfs macro.s
	go build -o minigo *.go

# assembly for 2gen
minigo.s: minigo
	./minigo --position [a-z]*.go > /tmp/tmpfs/minigo.s
	cp /tmp/tmpfs/minigo.s minigo.s

# 2gen compiler
minigo2: minigo.s
	as -o minigo.o minigo.s
	ld -o minigo2 minigo.o

# assembly for 3gen
minigo2.s: minigo2
	./minigo2 [a-z]*.go > /tmp/tmpfs/minigo2.s
	cp /tmp/tmpfs/minigo2.s minigo2.s

# 3gen compiler
minigo3: minigo2.s
	as -o minigo2.o minigo2.s
	ld -o minigo3 minigo2.o

# assembly for 4gen
minigo3.s: minigo3
	./minigo3 [a-z]*.go > /tmp/tmpfs/minigo3.s
	cp /tmp/tmpfs/minigo3.s minigo3.s


selfhost: minigo3.s
	diff /tmp/tmpfs/minigo2.s /tmp/tmpfs/minigo3.s && echo ok

test: minigo3.s
	make vet selfhost
	./test_group 1
	./test_group 2
	./comparison-test.sh
	./test_group 0

clean:
	rm -f minigo*
	rm -f a.s a.out
	rm -rf /tmp/tmpfs/*

fmt:
	gofmt -w *.go t/*/*.go

vet:
	go vet *.go
