:: Set Param
@ECHO OFF
@SETLOCAL

:: build Win x64
mkdir build
pushd build
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ..
nmake
popd

@ENDLOCAL
