#!/usr/bin/env perl

use Getopt::Long;
use Spreadsheet::XLSX;
my ($opt_help, $opt_deli, $opt_table_id, $opt_columns);

GetOptions(
  "h" => \$opt_help,
  "help" => \$opt_help,
  "d=s" => \$opt_deli,
  "s=s" => \$opt_sheet,
  "sheet=s" => \$opt_sheet,
  "r=s" => \$opt_rows,
  "rows=s" => \$opt_rows,
  "c=s" => \$opt_columns,
  "columns=s" => \$opt_columns
);

my @rows = ();
my @columns = ();

sub useage {
  my $useage =<<"EOF";

useage: $0 -d 列分隔符 -s sheet名称 -r 行 -c 列 <.xlsx file>

  本工具是将指定的 .xlsx 文件中的表格按照指定的列分隔符按行列格式打印到标准输出.

  如果没有指定列分隔符，则使用\"\\t\".

  默认输出第一个 sheet 的全部内容，可以使用 -s 选项指定要输出的 sheet 的名称。

  可以通过 -r 选项指定要输出的行，通过 -c 选项指定要输出的列。

  例如输出 “客户列表” sheet 页中的第 3 行至第 10 行，第 A列以及第 E 列至第 L 列的内容，分隔符使用逗号:

  $0 -s 客户列表 -r 3-10 -c A,E-L -d, file.xlsx

EOF

}

print useage() and exit if $opt_help;


my $file_name = $ARGV[0];
my $excel = Spreadsheet::XLSX -> new ($ARGV[0]);

my $delimeter = "\t";
$delimeter = $opt_deli if $opt_deli;
$delimeter =~ s/\\t/\t/g;
$delimeter =~ s/\\n/\n/g;

if(defined($opt_rows)) {
  for (split /,/, $opt_rows) {
    if (/^\d+$/) {
      push @rows, $_;
    } elsif (/^\d+-\d+$/) {
      my ($start, $end) = split /-/, $_;
      for ($start .. $end) {
        push @rows, $_;
      }
    }
  }
}

if(defined($opt_columns)) {
  for (split /,/, $opt_columns) {
    if (/^[A-Z]+$/) {
      push @columns, $_;
    } elsif (/^[A-Z]+-[A-Z]+$/) {
      my ($start, $end) = split /-/, $_;
      for ($start .. $end) {
        push @columns, $_;
      }
    }
  }
}

sub letter2digits {
    my $letter = shift;
    $letter = reverse $letter;
    my $start = 64;
    $start = 96 if $letter =~ m/[a-z]/;
    my $result = 0;
    my $i = 0;
    for ($letter =~ /(.)/g) {
        $result += ((ord($_) - $start) * 26 ** $i);
        $i++;
    }
    return $result;
}

$opt_sheet = $excel->{Worksheet}->[0]->{Name} unless (defined($opt_sheet));

for my $sheet (@{$excel -> {Worksheet}}) {
    next if $sheet->{Name} ne $opt_sheet;
    if (@rows) {
        @rows = map {$_ - 1} @rows;
    } else {
        @rows = ($sheet->{MinRow} .. ($sheet->{MaxRow} || $sheet->{MinRow}));
    }
    if (@columns) {
        @columns = map {letter2digits($_) - 1} @columns;
    } else {
        @columns = ($sheet->{MinCol} .. ($sheet->{MaxCol} || $sheet->{MinCol}));
    }
    for my $row (@rows) {
        print join $delimeter, map {$_->{Val}} @{$sheet->{Cells}[$row]}[@columns];
        print "\n";
    }
}
