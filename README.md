# Yashme (PMRace) on Vagrant (Artifact Evaluation)

This artifact contains a vagrant repository that downloads and compiles the source code for PMRace (a plugin for Jaaru), its companion compiler pass, and benchmarks.  The artifact enables users to reproduce the bugs that are found by PMRace in [PMDK](https://github.com/uci-plrg/jaaru-pmdk), [RECIPE](https://github.com/uci-plrg/nvm-benchmarks/tree/vagrant/RECIPE), [Memcached](https://github.com/uci-plrg/memcached), and [Redis](https://github.com/uci-plrg/redis) as well as performance results to compare PMRace with Jaaru, the underlying persistent memory model checker.

Our workflow has four primary parts: (1) creating a virtual machine and installing dependencies needed to reproduce our results, (2) downloading the source code of PMRace and the benchmarks and building them, (3) providing the parameters corresponding to each bug to reproduce the bugs, and (4) running the benchmarks to compare PMRace with the Jaaru (The underlying model checker). After the experiment, the corresponding output files are generated for each bug and each performance measurement.

## Step-by-step guidance

1. In order for Vagrant to run, we should first make sure that the [VT-d option for virtualization is enabled in BIOS](https://docs.fedoraproject.org/en-US/Fedora/13/html/Virtualization_Guide/sect-Virtualization-Troubleshooting-Enabling_Intel_VT_and_AMD_V_virtualization_hardware_extensions_in_BIOS.html).

2. Then, you need to download and install Vagrant, if we do not have Vagrant ready on our machine. Also, it is required to install *vagrant-disksize* plugin for vagrant to specify the size of the disk needed for the evaluation.

```
    $ sudo apt update
    $ sudo apt-get install virtualbox
    $ sudo apt-get install vagrant
    $ vagrant plugin install vagrant-disksize
```

**Note:** If you encountered `conflicting dependencies fog-core (~> 1.43.0) and fog-core (= 1.45.0)` error in installing `vagrant-disksize` plugin, you need to use the most recent version of vagrant:

```
    $ wget -c https://releases.hashicorp.com/vagrant/2.0.3/vagrant_2.0.3_x86_64.deb
    $ sudo dpkg -i vagrant_2.0.3_x86_64.deb
    # Now install vagrant-disksize
    $ vagrant plugin install vagrant-disksize
```

3. Clone this repository into the local machine and go to the *pmrace-vagrant* folder:

```
    $ git clone https://github.com/uci-plrg/pmrace-vagrant.git
    $ cd pmrace-vagrant
```

4. Use the following command to set up the virtual machine. Then, our scripts automatically downloads the source code for PMRace, its LLVM pass, and PMDK, Redis, Memcached, and RECIPE. Then, it builds them and sets them up to be used. Finally, it copies the running script in the *home* directory of the virtual machine. 

```
    pmrace-vagrant $ vagrant up
```

We highly recommend to use [tmux](https://github.com/tmux/tmux/wiki/Installing) for running long-running commands if you don't have access to a reliable network.

**Note:** If you encountered `SSL certificate problem: certificate has expired` error, you can configure vagrant to install the ubuntu image without using SSL:
```
    $ vagrant box add ubuntu/bionic64 --insecure
    $ vagrant up
```

5. After everything is set up, the virtual machine is up and the user can ssh to it by using the following command:

```
    pmrace-vagrant $ vagrant ssh
```

6. After logging in into the VM, there are eight script files in the 'home' directory. These scripts automatically run the corresponding benchmark and save the results in the *~/results* direcotory:

```
    vagrant@ubuntu-bionic:~$ ls
    llvm-project         memcached-server.sh  perf.sh  pmcheck-vmem  pmdk-races.sh    redis-client.sh  setup.sh
    memcached-client.sh  nvm-benchmarks       pmcheck  pmdk          recipe-races.sh  redis-server.sh  testcase
```

7. To generate performance results for Redis, Memcached, PMDK, and Recipe benchmark, run *perf.sh* script. When it finishes successfully, it generates the corresponding performance results in *~/results/performance* directory. **performance.out** contains average execution time for 100 random executions of the benchmarks on PMRace and Jaaru. In addition, it contains the number of bugs found w/ or w/o prefix-based expansion algorithm. We highly recommend to use [tmux](https://github.com/tmux/tmux/wiki/Installing) for generating performance results.

```
    vagrant@ubuntu-bionic:~$ ./perf.sh
    vagrant@ubuntu-bionic:~$ vim ~/results/performance/performance.out
```

8. Run *recipe-races.sh* script to regenerate persistency races in RECIPE that found by PMRace. Then, it generates the corresponding log file for each benchmark in *~/results/recipe* directory. Files with the pattern of `BENCHMARK-races.log` contain the persistency races.

```
    vagrant@ubuntu-bionic:~$ ./recipe-races.sh
    vagrant@ubuntu-bionic:~$ ls ~/results/recipe/
    CCEH-races.log     FAST_FAIR-races.log     P-ART-races.log     P-BwTree-races.log     P-CLHT-x1-races.log   P-Masstree-x1-races.log
    CCEH-x1-races.log  FAST_FAIR-x1-races.log  P-ART-x1-races.log  P-BwTree-x1-races.log  P-Masstree-races.log  logs
```

Each of these files contain writes that are prone to persistency races followed by the read that can observe the persistency race. PMRace reports the exact location (i.e., line number and character number of the variable) for each read and write:
```
    vagrant@ubuntu-bionic:~$ cat ~/results/recipe/P-BwTree-races.log
  [Warning] ERROR: PersistRace: Persistency Race ====> write: Seq_number=343     Execution=0x7f5f5172b3f0        Address=0x7f6272341fe8          Location=src/bwtree.h:572:10 @[ src/bwtree.h:8628:15 @[ src/bwtree.h:8924:9 @[ src/bwtree.h:8945:49 @[ /usr/lib/gcc/x86_64-linux-gnu/7.5.0/../../../../include/c++/7.5.0/bits/invoke.h:60:14 @[ /usr/lib/gcc/x86_64-linux-gnu/7.5.0/../../../../include/c++/7.5.0/bits/invoke.h:95:14 @[ /usr/lib/gcc/x86_64-linux-gnu/7.5.0/../../../../include/c++/7.5.0/thread:234:13 @[ /usr/lib/gcc/x86_64-linux-gnu/7.5.0/../../../../include/c++/7.5.0/thread:243:11 @[ /usr/lib/gcc/x86_64-linux-gnu/7.5.0/../../../../include/c++/7.5.0/thread:186:13 ] ] ] ] ] ] ] ] >>>>>>> Read by: Address=0x7f6272341fe8          Location=src/bwtree.h:613:12 @[ src/bwtree.h:587:49 @[ src/bwtree.h:8615:15 @[ src/bwtree.h:7785:45 ] ] ]
```

9. Run *pmdk-races.sh* script to regenerate bugs in PMDK that found by PMRace. Then, it generates the corresponding log file for each benchmark in *~/results/pmdk* directory.

```
    vagrant@ubuntu-bionic:~$ ./pmdk-bugs.sh
    vagrant@ubuntu-bionic:~$ ls ~/results/pmdk/
    btree-races.log  ctree-races.log  logs
```

10. Open two terminals. Run *redis-server.sh* in one terminal first, and then in the other terminal run *redis-client.sh*. 

```
    # Server terminal
    vagrant@ubuntu-bionic:~$ ./redis-server.sh
    
    ...
    
    *******************************************************************
    Pre-Crash Execution 1
    *******************************************************************

    ...

    *******************************************************************
    Post-Crash Execution 1
    *******************************************************************
```

```
   # Client terminal
   vagrant@ubuntu-bionic:~$ ./redis-client.sh

   ...
   
   Press any keys to start Post-rash client..
```

once you see *Post-Crash Execution 1* in the server's terminal, press any keys in the client's terminal to start the post-crash test case. Once you press any keys, so many persistency races are reported in the server's terminal. Rerun the *redis-client.sh* one more time after server prints "Pre-Crash Execution 2" and press any keys once you see the message in the client's terminal to gracefully finish all executions in the server.

11. Similar to Redis, open two terminals. Run *memcached-server.sh* in one terminal first, and then in the other terminal run *memcached-client.sh*.

```
    # Server terminal
    vagrant@ubuntu-bionic:~$ ./memcached-server.sh

    ...

    *******************************************************************
    Pre-Crash Execution 1
    *******************************************************************

    ...

    *******************************************************************
    Post-Crash Execution 1
    *******************************************************************
```

```
   # Client terminal
   vagrant@ubuntu-bionic:~$ ./memcached-client.sh

   ...

   Press any keys to start Post-rash client..
```

once you see *Post-Crash Execution 1* in the server's terminal, press any keys in the client's terminal to start the post-crash test case. Once you press any keys, so many persistency races are reported in the server's terminal. Rerun
 the *memcached-client.sh* one more time after server prints "Pre-Crash Execution 2" and press any keys once you see the message in the client's terminal to gracefully finish all executions in the server.

## Disclaimer

We make no warranties that PMRace is free of errors. Please read the paper and the README file so that you understand the tools capabilities, limitations, and how to use it.

## Contact

Please feel free to contact us for more information. Bug reports are welcome, and we are happy to hear from our users and how PMRace help them to find persistency races in their programs. Please contact Hamed Gorjiara at [hgorjiar@uci.edu](mailto:hgorjiar@uci.edu), Harry Xu at [harryxu@g.ucla.edu](mailto:harryxu@g.ucla.edu), or Brian Demsky at [bdemsky@uci.edu](mailto:bdemsky@uci.edu) for any questions about PMRace.

## Copyright

Copyright &copy; 2022 Regents of the University of California. All rights reserved
