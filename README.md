# elasticsearch
The script in this repository install elasticsearch and sets up to run in a production environment.  The script does not use multicast.

Among the things that the script does are:
- Gives permission to the `elastic` user to prevent memory from being swapped.
- Increases the number of open file descriptors that are allowed on the machine.
- Allows more limits on `mmap` counts
- Opens the ports that elastic might need to use on the iptables.
- Removes multicast from the elastic configuration.
- Installs the marvel plugin.
- Runs elasticsearch
