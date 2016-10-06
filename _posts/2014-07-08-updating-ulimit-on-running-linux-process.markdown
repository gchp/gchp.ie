---
layout: post
title: Updating ulimit on a running Linux process
date: '2014-07-08 21:53:24'
tags:
- linux
- debugging
permalink: /updating-ulimit-on-running-linux-process/
---

Today in $day_job I came across an interesting problem. We had a redis process which, after some heavy load testing, locked up and spiked the CPU at a constant 98%. I spent some time working with a colleague of mine in debugging this, and wanted to document some of what we covered in the hopes that it will come in handy in the future - perhaps for others, but mainly for myself.

We could see that the redis process was causing the CPU spike, by looking at the output of `top`. From here we were able to take the PID and attach to the process using `strace -p <pid>`. The output of this command gave us the indication that the issue was caused by too many open file descriptors. We confirmed this by comparing the output of:

```
$ ls -l /proc/<pid>/fd | wc -l
1025
```

which gives the number of open file descriptors (1025 in this case), with the output of:

```
$ grep -E "^Max open files" /proc/<pid>/limits
Max open files 1024 4096 files
```

Which showed that the maximum is indeed 1024.

So, now that we had diagnosed the issue, we needed a way to fix it without reloading or restarting the process. Using `ulimit -n 2048` would have increased the limit, but wouldn't have affected the running process, so that was out. Instead, we turned to the neckbeard favourite - gdb.

First, we created a gdb session attached to the PID we noted above:

```
gdb -p <pid>
```

Next, is where the magic happens.

```
(gdb) set $rlim = &{0ll, 0ll}

# the number 7 here is important.
(gdb) print getrlimit(7, $rlim)
$1 = 0

(gdb) print *$rlim
$2 = {1024, 4096}

# update the value retrieved above with getrlimit
(gdb) set *$rlim[0] = 1024*4
(gdb) print *$rlim
$3 = {4096, 4096}

(gdb) print setrlimit(7, $rlim)
$4 = 0
```

Let's see what this is actually doing here. First, we assign a value to the variable `$rlim`. This variable is an array containing the soft and hard limits for max open files. You can verify this by checking the output of:

```
$ cat /proc/<pid>/limits
Limit               Soft Limit  Hard Limit  Units 
Max cpu time        unlimited   unlimited   seconds
Max file size       unlimited   unlimited   bytes 
Max data size       unlimited   unlimited   bytes
Max stack size      10485760    unlimited   bytes
Max core file size  0           unlimited   bytes
Max resident set    unlimited   unlimited   bytes
Max processes       3515        3515        processe
Max open files      1024        4096        files   
Max locked memory   65536       65536       bytes   
Max address space   unlimited   unlimited   bytes  
Max file locks      unlimited   unlimited   locks  
Max pending signals 3515        3515        signals
Max msgqueue size   819200      819200      bytes
Max nice priority   0           0           
Max realtime priority 0         0                    
Max realtime timeout  unlimited unlimited   us

```

If you count the items in this output (zero indexed), you will see that the 7th item down lists "Max open files". Looking across this row you will see that the soft limit is 1024, and the hard limit is 4096, which are the values contained in the `$rlim`  variable in gdb.

Once we have those values, we set the first item in the variable (soft limit) to be 4096 (1024 * 4). We then use `setrlimit` to apply this change back to the running process, again passing in the number 7 as the target limit in this case.

If we detach from gdb at this point, and check the output of `top` again, we see that the CPU usage for this process has dropped to less that 1%, and that the outout of `strace` no longer shows the open file descriptors error. And we didn't have to restart or reload the process!

**Note:** this change will only apply to the current process. You will probably want to make this change permanent using `ulimit -n <limit>`, or similar depending on what you actually want to do here.

---

I know there are other ways of achieving this, probably. Some people mention using `prlimit` to do this, however we weren't able to locate this command, and installing `util-linux-ng` package didn't provide it as some said it would. This worked for us though, and I'm happy with that!

If you have another solution for this [let me know on twitter!](http://twitter.com/greg_chapple)
