#!/bin/bash
# This is a shell script to check your program(s) on test cases.
# It usese the same language you normally use to type commands in
# a terminal window.  You can write whole programs in shell.

# Assume we've succeeded until we see otherwise.
FAIL=0

# Print an error message and set the fail flag.
fail() {
    echo "**** $1"
    FAIL=1
}

# Check the exit status.  The actual exit status (ASTATUS) should match
# the expected status (ESTATUS)
checkStatus() {
  ESTATUS="$1"
  ASTATUS="$2"

  # Make sure the program exited with the right exit status.
  if [ "$ASTATUS" -ne "$ESTATUS" ]; then
      fail "FAILED - incorrect program exit status. (expected $ESTATUS,  Got: $ASTATUS)"
      return 1
  fi

  return 0
}

# Check the contents of an a file.  If the expected file (EFILE)
# exists, then the actual file (AFILE) should exist and it should match.
checkFile() {
  NAME="$1"
  EFILE="$2"
  AFILE="$3"

  # Make sure we're really expecting this file.
  if [ ! -f "$EFILE" ]; then
      return 0
  fi

  # Make sure the output matches the expected output.
  echo "   diff $EFILE $AFILE"
  diff -q "$EFILE" "$AFILE" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      fail "FAILED - $NAME ($AFILE) doesn't match expected ($EFILE)"
      return 1
  fi

  return 0
}

# Same as checkFile, but if the expected file (EFILE) doesn't exist, the
# actual file (AFILE) should not exit either.
checkFileOrMissing() {
  NAME="$1"
  EFILE="$2"
  AFILE="$3"
  
  # if the expected output file doesn't exist, the actual file should't either.
  if [ ! -f "$EFILE" ]; then
      if [ -f "$AFILE" ]; then
	  fail "FAILED - $NAME ($AFILE) should not be created."
	  return 1
      fi
      return 0
  fi

  # Make sure the output matches the expected output.
  echo "   diff $EFILE $AFILE"
  diff -q "$EFILE" "$AFILE" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      fail "FAILED - $NAME ($AFILE) doesn't match expected ($EFILE)"
      return 1
  fi

  return 0
}

# Same as checkFile, but if the expected file (EFILE) doesn't exist, the
# actual file (AFILE) should be empty.
checkFileOrEmpty() {
  NAME="$1"
  EFILE="$2"
  AFILE="$3"
  
  # if the expected output file doesn't exist, the actual file should be
  # empty.
  if [ ! -f "$EFILE" ]; then
      if [ -s "$AFILE" ]; then
	  fail "FAILED - $NAME ($AFILE) should be empty."
	  return 1
      fi
      return 0
  fi

  # Make sure the output matches the expected output.
  echo "   diff $EFILE $AFILE"
  diff -q "$EFILE" "$AFILE" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      fail "FAILED - $NAME ($AFILE) doesn't match expected ($EFILE)"
      return 1
  fi

  return 0
}

# The given file, AFILE, should be empty.
checkEmpty() {
  NAME="$1"
  AFILE="$2"
  
  if [ -s "$AFILE" ]; then
      fail "FAILED - $NAME ($AFILE) should be empty."
      return 1
  fi

  return 0
}

# Run a test of the driver program.
runTest() {
  TESTNO=$1

  echo "Test $TESTNO"
  rm -f output.txt stderr.txt

  echo "   ./driver < input-$TESTNO.txt > output.txt 2> stderr.txt"
  ./driver < input-$TESTNO.txt > output.txt 2> stderr.txt
  ASTATUS=$?

  if ! checkStatus 0 "$ASTATUS" ||
     ! checkFile "Program output" "expected-$TESTNO.txt" "output.txt" ||
     ! checkEmpty "Stderr output" "stderr.txt"
  then
      FAIL=1
      return 1
  fi

  echo "Test $TESTNO PASS"
  return 0
}

# get a fresh copy of the target program
make clean

# Make the double unit test program and run it
rm -f doubleTest
make doubleTest

if [ -x doubleTest ]; then
    if ./doubleTest; then
	echo "Double test program passed"
    else
	echo "Double test program didn't finish successfully."
    fi
else
    fail "Couldn't build the doubleTest program."
fi


# Make the string unit test program and run it
rm -f stringTest
make stringTest

if [ -x stringTest ]; then
    if ./stringTest; then
	echo "String test program passed"
    else
	echo "String test program didn't finish successfully."
    fi
else
    fail "Couldn't build the stringTest program."
fi


# Make the map unit test program and run it
rm -f mapTest
make mapTest

if [ -x mapTest ]; then
    if ./mapTest; then
	echo "Map test program passed"
    else
	echo "Map test program didn't finish successfully."
    fi
else
    fail "Couldn't build the mapTest program."
fi


make
if [ $? -ne 0 ]; then
  fail "Make exited unsuccessfully"
fi

# Run all the black-box tests.
if [ -x driver ]; then
    runTest 01
    runTest 02
    runTest 03
    runTest 04
    runTest 05
    runTest 06
    runTest 07
    runTest 08
    runTest 09
    runTest 10
    runTest 11
else
    fail "Your driver program didn't compile, so it couldn't be tested."
fi


if [ $FAIL -ne 0 ]; then
  echo "FAILING TESTS!"
  exit 13
else 
  echo "TESTS SUCCESSFUL"
  exit 0
fi
