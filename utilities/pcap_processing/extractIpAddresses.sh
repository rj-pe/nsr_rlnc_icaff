#!/bin/bash

# filter out the ip address numbers from a wireshark list of resolved addresses

cat ipAddressesList |  awk {'print $4'} | sed 's/,//' | sed 's/\./ /g' | sed 's/[0-9]/ & /g' > ipList
