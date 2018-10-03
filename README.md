# crispy-giggle
Some scripts used to solve ctf challenges.

## SubBrute
Useful against subdomain wild card. You just need to exclude the status code (-x) or the content length (-xL) to avoid seeing default page.

Usage: `./subbrute.sh -d DOMAIN -D DICTIONARY -o OUTFILE -xL 1234`
