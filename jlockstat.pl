#!/usr/bin/perl
#
# jlockstat.pl - DTrace based JVM to native locking information
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
#

use DTrace;
use Getopt::Std;
use strict;

my $dtrace = << 'DE';
#pragma D option bufsize=50M

plockstat$1:::rw-acquire 
{
    @lock[tid] = count();
    printf("#JStack-start:\n");
    jstack();
    printf("#JStack-end:\n");
}

plockstat$1:::mutex-acquire 
/arg1 == 0/
{
    @mutex[tid] = count();
    printf("#JStack-start:\n");
    jstack();
    printf("#JStack-end:\n");
}

:::END
{
    printf("#Locks:\n");
    printa(@lock);
    printf("####\n");
    printf("#Mutexes:\n");
    printa(@mutex);
    printf("####\n");
}
DE

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

my %stacks = parsestackdump( $file , "#JStack-start", "#JStack-end" );

my $key, my $pair, my %count;

foreach $key ( sort { $a <=> $b } ( keys %stacks ) ) {
  my $stackentry = gettopjavastackentry( \%{ $stacks{$key} } );

  if ( not "" eq $stackentry ) {
    $pair = $stackentry . " " . getnativebeforemutex( $stacks{$key} );
    $count{$pair}++;
  }
}

printcolumnaligned( [hashtoarray(\%count)] );

#
# Print help
#
sub usage() {
  print << "END";
jlockstat.pl - Aggregate and display Java-to-native locking statistics
usage: ./jlockstat.pl -p <pid> or ./jlockstat.pl -f <file> <args>
Mode arguments:
     -p <pid>  Process id to connect to
     -f <file> Examine file (doesn't run dtrace)
Optional arguments:   
END
}

#
# Convetion is that the stack frame begins with a mutex operation
#
sub getnativebeforemutex {
  my (%stack) = %{ $_[0] };
  my $key;

  foreach $key ( sort { $a <=> $b } ( keys %stack ) ) {

    #Parse native methods only
    if ( defined $stack{$key}[2] ) {

      #First not mutex related op, return it
      if ( $stack{$key}[1] !~ m/mutex/ ) {
        return $stack{$key}[1];
      }
    }
  }
}

