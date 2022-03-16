#!perl

use constant DIR => q{_posts/chapters};

my $md_files = get_files(DIR);

print @$md_files, "\n";

exit (0);

sub get_files {
    my $path    = shift;
    opendir my $dir, $path or die "Can't open directory $path: $!\n";
    my @files = grep /\.md$/, readdir($dir);
    closedir $dir;
    return \@files;
}