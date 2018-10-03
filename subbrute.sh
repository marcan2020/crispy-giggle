#!/bin/bash

usage()
{
  echo "usage: $0 [-d DOMAIN -D DICTIONARY -o OUTFILE [-x code] [-xL length] | -h]"
}

if [[ $# -eq 0 ]] ; then
		usage
    exit 0
fi

while [ "$1" != "" ]; do
    case $1 in
        -d | --domain )         shift
                                domain=$1
                                ;;
        -D | --dictionary )    	shift
                                dictionary=$1
                                ;;
        -o | --outfile )    		shift
                                out=$1
                                ;;
        -x | --exclude-status ) shift
                                code=$1
                                ;;
        -o | --exclude-length ) shift
                                length=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z "$domain" ] ||  [ -z "$dictionary" ] || [ -z "$out" ]
then
  usage
  exit 1
fi

echo "Starting to bruteforce"

while read sub;
do
  curl http://$sub.$domain \
    -w '%{url_effective}\n%{scheme}/%{http_version} %{http_code}\nContent-Type: %{content_type}\nContent-Length: %{size_download}\nTime: %{time_total}\n\n' \
    -s -o /dev/null &
done < $dictionary > $out

if [ "$code" ]
then
  echo "Checking for other status codes"
  win=$(grep HTTP $out | grep -v $code | awk '{print $2}')
  echo Code found: $win
  for l in $win
  do
    grep 1.1\ $l $out -B1 -A3
  done
fi
 
if [ "$length" ]
then
  echo "Checking for other lengths"
  win=$(grep Length $out | grep -v $length | awk '{print $2}')
  echo Length found: $win
  for l in $win
  do
    grep Content-Length:\ $l $out -B3 -A1
  done
fi

echo "Done"


