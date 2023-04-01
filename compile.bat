@echo off

cls

if exist binary\ (
    rmdir /s /q "binary"
)

mkdir binary
cd binary

nvcc ..\kernel.cu ..\disk.cu ..\tarfg.cu --std=c++20 -o tarfg
start "" tarfg.exe

cd ..\
