#!/usr/bin/env bash

mkdir -p ./help
rm ./help/*
mkdir -p ./results
mkdir -p ./tmp/subcommands

# awscmd=(docker run --rm amazon/aws-cli:2.7.16)
# awscmd=(docker run --rm amazon/aws-cli:2.4.5)
awscmd=(aws)

"${awscmd[@]}" help | col -b > ./help/aws_help

"${awscmd[@]}" help topics > ./help/aws_help_topics

awk \
  '/AVAILABLE SERVICES/{flag=1; next} /SEE ALSO/{flag=0} flag { print $2 }' \
  ./help/aws_help \
  | grep -v '^$' \
  > ./tmp/services

echo -n "" > ./tmp/subcommands_list

echo ""
while read -r service ; do
  echo -e "\r\033[1A\033[0K${service}"
  "${awscmd[@]}" "${service}" help | col -b > "./help/aws_${service}_help"

  awk \
    '/AVAILABLE COMMANDS/{flag=1; next} /[A-Z]/{flag=0} flag { print $2 }' \
    "./help/aws_${service}_help" \
    | grep -v '^$' \
    > "./tmp/subcommands/${service}"

  awk '$0="'"${service}"' "$0' "./tmp/subcommands/${service}" >> ./tmp/subcommands_list  

done < ./tmp/services


cp ./tmp/subcommands_list ./results/service_commands

