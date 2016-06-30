# !/bin/bash
# *******************************<+>***************************************
#
# File        : boost.sh
#
# Description : Boost librairies build instructions.
#
# Project     : Rtone
#
# *************************************************************************
# Contributors :
#    Version 1.00: 13/08/2014, Author: spastor, Original hack  
#
# *************************************************************************
# (c) Copyright 2014 Rtone
#     All Rights Reserved.
# *********************************<+>*************************************

PLATFORM=$(uname -m)
BOOST_DIR=

# default values
INSTALL_DIR=$HOME/work/3rdParties/$PLATFORM/usr

load_config() {
    local TEMPFILE="/tmp/boost$$.tmp"
    cat $1 | awk 'BEGIN { FS="="; } \
    /^\#/ { print; } \
    !/^\#/ { if (NF == 2) { n = $1; gsub(/[^A-Za-z0-9_]/,"_",n); print n "=\"" $2 "\""; } else { print; } }' \
    >$TEMPFILE
    source $TEMPFILE
    rm $TEMPFILE > /dev/null 2> /dev/null
    return 0
}

set_boost_dir() {
    BOOST_DIR=boost_$(echo $BOOST_VERSION | tr . _)
}

show_config() {
  echo "Boost..:"
  echo "  Version..: $BOOST_VERSION"
  echo "  Tarball..: $BOOST_TARBALL"
  echo "  Uri......: $BOOST_URI"
  echo "  Libs.....: $BOOST_LIBS"
  echo "  Boost dir: $BOOST_DIR"
  echo
  echo "  Install dir..: $INSTALL_DIR"
  echo
  sleep 5
}

do_clean() {
  rm -rf $BOOST_DIR
  rm -f $DOWNLOAD
}

do_download() {
  if [ ! -d $BOOST_DIR ]; then
    if [ ! -e $BOOST_TARBALL ]; then
        echo "Downloading $BOOST_TARBALL"
        wget -P $BOOST_URI -O $BOOST_TARBALL
    fi
    echo "Extracting $BOOST_TARBALL to $BOOST_DIR"
    tar -xvf $BOOST_TARBALL
  fi  
}

do_configure() {
  echo "Running Boost boostrap.sh script"
  ./bootstrap.sh
}

do_make() {
  echo "Running bjam"
  ./bjam toolset=gcc cxxflags=-fPIC $BOOST_LIBS --layout=system stage
}

do_install() {
  echo "Creating directory: ${INSTALL_DIR}"
  mkdir -p $INSTALL_DIR

  echo "Moving Boost libraries to ${INSTALL_DIR}"
  mv stage/lib $INSTALL_DIR

  echo "Creating directory: ${INSTALL_DIR}/include"
  mkdir -p $INSTALL_DIR/include

  echo "Copying ${BOOST_DIR}/boost to ${INSTALL_DIR}/include"
  cp -rf boost $INSTALL_DIR/include
}

do_make_boost() {
    load_config $1
    set_boost_dir
    show_config
    
    do_download     && \
    cd  $BOOST_DIR  && \
    do_configure    && \
    do_make

    do_install && \
    cd .. && \
    rm -rf $BOOST_DIR
}

do_print_usage() {
    echo
    echo "Usage:"

    echo -n "  $0 "       
    echo '"boost configuration file"    Build and install boost thrid parties with the parameters contained in the configuration file'

    echo "  $0 --help                        Print help"

    echo
    echo "ex:"
    echo " $0 boost_1.54.0                   Build and install boost 1.54.0"
    echo
}

#----------------------------------------------------------------------------//#
# main
#----------------------------------------------------------------------------//#
if [ $# -eq 1 ]
then
    [ "$1" = "--help" ] && do_print_usage && exit 0
    do_make_boost $1
else
    do_print_usage
    exit 1
fi
