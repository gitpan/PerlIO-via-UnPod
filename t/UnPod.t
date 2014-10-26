BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
    unless (find PerlIO::Layer 'perlio') {
        print "1..0 # Skip: PerlIO not used\n";
        exit 0;
    }
}

use strict;
use warnings;
use Test::More tests => 13;

BEGIN { use_ok('PerlIO::via::UnPod') }

my $file = 'test.pm';
my $original = <<EOD;
This is source code
=head 1 HEADER

This is pod.

=over 2

=item an item

This is an item

=back

=cut

This is more source code.
EOD

my $src = <<EOD;
This is source code

This is more source code.
EOD

# Check pod when writing

ok(
 open( my $out,'>:via(PerlIO::via::UnPod)', $file ),
 "opening '$file' for writing"
);

ok( (print $out $original),		'print to file' );
ok( close( $out ),			'closing writing handle' );

# Check pod without layers

{
local $/ = undef;
ok( open( my $test,$file ),		'opening without layer' );
is( readline( $test ),$src,		'check source content' );
ok( close( $test ),			'close read test handle' );

ok( open( $test,">$file" ),		'creating without layer' );
print $test $original;
ok( close( $test ),			'close create test handle' );
}

# Check pod when reading

ok(
 open( my $in,'<:via(UnPod)', $file ),
 "opening '$file' for reading"
);
is( join( '',<$in> ),$src,		'read from file source' );
ok( close( $in ),			'close reading handle source' );

# Remove whatever we created now

ok( unlink( $file ),			"remove test file '$file'" );
