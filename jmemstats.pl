#!/usr/bin/perl
#
# jmemstats.pl - JVM memory management statistics
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
#pragma D option quiet
#pragma D option bufsize=50M
#pragma D option jstackstrsize=2048

hotspot$1:::object-alloc 
{
    this->str_ptr = (char*) copyin(arg1, arg2+1);
    this->str_ptr[arg2] = '\0';
    this->classname = (string) this->str_ptr;

    @class[this->classname] = count();
    @size[this->classname] = sum(args[3]);
    this->alloced_class = this->classname;
    printf("#JStack-start\n");
    jstack();
    printf("#JStack-end\n");
}

:::END
{
    printf("#Alloc objects:\n");
    printa(@class);
    printf("####\n");
    printf("#Alloc bytes:\n");
    printa(@size);
    printf("####\n");
}
DE

#parse cmd-line options
my %options = ();
getopts( "p:f:jabos", \%options );
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

#parse results
#%lines = parse($file, "#Alloc objects:", "####");
#%nojni = striparrayallocs(\%lines);
#%filtered = aggregateperpackage(\%nojni);
#printsortedhash(\%filtered, sortnvalues(\%filtered));

my %stacks;

%stacks = parsestackdump("out", "#JStack-start", "#JStack-end");

my $key, my $pair, my %count;

foreach $key ( sort { $a <=> $b } ( keys %stacks ) ) {
  my $stackentry = gettopjavastackentry( \%{ $stacks{$key} } );

  if ( not "" eq $stackentry ) {
    $count{$stackentry}++;
  }
}


printcolumnaligned( [hashtoarray(\%count)] );

#
# Print help
#
sub usage() {
  print << "END";
jmemstats.pl - Aggregate and display Java memory management statistics
usage: ./jmemstats -p <pid> 
Mode arguments:
     -p <pid>  Process id to connect to
     -f <file> Examine file (doesn't run dtrace)
Optional arguments:
    -j Include array allocations
    -a Aggregate results per package
    -b or -o Only show allocated bytes or allocated objects
    -r restrict output to the provided package name (regexp-based)
END
}

#
# Strip array allocations (starting with [)
#
sub striparrayallocs {
  my (%input) = %{ $_[0] };
  my (%stripped);

  my $key, my $value, my $package;
  while ( ( $key, $value ) = each %input ) {
    if ( not $key =~ m/\[/ ) {
      $stripped{$key} = $value;
    }
  }
  return %stripped;
}
