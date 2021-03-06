#! /bin/sh
# ----------------------------------------------------------------------------
# end.sh
# $Id: end.sh,v 1.9 2006/01/30 22:49:38 gcasse Exp $
# $Author: gcasse $
# Description: This script must be the last one to call
# $Date: 2006/01/30 22:49:38 $ |
# $Revision: 1.9 $ |
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

####
# Installing the package in the current tree
InstallPackage()
{
    echo "obsolete"
}

####
# Adding the package to the new Oralux tree
Copy2Oralux()
{
#     rm $NEW_ORALUX/KNOPPIX/rawrite*
    
# #    cp $INSTALL_PACKAGES/fdimage/fdimage.exe $NEW_ORALUX/KNOPPIX/
#     cp $INSTALL_PACKAGES/knoppix/mkfloppy.bat $NEW_ORALUX/KNOPPIX/

#     cp $INSTALL_PACKAGES/knoblind/knoblind.bat $NEW_ORALUX/KNOPPIX/
#     cp $INSTALL_PACKAGES/knoblind/rawrite.exe $NEW_ORALUX/KNOPPIX/
#     cp $INSTALL_PACKAGES/knoblind/callrw.bat $NEW_ORALUX/KNOPPIX/

#     # Doc
#     mkdir $BUILD/usr/share/doc/rawrite
#     cp -pR $INSTALL_PACKAGES/knoblind/rawrite3.doc $BUILD/usr/share/doc/rawrite

    # Customizing the boot stage
    # To be done juste once!
    ISOLINUX=$NEW_ORALUX/boot/isolinux
    cp $INSTALL_PACKAGES/knoppix/boot.msg $ISOLINUX
    cp $INSTALL_PACKAGES/knoppix/f2 $ISOLINUX
    cp $INSTALL_PACKAGES/knoppix/f3 $ISOLINUX
    rm $ISOLINUX/logo.16

    # The persistent home and the saved config will be searched
    # vga=normal (instead of vga=791)
    cp $ISOLINUX/isolinux.cfg /tmp

    sed -e "s/lang=us/myconfig=scan home=scan lang=us/g" -e "s/vga=791/screen=800x600 vga=normal/g" /tmp/isolinux.cfg > $ISOLINUX/isolinux.cfg

    rm /tmp/isolinux.cfg




    echo "unalias -a" >> $BUILD/etc/profile

    echo "if [ ! -f \$HOME/.bashrc ]; then" >> $BUILD/etc/profile
    echo "cp /etc/bashrc \$HOME/.bashrc" >> $BUILD/etc/profile
    echo "chmod 644 \$HOME/.bashrc" >> $BUILD/etc/profile
    echo "fi" >> $BUILD/etc/profile
    echo "source \$HOME/.bashrc" >> $BUILD/etc/profile

    echo "if [ ! -f \$HOME/.emacs ]; then" >> $BUILD/etc/profile
    echo "cp /usr/share/oralux/install/packages/emacspeak/.emacs \$HOME" >> $BUILD/etc/profile
    echo "chmod 644 \$HOME/.emacs" >> $BUILD/etc/profile
    echo "fi" >> $BUILD/etc/profile

    echo "if [ ! -d \$HOME/.emacs.d ]; then" >> $BUILD/etc/profile
    echo "mkdir \$HOME/.emacs.d" >> $BUILD/etc/profile
    echo "chmod 700 \$HOME/.emacs.d" >> $BUILD/etc/profile
    echo "fi" >> $BUILD/etc/profile

    echo "if [ ! -d \$HOME/.links ]; then" >> $BUILD/etc/profile
    echo "mkdir \$HOME/.links" >> $BUILD/etc/profile
    echo "chmod 700 \$HOME/.links" >> $BUILD/etc/profile
    echo "cp /usr/share/oralux/install/packages/links/*.cfg \$HOME/.links" >> $BUILD/etc/profile
    echo "chmod 644 \$HOME/.links/*.cfg" >> $BUILD/etc/profile
    echo "fi" >> $BUILD/etc/profile

    echo "if [ ! -d \$HOME/.ne ]; then" >> $BUILD/etc/profile
    echo "mkdir \$HOME/.ne" >> $BUILD/etc/profile
    echo "chmod 700 \$HOME/.ne" >> $BUILD/etc/profile
    # defaultDap instead of default#ap since mkisofs -no-bak removes it.
    echo "cp /usr/share/oralux/install/packages/ne/.defaultDap \$HOME/.ne/.default\#ap" >> $BUILD/etc/profile
    echo "fi" >> $BUILD/etc/profile

    echo "alias ..='cd ..'" >> $BUILD/etc/profile
    echo "alias which='type -path'" >> $BUILD/etc/profile
    echo "alias where='type -all'" >> $BUILD/etc/profile
    echo "alias ll='ls -l'" >> $BUILD/etc/profile
    echo "alias l='ls -a'" >> $BUILD/etc/profile
    echo "alias rm='rm -i'" >> $BUILD/etc/profile
    echo "alias mv='mv -i'" >> $BUILD/etc/profile
    echo "alias cp='cp -i'" >> $BUILD/etc/profile
    echo "alias la='ls -la'" >> $BUILD/etc/profile

    echo "#This is very KNOPPIX-specific" >> $BUILD/etc/profile
    echo "alias su='sudo su'"  >> $BUILD/etc/profile
    echo "#" >> $BUILD/etc/profile

    echo "export EDITOR=ne"  >> $BUILD/etc/profile
    echo "export PAGER=w3m"  >> $BUILD/etc/profile

    echo "/usr/bin/oralux.sh" >> $BUILD/etc/profile
    rm -rf $BUILD/tmp/*
    echo > $BUILD/etc/resolv.conf

    # Customizing the KNOPPIX directory
     cd $NEW_ORALUX/KNOPPIX
    rm *.jpg
    rm *.gif
    rm *.htm*
    rm KNOPPIX-FAQ*.txt
    rm md5sums
    rm README_Security.txt
    rm knoppix-cheatcodes.txt

    cd $INSTALL_PACKAGES/cdrom
    tar --dereference --exclude CVS --exclude "*.sav" --exclude "*~" -cf - * | tar -C $NEW_ORALUX/KNOPPIX -xf -

    # Html files
    cd $ORALUX/doc/htm
    tar --dereference --exclude CVS --exclude "*.sav" --exclude "*~" -cf - * | tar -C $NEW_ORALUX/KNOPPIX -xf -

    cp $ORALUX/MBROLA.htm $NEW_ORALUX/KNOPPIX
}

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
