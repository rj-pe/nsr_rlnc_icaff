#!/bin/bash

# usage: ./noFilter input.pcap output.name
# extract only the raw packet bytes from a pcap
# each line in the output represents a packet

tshark -r $1 -T jsonraw | egrep "frame_raw" | awk '{print $2}' | sed 's/\[//' |
sed 's/\"//' | sed 's/\"\,//' > $2
