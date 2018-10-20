# crispy-giggle
Some scripts used to solve ctf challenges.

## SubBrute
Useful against subdomain wild card. You just need to exclude the status code (-x) or the content length (-xL) to avoid seeing default page.

Usage: `./subbrute.sh -d DOMAIN -D DICTIONARY -o OUTFILE -xL 1234`

## msed
Extract a regex matching group with sed.

The default is the first matching group:
```
$ echo test123abc | ./msed test(.*)abc
123
```

For multiple matching group use:
```
$ echo test123abc456def | ./msed "test(.*)abc(.*)def" 2
456
```

## autoblue
Generate payload to exploit EternalBlue in x86 by default. Add the option `-x64` to have the 64 bits version.

Usage: `./autoblue.sh -lhost YOUR_IP -lport LISTENING_PORT`
