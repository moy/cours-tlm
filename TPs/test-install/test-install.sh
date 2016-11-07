#!/bin/sh

DIR=$(dirname "$0")
DIR=$(cd "$DIR" && pwd)

die () {
    echo "$*"
    if test -d "$tmp"
    then
	echo "Directory $tmp not deleted. You may examine its content for debugging."
    fi
    exit 1
}

start_test () {
    printf "testing %s ..." "$*"
}

test_ok () {
    printf " OK\n"
}

tmp="$PWD"/tmp.$$
mkdir -p "$tmp"
cd "$tmp"

start_test g++
g++ "$DIR"/test-c++.cpp -o ./test-c++ || die "Cant run g++"
./test-c++ > actual || die "Can't execute program"
echo 'g++ works!' > expected
diff actual expected || die "Incorrect output"
test_ok

start_test SystemC installation
test -n "$SYSTEMCROOT" || die "Please, set \$SYSTEMCROOT"
test -e "$SYSTEMCROOT"/include/systemc || die "$SYSTEMCROOT/include/systemc does not exist. Check \$SYSTEMCROOT."
ARCH=$("$SYSTEMCROOT"/config/config.guess | sed -e 's/x86_64-.*-linux-gnu/linux64/' -e 's/i.86-.*-linux-gnu/linux/' -e 's/x86_64-.*-darwin.*/macosx64/')
test -e "$SYSTEMCROOT/lib-$ARCH"/libsystemc.la || die "$SYSTEMCROOT/lib-$ARCH/libsystemc.la does not exist. Check your SystemC installation."
test_ok

start_test SystemC compilation
g++ "$DIR"/test-systemc.cpp \
    -I "$SYSTEMCROOT"/include/ \
    -L "$SYSTEMCROOT/lib-$ARCH" \
    -Xlinker -Bstatic -lsystemc -Xlinker -Bdynamic -pthread \
    -o test-systemc || die "Can't compile a SystemC program"
./test-systemc 2>/dev/null > actual || die "Can't execute SystemC program"
echo 'SystemC works!' > expected
diff actual expected || die "Incorrect output from SystemC program"
test_ok

start_test X11
g++ "$DIR"/test-x11.cpp -o test-x11 -lX11 || die "Can't compile a program using X11. Do you have libx11-dev installed?"
./test-x11 || die "Can't execute a program using X11. Your installation of X11 is seriously broken :-(."
test_ok

start_test SDL
command -v sdl-config >/dev/null || die "Can't find sdl-config. Check that you have the SDL library installed."
g++ "$DIR"/test-sdl.cpp `sdl-config --cflags` `sdl-config --libs` -o test-sdl || die "Can't compile an SDL program."
./test-sdl || die "Can't execute an SDL program."
test_ok

start_test MicroBlaze installation
test -n "$CROSS_COMPILE" || die "Please, set \$CROSS_COMPILE to e.g. microblaze-unknown-linux-gnu-"
check_cmd () {
    command -v "$CROSS_COMPILE""$1" >/dev/null || die "Can't find ${CROSS_COMPILE}g++"
}
check_cmd ld
check_cmd gcc
check_cmd objdump
test_ok

start_test MicroBlaze compilation
"$CROSS_COMPILE"gcc "$DIR"/test-microblaze.c -o test-microblaze || die "Can't cross-compile with $CROSS_COMPILE"gcc
test -x test-microblaze || die "Executable file not generated"
"$CROSS_COMPILE"objdump -d test-microblaze > actual || die "Can't disassemble with $CROSS_COMPILE"objdump
grep -q '^[0-9a-zA-Z]* *<main>: *$' actual || die "Dissassembly doesn't contain main function"
test_ok

echo "All tests passed successfully"
rm -fr "$tmp"
