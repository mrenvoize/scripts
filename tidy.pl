#!/usr/bin/perl

use File::Slurp;
my $template = read_file(shift);

# replace TT snippets with <!-- snNN -->
my %snip = ();
my $id   = 0;
$template =~ s/ \[% (.*?) %\] / $snip{++$id} = $1; "<!-- sn$id -->" /gxse;

# run tidy
open my $tidy_fh, '|-', 'tidy -utf8  --preserve-entities y -indent -wrap 120 >tidy_out'
    or die;
print $tidy_fh $template;
close $tidy_fh;

# fix code back
my $template_tidied = read_file('tidy_out');
$template_tidied =~ s/%3C!--%20/<!-- /g;
$template_tidied =~ s/%20--%3E/ -->/g;
$template_tidied =~ s/&lt;!-- /<!-- /g;
$template_tidied =~ s/ --&gt;/ -->/g;
$template_tidied =~ s/<!-- sn(\d+) -->/ "[%$snip{$1}%]" /ge;

# print the result
print $template_tidied;
