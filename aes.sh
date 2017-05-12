#!/bin/bash

################################################################
#                                                              #
# AES encrypt/decrypt util for Pisces@miaozhen                 #
#   using 128-ECB cipher and 64 bits length key and empty iv   #
#                                                              #
################################################################


function print_usage () {
    cat <<EOF >&2
Usage: $(basename $0) <-e/-d> -k <AES Key> message_file

  $(basename $0) is an util for encrypt/decrypt message using AES-128-ECB cypher with empty iv, 
  which size of key must be 64 bits. <AES Key> must be based64 encoded string of 64 bits octets, 
  In Common You'll use value of STDB.api_info.ApiSecret as <AES Key>.

Options:

  -e    encrypt message_file, this is the DEFAULT option.
  -d    decrypt message_file.
  
EOF
}


OPTION_STR=":edk:"
OPT_ENCRYPT=""
OPT_DECRYPT=""
OPT_KEY=""


while getopts "$OPTION_STR" opt
do
    case "$opt" in
	d  )  OPT_DECRYPT="TRUE";;
	e  )  OPT_ENCRYPT="TRUE";;
	k  )  OPT_KEY=$OPTARG;;
    esac
done

if [[ $OPT_ENCRYPT == "TRUE" && $OPT_DECRYPT == "TRUE" ]]
then
    echo "Error: you could not specify \"-d\" and \"-e\" in the meantime." >&2
    print_usage
    exit 65
elif [[ -z $OPT_DECRYPT ]]
then
    OPT_ENCRYPT=TRUE
    OPT_DECRYPT=FALSE
fi

if [[ -z $OPT_KEY ]]
then
    echo "Error: <AES Key> must be specified." >&2
    print_usage
    exit 65
elif ! echo "$OPT_KEY" | grep -q '[=+/0-9a-zA-Z]\{24\}'
then
    echo "Error: <AES Key> must be base64 encoded UUID, you may find a valiad <AES Key> in STDB.api_info.ApiSecret" >&2
    print_usage
    exit 65
fi

shift $((OPTIND - 1))

BASE64_DECODE_FLAG=""
if echo "$OPTYPE" | grep -qi "linux\|gnu"
then
    BASE64_DECODE_FLAG="-d"
else
    BASE64_DECODE_FLAG="-D"
fi

AES_KEY=$(echo -n "$OPT_KEY" | base64 $BASE64_DECODE_FLAG | od -An -tx1 | perl -pe 's#\s##g')

OPENSSL_CMD="openssl"
OPENSSL_OPTS="enc -aes-128-ecb -a  -K $AES_KEY "
if [[ $OPT_DECRYPT == TRUE ]]
then
    OPENSSL_OPTS="$OPENSSL_OPTS -d "
fi

if [[ $OPT_DECRYPT == TRUE ]]
then
    cat $1 | perl -pe 's#.{64}#$&\n#g if length($_) > 64 && substr($_, 64, 1) ne "\n"' | $OPENSSL_CMD $OPENSSL_OPTS -iv ''| perl -pe ""
else
    cat $1 | $OPENSSL_CMD $OPENSSL_OPTS -iv ''
fi
