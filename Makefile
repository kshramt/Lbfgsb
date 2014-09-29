# Configurations

.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
.SECONDARY:
.PRECIOUS:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Constants

FC := gfortran

DRIVERS := driver1.f driver2.f driver3.f driver1.f90 driver2.f90 driver3.f90
DRIVER_EXES := $(DRIVERS:%=%.exe)

LBFGSB := lbfgsb.o
TIMER := timer.o

ifeq ($(FC),ifort)
   LIBS := -mkl
   FFLAGS := -warn -check -trace -O0 -p -g -DDEBUG -debug all
else
   LIBS := -lblas -llapack
   FFLAGS := -O -Wall -fbounds-check -g -Wno-uninitialized -fbacktrace
endif
FFLAGS += $(LIBS)

# Tasks

.PHONY: all

all: $(DRIVER_EXES)

# Files

# Rules

%.exe: % $(LBFGSB) $(TIMER)
	$(FC) $(FFLAGS) $^ -o $@

%.o: %.f
	$(FC) $(FFLAGS) -c $< -o $@

%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@
