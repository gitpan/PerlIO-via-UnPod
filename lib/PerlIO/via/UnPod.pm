package PerlIO::via::UnPod;

# Set the version info
# Make sure we do things by the book from now on

$VERSION = '0.02';
use strict;

# Satisfy -require-

1;

#-----------------------------------------------------------------------

# Subroutines for standard Perl features

#-----------------------------------------------------------------------
#  IN: 1 class to bless with
#      2 mode string (ignored)
#      3 file handle of PerlIO layer below (ignored)
# OUT: 1 blessed object

sub PUSHED { 

# Die now if strange mode
# Create the object with the right fields

#    die "Can only read or write with removing pod" unless $_[1] =~ m#^[rw]$#;
    bless {insrc => 1},$_[0];
} #PUSHED

#-----------------------------------------------------------------------
#  IN: 1 instantiated object
#      2 handle to read from
# OUT: 1 processed string (if any)

sub FILL {

# Create local copy of $_
# While there are lines to be read from the handle
#  If we're in what looks like a pod line
#   Set flag depending on whether we are at the end of pod
#  Elseif we're now in source
#   Return the line
# Return indicating end reached

    local( $_ );
    while (defined( $_ = readline( $_[1] ) )) {
	if (m#^=[a-zA-Z]#) {
            $_[0]->{'insrc'} = m#^=cut#;
        } elsif ($_[0]->{'insrc'}) {
            return $_;
        }
    }
    undef;
} #FILL

#-----------------------------------------------------------------------
#  IN: 1 instantiated object
#      2 buffer to be written
#      3 handle to write to
# OUT: 1 number of bytes written

sub WRITE {

# For all of the lines in this bunch (includes delimiter at end)
#  If it looks like a pod line
#   Set flag whether we're at the end of pod
#  Elseif we're in source now
#   Print the line, return now if failed
# Return total number of octets handled

    foreach (split( m#(?<=$/)#,$_[1] )) {
	if (m#^=[a-zA-Z]#) {
            $_[0]->{'insrc'} = m#^=cut#;
        } elsif ($_[0]->{'insrc'}) {
            return -1 unless print {$_[2]} $_;
        }
    }
    length( $_[1] );
} #WRITE

#-----------------------------------------------------------------------

__END__

=head1 NAME

PerlIO::via::UnPod - PerlIO layer for removing plain old documentation

=head1 SYNOPSIS

 use PerlIO::via::UnPod;

 open( my $in,'<:via(UnPod)','file.pm' )
  or die "Can't open file.pm for reading: $!\n";
 
 open( my $out,'>:via(UnPod)','file.pm' )
  or die "Can't open file.pm for writing: $!\n";

=head1 DESCRIPTION

This module implements a PerlIO layer that removes plain old documentation
(pod) on input B<and> on output.  It is intended as a development tool only,
but may have uses outside of development.

=head1 EXAMPLES

Here are some examples, some may even be useful.

=head2 Source only filter

A script that only lets source code pass.

 #!/usr/bin/perl
 use PerlIO::via::UnPod;
 binmode( STDIN,':via(UnPod)' ); # could also be STDOUT
 print while <STDIN>;

=head1 SEE ALSO

L<PerlIO::via>, L<PerlIO::via::Pod> and any other PerlIO::via modules on CPAN.

=head1 COPYRIGHT

Copyright (c) 2002 Elizabeth Mattijsen.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
