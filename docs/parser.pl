#!/usr/bin/env perl

use constant DIR => q{_posts/chapters};
use constant CONTENT_DIR => q{content};

&main;

exit (0);

sub main {
    my $files = get_files(DIR);
    foreach (sort @$files) {
        print "$_\n";
        parse($_);
    }
}

sub parse {
    my $file    = $_[0];

    my $infile  = DIR . '/' . $file;
    my $enfile  = sprintf q{%s/_en/%s}, CONTENT_DIR, $file;
    my $vifile  = sprintf q{%s/_vi/%s}, CONTENT_DIR, $file;

    open my $fh, $infile or qq{Cannot open $infile: $!};
    open my $en, ">$enfile"  or qq{Cannot open $enfile: $1};
    open my $vi, ">$vifile"  or qq{Cannot open $vifile: $1};

    my $out     = $en;
    my $section = 0;
    my $end     = 0;
    my $start   = 1;

    while (<$fh>) {
        if ($end) {
            $end = 0;
        }

        if (/^##\s(\d+)\./) {
            $section = $1;
        } elsif (/^##\s/) {
            $section = -1;
        }

        if ($section == 1 && $start == 2) {
            print $out qq{layout: day\n};
            print $out qq{---\n\n};
            $start = 0;

            print $out "\n{% include logo.html info=page %}\n\n";
            print $out "{% include day_head.html info=page %}\n\n";
        }

        if ($section == 10 || $section == -1) {
            my $header = find_header($_);
            if ($header ne $_) {
                $section = 0;
                $end = 1;
                $start = 1;
                $out = $vi;
            }
        }

        if ($section == 0) {
            next if /^\s*$/;
            $_ = find_header($_);

            if ($start == 1) {
                print $out qq{---\n};
                $start++;
            }
        }

        print $out $_;
    }

    close $fh;
    close $en;
    close $vi;
}

sub find_header {
    my $line        = $_[0];
    $line =~ s/^(Tuần|week):?\s+(.*)$/week: $2/i and return $line;
    $line =~ s/^(Ngày|day):?\s+(.*)$/day: $2/i and return $line;

    if ($line =~ s/^(\S+ đề|title):?\s+(.*)$/title: $2/i
     || $line =~ s/^(Kinh thánh|bible):?\s+(.*)$/bible: $2/i) {
        $line =~ s/'/’/g;
        $line =~ s/^([^:]+: )(.*)$/$1'$2'/;
    }
    return $line;
}

sub get_files {
    my $path    = shift;
    opendir my $dir, $path or die "Can't open directory $path: $!\n";
    my @files = grep /\.md$/, readdir($dir);
    closedir $dir;
    return \@files;
}
