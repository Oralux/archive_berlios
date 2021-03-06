#! /bin/sh
# ----------------------------------------------------------------------------
# ttpport.sh
# $Id: ttpport.sh,v 1.3 2006/01/28 23:09:21 gcasse Exp $
# $Author: gcasse $
# Description: Installing ttpport, Brazilian portuguese phonetizer
# $Date: 2006/01/28 23:09:21 $ |
# $Revision: 1.3 $ |
# Copyright (C) 2004, 2005 Gilles Casse (gcasse@oralux.org)
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

####
# Installing the package in the current tree
InstallPackage()
{
    cd $INSTALL_PACKAGES/ttpport

    BIN="$BUILD/usr/local/bin"
    install -d $BIN
    install -m 555 ttpport $BIN

    DATA="$BUILD/usr/local/share/mbrola/ttpport"
    install -d $DATA
    install -m 444 dicton port_rules portuguese.dat $DATA

    DOC="$BUILD/usr/local/share/doc/ttpport"
    install -d $DOC
    install -m 444 readme.txt $DOC
}

####
case $1 in
    i|I)
	BUILD=""
        InstallPackage
        ;;
    b|B)
	# copy to the new Oralux tree
        InstallPackage
        ;;
    *)
        echo "I (install) or B(new tree) is expected"
        ;;
esac

exit 0

