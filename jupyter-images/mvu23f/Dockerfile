ARG BASE_CONTAINER=jupyter/scipy-notebook:latest
FROM $BASE_CONTAINER

LABEL maintainer="Unidata <support-gateway@unidata.ucar.edu>"

USER root

# ffmpeg for matplotlib anim & dvipng for latex labels
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-client wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD environment.yml /tmp

RUN conda install --quiet --yes \
    'conda-forge::nb_conda_kernels'  && \
    pip install --upgrade jupyterlab-git nbgitpuller  && \
    conda env update --name mvu-spring-2023 -f /tmp/environment.yml && \
    rm /tmp/environment.yml && \
    conda clean --all -f -y && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

####################################################
# Begin WRF ideal single column model compilation  #
####################################################

# Mostly following the steps outlined here:
# https://forum.mmm.ucar.edu/threads/full-wrf-and-wps-installation-example.12385/

# Dependencies missing from base image
RUN apt-get update && apt-get install --yes --no-install-recommends \
      gcc cpp gfortran g++ openmpi-bin libopenmpi-dev git csh perl file \
      make m4 curl vim ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Run tests recommended by MMM to confirm the fortran and c compilers are
# functioning as expected
# https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP1
RUN set -x && cd / && mkdir TESTS && cd TESTS && \
    curl https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar -O && \
    tar -xf Fortran_C_tests.tar && \
    gfortran TEST_1_fortran_only_fixed.f && ./a.out && \
    gfortran TEST_2_fortran_only_free.f90 && ./a.out && \
    gcc TEST_3_c_only.c && ./a.out && \
    gcc -c -m64 TEST_4_fortran+c_c.c && gfortran -c -m64 TEST_4_fortran+c_f.f90 && \
        gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o && ./a.out && \
    ./TEST_csh.csh && \
    ./TEST_perl.pl && \
    ./TEST_sh.sh && \
    cd / && rm -rf TESTS

# Test for other utilities
RUN which ar awk cat cp cut expr file grep gzip \
    head hostname ln ls make mkdir mv nm printf rm \
    sed sleep sort tar touch tr uname wc which m4

###########################################################
# Library and software versions
###########################################################

ENV NETCDF_VERSION=4.9.0 \
    NETCDF_F_VERSION=4.5.3 \
    WRF_VERSION=4.4.2

###########################################################
# Library and software PATHS
###########################################################

ENV DIR=/Build_WRF/LIBRARIES
ENV NETCDF=$DIR/netcdf
ENV PATH=$NETCDF/bin:$PATH \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF/lib:/$ZLIB_DIR/lib

RUN mkdir -p $DIR

###########################################################
# Compiler options
###########################################################

ENV CC=gcc \
    CXX=g++ \
    FC=gfortran \
    FCFLAGS=-m64 \
    F77=gfortran \
    FFLAGS=-m64 \
    LDFLAGS="-L$NETCDF/lib" \
    CPPFLAGS="-I$NETCDF/include"

###########################################################
# Build libraries
###########################################################

# netcdf-c
# BUILT WITH "--disable-netcdf4" SO WE COMPILE WRF WITH "NETCDF_classic"
RUN set -x && \
    cd / && mkdir -p Build_WRF/LIBRARIES && cd Build_WRF/LIBRARIES && \
    curl https://downloads.unidata.ucar.edu/netcdf-c/$NETCDF_VERSION/netcdf-c-$NETCDF_VERSION.tar.gz -O && \
    tar xzvf netcdf-c-$NETCDF_VERSION.tar.gz && \
    cd netcdf-c-$NETCDF_VERSION && \
    ./configure --enable-shared --disable-netcdf4 --disable-filter-testing --disable-dap --prefix=$DIR/netcdf && \
    make && make install && \
    cd .. && rm -rf netcdf-c-$NETCDF_VERSION*

# netcdf-f
RUN set -x && \
    export CPPFLAGS="-I$NETCDF/include -L$NETCDF/lib" && \
    cd /Build_WRF/LIBRARIES && \
    curl https://downloads.unidata.ucar.edu/netcdf-fortran/$NETCDF_F_VERSION/netcdf-fortran-$NETCDF_F_VERSION.tar.gz -O && \
    tar xzvf netcdf-fortran-$NETCDF_F_VERSION.tar.gz && \
    cd netcdf-fortran-$NETCDF_F_VERSION && \
    ./configure --prefix=$DIR/netcdf --disable-shared && \
    make && make install && \
    cd .. && rm -rf netcdf-fortran-$NETCDF_F_VERSION

###########################################################
# Verify libraries will play nice with the compilers used to build WRF
###########################################################

# https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP3

RUN set -x && \
    cd / && mkdir TESTS && cd TESTS && \
    curl https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar -O && \
    tar -xf Fortran_C_NETCDF_MPI_tests.tar && \
    cp ${NETCDF}/include/netcdf.inc . && \
    gfortran -c 01_fortran+c+netcdf_f.f && \
    gcc -c 01_fortran+c+netcdf_c.c && \
    gfortran 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf && \
    ./a.out && \
    mpif90 -c 02_fortran+c+netcdf+mpi_f.f && \
    mpicc -c 02_fortran+c+netcdf+mpi_c.c && \
    mpif90 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf && \
    mpirun --allow-run-as-root ./a.out && \
    cd / && rm -rf TESTS

###########################################################
# Actually build WRF
###########################################################

# At the moment, the configure script on the repo has an open issue regarding
# string comparison:
# https://github.com/wrf-model/WRF/issues/1817
COPY ./configure /tmp/configure
COPY ./Registry.EM_COMMON_edit /tmp/Registry.EM_COMMON_edit

# ./configure won't run with the options (33 and 0) if this variable is not set
ENV NETCDF_classic=1

# Piping the output of "echo '33\r0\r'" tells the script to configure WRF to
# compile for parallel using smpar and the GNU compilers we have been using (33)
# and to compile for no nesting (0)
RUN set -x && \
    cd /Build_WRF && \
    git clone --recurse-submodule https://github.com/wrf-model/WRF.git && \
    cd WRF && \
    git checkout release-v${WRF_VERSION} && \
    mv /tmp/Registry.EM_COMMON_edit ./Registry/Registry.EM_COMMON && \
    mv /tmp/configure ./configure && chmod u+x ./configure && \
    git diff && \
    echo '33\r0\r' | ./configure && \
    ./compile em_scm_xy > log.compile 2>&1 && \
    chown -R ${NB_UID}:${NB_GID} /Build_WRF/WRF

####################################################
# End WRF ideal single column model compilation    #
####################################################

# Download data at the end to reduce image size
ENV DATA /data/
RUN mkdir ${DATA} && \
    wget -O - https://www.radiativetransfer.org/misc/download/unstable/arts-cat-data-snapshot-arts-2.5.8.tar.gz | tar -xzf - -C ${DATA} && \
    fix-permissions "${DATA}"

USER $NB_UID

COPY Acknowledgements.ipynb /
COPY .condarc /
COPY .bashrc /
COPY .profile /

