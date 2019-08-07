#!/usr/bin/perl
#
# jiosnoop.pl - DTrace based utility to monitor JVM I/O activity
#
# (C) Copyright 2008 Georgios Gousios <gousiosg@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use DTrace;
use Getopt::Std;
use strict;

my $dtrace = << 'DS';
#pragma D option bufsize=50M
#pragma D option quiet

syscall::read:return
/pid==$1/
{
    printf("###JStack-read-start\n");
    jstack();
    printf("bytes/read.%d\n", arg0);
    printf("###JStack-read-end\n");
}

syscall::recv*:return
/pid==$1/
{
    printf("###JStack-recv-start\n");
    jstack();
    printf("bytes/recv.%d\n", arg0);
    printf("###JStack-recv-end\n");
}

syscall::write:entry 
/pid==$1/
{
    printf("###JStack-write-start\n");
    jstack();
    printf("bytes/write.%d\n", arg2);
    printf("###JStack-write-end\n");
}

syscall::send*:entry 
/pid==$1/
{
    printf("###JStack-send-start\n");
    jstack();
    printf("bytes/send.%d\n", arg2);
    printf("###JStack-send-end\n");
}

syscall::sendfile*:entry
/pid==$1/
{
    printf("###JStack-sendfile-start\n");
    jstack();
    printf("bytes/sendfile.%d\n", arg2);
    printf("###JStack-sendfile-end\n");
}
DS

#parse cmd-line options
my %options = ();
getopts( "p:f:", \%options );
my $pid = 0;
my $file;

#Make sure mode options are valid
unless ( defined( $pid = $options{p} ) || defined( $file = $options{f} )) {
  die usage();
}

#Run dtrace if the -p option is set
$dtrace =~ s/\$1/$pid/mg;

if ( $pid != 0 ) {
  $file = rundtrace($dtrace);  
}

my $key, my %count, my $pair;
my %stacks = parsestackdump($file, "^###JStack-.*-start", "^###JStack-.*-end");

foreach $key ( sort { $a <=> $b } ( keys %stacks ) ) {
  my $stackentry = getbottomjavastackentry( \%{ $stacks{$key} } );

  if ( not "" eq $stackentry ) {
    $pair = $stackentry . " " . getprobetrigger(\%{ $stacks{$key} });
    $count{$pair}++;
  }
}

printcolumnaligned( [hashtoarray(\%count)] );

#
# Print help
#
sub usage() {
  print << "END";
jiosnoop.pl - Aggregate and display I/O operation statistics
usage: ./jiosnoop.pl -p <pid> or ./jiosnoop.pl -f <file> <args>
Mode arguments:
     -p <pid>  Process id to connect to
     -f <file> Examine file (doesn't run dtrace)
Optional arguments:
     
END
}

