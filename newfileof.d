#!/usr/sbin/dtrace -s
/*
 * creatbyproc.d - file creat()s by process name. DTrace OneLiner.
 *
 * This is a DTrace OneLiner from the DTraceToolkit.
 *
 * 11-Jun-2005	Brendan Gregg	Created this.
 */

syscall::open:entry 
/(pid == $target || progenyof($target)) && ( arg1 == (0x0200 | 0x0400 | 0x0001) || arg1 == (0x01000601 | 0x0201 | 0x0400 | 0x0001))  /* O_CREAT | O_TRUNC | O_WRONLY */ /
{ 
  if (copyinstr(arg0) != "/dev/null" ) {
    printf("%d %s %s", pid, execname, copyinstr(arg0)); 
  }
}
