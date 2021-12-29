#!/usr/sbin/dtrace -s
/*
 * creatbyproc.d - file creat()s by process name. DTrace OneLiner.
 *
 * This is a DTrace OneLiner from the DTraceToolkit.
 *
 * 11-Jun-2005	Brendan Gregg	Created this.
 */

syscall::read:entry,
syscall::read_nocancel:entry,
syscall::readv_nocancel:entry,
syscall::pread_nocancel:entry
/pid == $target || progenyof($target)/
{
        @calls[pid, execname, arg0, "R"] = sum(arg0);
}

syscall::write:entry,
syscall::writev:entry,
syscall::pwrite:entry,
syscall::write_nocancel:entry,
syscall::writev_nocancel:entry,
syscall::pwrite_nocancel:entry
/pid == $target || progenyof($target)/
{
        @calls[pid, execname, arg0, "W"] = sum(arg0);
}

dtrace:::END
{
        printf("%6s %-24s %4s %4s %8s\n", "PID", "CMD", "FD", "DIR", "COUNT");
        printa("%6d %-24s %d %4s %@8d\n", @calls);
}

