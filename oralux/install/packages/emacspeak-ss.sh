#! /bin/sh
# ----------------------------------------------------------------------------
# emacspeak.sh
# $Id: emacspeak-ss.sh,v 1.2 2005/01/30 21:43:51 gcasse Exp $
# $Author: gcasse $
# Description: Installing emacspeak. Thanks to the Nath's howto: 
# emacspeak-dtk-soft-debinst-howto.htm
# $Date: 2005/01/30 21:43:51 $ |
# $Revision: 1.2 $ |
# Copyright (C) 2003, 2004, 2005 Gilles Casse (gcasse@oralux.org)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# ----------------------------------------------------------------------------
####
source ../oralux.conf
EMACSPEAK_SS=emacspeak-ss-1.9.1.tar.gz
ARCH_EMACSPEAK_SS=$ARCH/$EMACSPEAK_SS
LISTE="accent apollo braillenspeak ciber doubletalk pchablado"

####
# Replacing the original KNOPPIX file from a customized one
substituteFile()
{
    file=$1
    dir=$2
    # If the new file "dir/file" (either coming from Knoppix or already updated for Oralux) isn't equal to the saved one.
    comp=`diff $INSTALL_PACKAGES/knoppix/$file.sav $dir/$file |wc -l|awk '{print $1}'`
    # we have to compare it with the previously updated Oralux file
    # If they are distinct, we are sure the new file has to replace the saved file.
    # and then be updated with the oralux customization
    # 
    comp2=`diff $INSTALL_PACKAGES/knoppix/$file $dir/$file |wc -l|awk '{print $1}'`
    if [ "$comp" != "0" ] && [ "$comp2" != "0" ]; then
        echo "the new KNOPPIX file $dir/$file is different from our original one $INSTALL_PACKAGES/knoppix/$file.sav"
        echo "--> Press q, to quit (so that the following operations are achieved:"
	echo "1. The saved file $INSTALL_PACKAGES/knoppix/$file.sav might be equal to the new file $dir/$file from Knoppix."
	echo "2. Our customized file $INSTALL_PACKAGES/knoppix/$file might be updated with the new features from $dir/$file)."
	echo "--> Press any other key to jump this stage"
	read a

	if [ "$a" == "q" ] || [ "$a" == "Q" ]; then
	    exit 1
	fi  
    elif [ "$comp2" != "0" ]; then
        echo "the new KNOPPIX file $dir/$file is different from our customized one $INSTALL_PACKAGES/knoppix/$file"
        echo "--> Press q, to quit (so that the following operations are achieved:"
	echo "The customized file $INSTALL_PACKAGES/knoppix/$file will take in account the new features from $dir/$file)."
	echo "--> Press any other key to jump this stage"
	read a

	if [ "$a" == "q" ] || [ "$a" == "Q" ]; then
	    exit 1
	fi 
    fi
}

####
# Installing the package in the current tree
InstallPackage()
{
    cd /tmp
    rm -rf emacspeak*

    if [ $method = "TARGZ" ]
        then
        tar -zxvf $ARCH_EMACSPEAK_SS
    fi
    if [ $method = "TARBZ2" ]
        then
        tar -jxvf $ARCH_EMACSPEAK_SS
    fi

    # Installing emacspeak-ss
    cd /tmp/emacspeak*; ./configure; make; make install

    cd /usr/share/emacs/site-lisp/emacspeak/servers

    for i in  $LISTE
      do 
      a=`head -1 $i`
      if [ '#!/usr/bin/tcl' != "$a" ]; then
	  echo "$i: Adding tcl command line"
	  echo '#!/usr/bin/tcl' > fic.tmp
	  cat $i >> fic.tmp
	  mv fic.tmp $i
      fi
      chmod a+x $i   
    done

    # Clearing /tmp
    cd /tmp
    rm -rf emacspeak*
}

####
# Adding the package to the new Oralux tree
Copy2Oralux()
{
    # Installing emacspeak-ss
    a=`echo $ARCH_EMACSPEAK_SS|grep tar.gz|wc -c|sed "s/ //g"`
    if [ $a != 0 ]
        then
        method="TARGZ"
    fi

    a=`echo $ARCH_EMACSPEAK_SS|grep tar.bz2|wc -c|sed "s/ //g"`
    if [ $a != 0 ]
        then
        method="TARBZ2"
    fi

    cd $BUILD/var/tmp
    rm -rf emacspeak*

    if [ $method = "TARGZ" ]
        then
        tar -zxvf $ARCH_EMACSPEAK_SS
    fi
    if [ $method = "TARBZ2" ]
        then
        tar -jxvf $ARCH_EMACSPEAK_SS
    fi

    chroot $BUILD bash -c "cd /tmp/emacspeak*; ./configure; make; make install"

    cd $BUILD/usr/share/emacs/site-lisp/emacspeak/servers

    for i in  $LISTE
      do 
      a=`head -1 $i`
      if [ '#!/usr/bin/tcl' != "$a" ]; then
	  echo "$i: Adding tcl command line"
	  echo '#!/usr/bin/tcl' > fic.tmp
	  cat $i >> fic.tmp
	  mv fic.tmp $i
      fi
      chmod a+x $i   
    done

    # Clearing /tmp
    cd $BUILD/var/tmp
    rm -rf emacspeak*
}

if [ ! -e $ARCH_EMACSPEAK_SS ]
    then
    cd $ARCH
    echo "Downloading $EMACSPEAK"
    wget -nd http://fr.rpmfind.net/linux/blinux/emacspeak/blinux/$EMACSPEAK_SS
fi

case $1 in
    i|I)
        InstallPackage
        ;;
    b|B)
        Copy2Oralux
        ;;
    *)
        echo "I (install) or B(new tree) is expected"
        ;;
esac

exit 0
