# Builds three .deb packages, for x86 (i386) and x86_64 (amd64) and arm (arm)
# These packages include a manpage, an icon, and a desktop file.

function getControl() {
echo Section: editors
echo Package: micro
echo Version: $2
echo Priority: extra
echo Maintainer: \"Zachary Yedidia\" \<zyedidia@gmail.com\>
echo Standards-Version: 3.9.8
echo Homepage: https://micro-editor.github.io/
echo Architecture: $1
echo "Description: A modern and intuitive terminal-based text editor"
echo " This package contains a modern alternative to other terminal-based"
echo " Editors. It is easy to Use, highly customizable via themes and plugins"
echo " and it supports mouse input"
}

function installFiles() {
  TO="$1/$2/usr/share/doc/micro/"
  mkdir -p $TO
  mkdir -p "$1/$2/usr/share/man/man1/"
  mkdir -p "$1/$2/usr/share/applications/"
  mkdir -p "$1/$2/usr/share/icons/"
  cp ../LICENSE $TO
  cp ../LICENSE-THIRD-PARTY $TO
  cp ../README.md $TO
  gzip -c ../assets/packaging/micro.1 > $1/$2/usr/share/man/man1/micro.1.gz
  cp ../assets/packaging/micro.desktop $1/$2/usr/share/applications/
  cp ../assets/logo.svg $1/$2/usr/share/icons/micro.svg
}

version=$1
if [ "$1" == "" ]
  then
    version=$(go run build-version.go | tr "-" ".")
fi
echo "Building packages for Version '$version'"
echo "Compiling."
./compile-linux.sh $version
       
echo "Beginning package build process"
        
PKGPATH="../packages/deb"
        
rm -fr $PKGPATH
mkdir -p $PKGPATH/amd64/DEBIAN/
mkdir -p $PKGPATH/i386/DEBIAN/
mkdir -p $PKGPATH/arm/DEBIAN/

getControl "amd64" "$version" > $PKGPATH/amd64/DEBIAN/control
tar -xzf "../binaries/micro-$version-linux64.tar.gz" "micro-$version/micro"
mkdir -p $PKGPATH/amd64/usr/local/bin/
mv "micro-$version/micro" "$PKGPATH/amd64/usr/local/bin/"
        
getControl "i386" "$version" > $PKGPATH/i386/DEBIAN/control
tar -xzf "../binaries/micro-$version-linux32.tar.gz" "micro-$version/micro"
mkdir -p $PKGPATH/i386/usr/local/bin/
mv "micro-$version/micro" "$PKGPATH/i386/usr/local/bin/"
        
getControl "arm" "$version" > $PKGPATH/arm/DEBIAN/control
tar -xzf "../binaries/micro-$version-linux-arm.tar.gz" "micro-$version/micro"
mkdir -p $PKGPATH/arm/usr/local/bin
mv "micro-$version/micro" "$PKGPATH/arm/usr/local/bin"
        
rm -rf "micro-$version"
        
installFiles $PKGPATH "amd64"
installFiles $PKGPATH "i386"
installFiles $PKGPATH "arm"
        
dpkg -b "$PKGPATH/amd64/" "../packages/micro-$version-amd64.deb"
dpkg -b "$PKGPATH/i386/" "../packages/micro-$version-i386.deb"
dpkg -b "$PKGPATH/arm/" "../packages/micro-$version-arm.deb"
