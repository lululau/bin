#!/usr/sbin/dtrace -s
/*
 * creatbyproc.d - file creat()s by process name. DTrace OneLiner.
 *
 * This is a DTrace OneLiner from the DTraceToolkit.
 *
 * 11-Jun-2005	Brendan Gregg	Created this.
 */

syscall::open:entry 
/pid == $target || progenyof($target)/
{ 
  if (copyinstr(arg0) != "/dev/null" ) {
    printf("%d %s %s", pid, execname, copyinstr(arg0)); 
  }
}
