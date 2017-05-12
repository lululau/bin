#!/usr/bin/env perl

my $bounds_string = join "", <>;
$bounds_string =~ s#\{#[#g;
$bounds_string =~ s#\}#]#g;
eval 'our $bounds = ' . $bounds_string;
my %apps = ();
for my $window (@$bounds) {
    my $app_name = $window->[0];
    my $window_title = $window->[1];
    my $window_position = $window->[2];
    my $window_size = $window->[3];
    if (not exists $apps{$app_name}) {
        $apps{$app_name} = [];
    }
    push @{$apps{$app_name}}, {
        title => $window_title, 
        position => $window_position, 
        size => $window_size
    }
}

my @osascript_strings = ();

for my $app_name (keys %apps) {
    my @script_strings_of_windows = ();
    my $windows = $apps{$app_name};
    for my $window (@$windows) {
        my $title = $window->{title};
        my $position = join ", ", @{$window->{position}};
        my $size = join ", ", @{$window->{size}};
        my $script = <<"FOE";
    try
            if title of w is "$title" then
                set position of w to {$position}
                set size of w to {$size}
            end if
        on error msg
        end try
FOE
        push @script_strings_of_windows, $script;
    }
    my $script_string_of_windows = join "\n", @script_strings_of_windows;
    my $script_string = <<"EOF";
try    
tell application "System Events" to tell process "$app_name"
    repeat with w in windows
    $script_string_of_windows
    end repeat
end tell    
on error msg
end try
EOF
    push @osascript_strings, $script_string;
}

print join("\n", @osascript_strings);
