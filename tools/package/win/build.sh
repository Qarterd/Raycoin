cur=$(cd $(dirname $0) && pwd)
root=$(cd "$cur/../../.." && pwd)
build="$root/build/package/win"
dist="$root/dist/package/win"
major=`grep -Po 'RAYCOIN_VERSION_MAJOR \K(\d+)' $root/viewer/src/RaycoinViewer.h | tr -d '\n'`
minor=`grep -Po 'RAYCOIN_VERSION_MINOR \K(\d+)' $root/viewer/src/RaycoinViewer.h | tr -d '\n'`
zip="Raycoin-$major.$minor.zip"
exe="Raycoin-$major.$minor-setup.exe"

echo "Removing old build files..."
rm -rf $build
rm -rf $dist
mkdir -p $build
mkdir -p $dist

echo ""
echo "Building package $dist/$zip..."
cp $root/build_msvc/Build/x64/Release/Output/RaycoinViewer/RaycoinViewer.exe $build
cp $root/build_msvc/Build/x64/Release/Output/raycoind/raycoind.exe $build
cp $root/build_msvc/Build/x64/Release/Output/raycoin-cli/raycoin-cli.exe $build
cp $root/build_msvc/Build/x64/Release/Output/raycoin-tx/raycoin-tx.exe $build
cp -r $cur/inc/* $build
pushd $build > /dev/null
zip -r $zip . -x@"$cur/zip-excludes.txt"
popd > /dev/null
mv -f $build/$zip $dist
echo "Created package $dist/$zip"

if [ -f "/mnt/c/Program Files (x86)/NSIS/makensis.exe" ]; then
    echo ""
    echo "Building package $dist/$exe..."
    pushd $cur > /dev/null
    powershell.exe -Command "& 'C:/Program Files (x86)/NSIS/makensis.exe' /DPRODUCT_VERSION=$major.$minor Raycoin.nsi"
    popd > /dev/null
    echo "Created package $dist/$exe"
fi

if [[ $(gpg --list-secret-keys) ]]; then
    echo ""
    echo "Signing packages..."
    pushd $dist > /dev/null
    if [ -f $zip ]; then
        gpg --detach-sign -a $zip
    fi
    if [ -f $exe ]; then
        gpg --detach-sign -a $exe
    fi
    popd > /dev/null
fi