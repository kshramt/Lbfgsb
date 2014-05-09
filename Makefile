.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
.SECONDARY:
.PRECIOUS:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

FC := gfortran

FFLAGS := -O -Wall -fbounds-check -g -Wno-uninitialized

DRIVERS := driver1.f driver2.f driver3.f driver1.f90 driver2.f90 driver3.f90
DRIVER_EXES := $(DRIVERS:%=%.exe)

LBFGSB := lbfgsb.o
LINPACK := linpack.o
BLAS := blas.o
TIMER := timer.o

.PHONY: all

all: $(DRIVER_EXES)

%.exe: % $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
	$(FC) $(FFLAGS) $^ -o $@

%.o: %.f
	$(FC) $(FFLAGS) -c $< -o $@

%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@
