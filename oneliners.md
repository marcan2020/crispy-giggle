# One Liners

## Extract nmap ports
`cat ./nmap/full.nmap | grep open | cut -d'/' -f1 > ports`

## nc everywhere
`while read p; do echo $p; echo test | nc domain.tld $p; done < ports`
