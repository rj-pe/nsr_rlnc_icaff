# Classes for cryptanalysis of secure network coding.
- [PacketCombination](#packetcombination)
- [CodeBreakResults](#codebreakresults)

These classes provide an interface with which to carry out codebreaking on
network coded packets.

Multiple packets are combined with network coding. Combinations can be
separated using independent component analysis (ICA). The packet estimates
produced by ICA can be scaled to retrieve the original packet symbols using
an exhaustive search for a valid IPv4 checksum.


## [PacketCombination](../utilities/PacketCombination.m)

### Description:

This class provides an interface for performing operations on combinations of
network packets.

A PacketCombination object can be initialized using two or more packets.
Source packets can be combined, separated, and scaled using methods
provided in this class.

### Creating an instance:

The constructor takes five parameters:
* the prime base (P) for constructing a Galois field of the form, P^N,
* the degree (N) of the Galois field (determines the number of elements in the 
  field), [Note](#note)
* a unique string (can be used as an identifier for the object),
* the number of packets to be combined,
* the packets to be combined (see [Source](#source) for a detailed explanation
  of the required interface).

#### Note:
Any degree can be used, but the [ipv4 checksum](https://github.com/rj-pe/nsr_rlnc_icaff/blob/4ebd52a962029f9c4a0b26c6afd9088a941405a3/scalingAlgorithms/findScalingFactorByChecksum.m#L1)
method only supports GF(2^4).

### Available methods:

* [``Combine()``](https://github.com/rj-pe/nsr_rlnc_icaff/blob/4a15ac9e88c64435a3bb53a266b519cbd9a0f612/utilities/PacketCombination.m#L72)
  - Combine packets using 
  [``networkCoding()``](../utilities/networkCoding.m).

* [``Separate()``](https://github.com/rj-pe/nsr_rlnc_icaff/blob/4a15ac9e88c64435a3bb53a266b519cbd9a0f612/utilities/PacketCombination.m#L83) 
  - Separate packets using
  [``ica()``](../separation/AMERICA/ica.m).

* [``FindScalingFactors( scalingAlgorithmHandle )``](https://github.com/rj-pe/nsr_rlnc_icaff/blob/4a15ac9e88c64435a3bb53a266b519cbd9a0f612/utilities/PacketCombination.m#L97)
  - Find optimal scaling factors for ICA packet estimates.
  
  * The scaling factor algorithm parameter should be a function handle.
  Available functions:
    * [``findScalingFactorByChecksum``](../scalingAlgorithms/findScalingFactorByChecksum.m)
    * [``findMinMseScalingFactor``](../scalingAlgorithms/findMinMseScalingFactor.m)

* [``ComputeCodeBreakResults( metric )``](https://github.com/rj-pe/nsr_rlnc_icaff/blob/4a15ac9e88c64435a3bb53a266b519cbd9a0f612/utilities/PacketCombination.m#L125)
  - Calculates the rate of success of a codebreaking attempt by comparing the
   scaled estimated packet with the original. 
   
  * The metric parameter should be a function handle. Available functions:
      * [``immse()``](https://www.mathworks.com/help/images/ref/immse.html)
      * [``calculatePctBytesCorrect()``](../utilities/calculatePctBytesCorrect.m)

### Source

This section describes the format of the raw packets used to create a combination.
A source array should be created using the Matlab 
[``readmatrix``](https://www.mathworks.com/help/matlab/ref/readmatrix.html)
method directly on a text file containing raw packet data.

For help creating text files containing raw packet data,
see [pcap_processing](../utilities/pcap_processing/), which contains bash
scripts that can be used for extracting packet data from ``.pcap`` files.


## [CodeBreakResults](../utilities/CodeBreakResults.m)

### Description:

This class is used to store the results of codebreaking attacks.

### Creating an instance:

A Matlab object should be created before any codebreaking begins.


The constructor takes three parameters: 
* the number of packet combinations to be performed in the experiment, 
* the number of packets to be combined in each codebreaking attempt, and
* the name of the algorithm used for scaling the ICA estimates.

```Matlab
r = CodeBreakResults(numOfCombinations, numOfPacketsPerCombination, "checksum");
```

The algorithm name string is used to create a timestamped filename.

E.g. passing the string ``"checksum"``produces a filename:
``26-Aug-2019 11:06:28-checksum.xlsx``

### Storing results in program memory:

A codebreaking attempt can be saved to memory by calling ``LogResult()``.

Each attempt is stored as a row in a Matlab 
[Table](https://www.mathworks.com/help/matlab/ref/table.html) object.

```Matlab
r.LogResult(combinationObjectIndex, packetCombinationObject);
```

### Saving resuls to a file:

Experiment results can be saved to an Excel workbook file by calling 
``SaveToFile()``. 

```Matlab
r.SaveToFile()
```
