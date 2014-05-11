# Configurations

.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
.SECONDARY:
.PRECIOUS:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Constants

LAPACK_VERSION := 3.5.0
LAPACK := lapack-$(LAPACK_VERSION)

FC := gfortran

FFLAGS := -O -Wall -fbounds-check -g -Wno-uninitialized -fbacktrace

DRIVERS := driver1.f driver2.f driver3.f driver1.f90 driver2.f90 driver3.f90
DRIVER_EXES := $(DRIVERS:%=%.exe)

LAPACKS := dpotrf dpotf2 ilaenv disnan ieeeck iparmq xerbla dlaisnan dtrtrs
LAPACK_OS := $(LAPACKS:%=%.o)
BLASS := dgemm dsyrk dtrsm lsame dgemv dnrm2 daxpy dcopy ddot dscal
BLAS_OS := $(BLASS:%=%.o)
LBFGSB := lbfgsb.o
TIMER := timer.o

# Tasks

.PHONY: all

all: $(DRIVER_EXES)

# Files

define cp_lapack_template =
$(1).f: dep/$(LAPACK)/SRC/$(1).f
	cp -f $$< $$@
endef
$(foreach f,$(LAPACKS),$(eval $(call cp_lapack_template,$(f))))

define cp_blas_template =
$(1).f: dep/$(LAPACK)/BLAS/SRC/$(1).f
	cp -f $$< $$@
endef
$(foreach f,$(BLASS),$(eval $(call cp_blas_template,$(f))))

# Rules

$(HOME)/Downloads/$(LAPACK).tgz:
	mkdir -p $(@D)
	cd $(@D)
	wget http://www.netlib.org/lapack/lapack-3.5.0.tgz

dep/$(LAPACK)/SRC/%.f: | dep/$(LAPACK)
	@

dep/$(LAPACK)/BLAS/SRC/%.f: | dep/$(LAPACK)
	@

dep/%: $(HOME)/Downloads/%.tgz
	mkdir -p $(@D)
	cd $(@D)
	tar -mxf $<

%.exe: % $(LBFGSB) $(BLAS_OS) $(LAPACK_OS) $(TIMER)
	$(FC) $(FFLAGS) $^ -o $@

%.o: %.f
	$(FC) $(FFLAGS) -c $< -o $@

%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@
