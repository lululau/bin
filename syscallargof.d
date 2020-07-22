#!/usr/sbin/dtrace -s
   /*
    * filebyproc.d - snoop files opened by process name. DTrace OneLiner.
    *
    * This is a DTrace OneLiner from the DTraceToolkit.
    *
    * 15-May-2005  Brendan Gregg   Created this.
    */

syscall::$1:entry /pid == $target && $2 ==  0 / { printf("%s %s", execname, copyinstr(arg0)); }
syscall::$1:entry /pid == $target && $2 ==  1 / { printf("%s %s", execname, copyinstr(arg1)); }
syscall::$1:entry /pid == $target && $2 ==  2 / { printf("%s %s", execname, copyinstr(arg2)); }
syscall::$1:entry /pid == $target && $2 ==  3 / { printf("%s %s", execname, copyinstr(arg3)); }
syscall::$1:entry /pid == $target && $2 ==  4 / { printf("%s %s", execname, copyinstr(arg4)); }
syscall::$1:entry /pid == $target && $2 ==  5 / { printf("%s %s", execname, copyinstr(arg5)); }
syscall::$1:entry /pid == $target && $2 ==  6 / { printf("%s %s", execname, copyinstr(arg6)); }
syscall::$1:entry /pid == $target && $2 ==  7 / { printf("%s %s", execname, copyinstr(arg7)); }
syscall::$1:entry /pid == $target && $2 ==  8 / { printf("%s %s", execname, copyinstr(arg8)); }
syscall::$1:entry /pid == $target && $2 ==  9 / { printf("%s %s", execname, copyinstr(arg9)); }
