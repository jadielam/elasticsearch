# elasticsearch
The script in this repository install elasticsearch and sets up to run in a production environment.  The script does not use multicast.

Among the things that the script does are:
1. Giving permission to the `elastic` user to prevent memory from being swapped.
2. Increasing the number of open file descriptors that are allowed on the machine.
3. Allow more limits on `mmap` counts
4. Opens the ports that elastic might need to use on the iptables.
5. Removes multicast from the elastic configuration.
6. Installs the marvel plugin.
7. Runs elasticsearch
