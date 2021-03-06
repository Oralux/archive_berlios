#! /bin/sh
# ----------------------------------------------------------------------------
# ircha_tts.sh
# $Id: ircha_tts.sh,v 1.2 2005/12/10 22:35:07 gcasse Exp $
# $Author: gcasse $
# Description: Installing ircha_tts, Spanish phonetizer
# $Date: 2005/12/10 22:35:07 $ |
# $Revision: 1.2 $ |
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
    install -d $BUILD/usr/local/bin
    install -m 555 ircha_tts/ircha_tts.pl $BUILD/usr/local/bin
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

