#!/bin/bash

# usage: ./noFilter input.pcap output.name
# extract the raw packet data from a pcapng file
# uses awk to filter packets which are shorter than 1000

tshark -r $1 -T jsonraw | egrep "frame_raw" |
awk 'length($0)>1000' | awk '{print $2}' |
sed 's/\[//' | sed 's/\"//' | sed 's/\"\,//' > $2
