# $Id: Best.pm,v 1.10 2005/01/24 02:21:46 reid Exp $

#   Algorithm::Pair::Swiss.pm
#
#   Copyright (C) 2006 Gilion Goudsmit ggoudsmit@shebang.nl
#
#   This library is free software; you can redistribute it and/or modify it
#   under the same terms as Perl itself, either Perl version 5.8.5 or, at your
#   option, any later version of Perl 5 you may have available.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#   or FITNESS FOR A PARTICULAR PURPOSE.
#

=head1 NAME

Algorithm::Pair::Swiss - Perl module to select pairings (designed for 
Magic: The Gathering tournaments).

=head1 SYNOPSIS

    use Algorithm::Pair::Swiss;

    my $pairer = Algorithm::Pair::Swiss->new;

    $pairer->parties(1,2,3,4);

    @round_1 = $pairer->pairs;

    $pairer->exclude(@round_1);

    @round_2 = $pairer->pairs;

=head1 DESCRIPTION

This module was created as an alternative for Algorithm::Pair::Best, which
probably offers more control over the pairings, in particular regarding
ensuring the highest overal quality of pairings. Algorithm::Pair::Swiss is
sort of dumb in this regard, but uses a slightly more intuitive interface.

After creating an Algorithm::Pair::Swiss-E<gt>B<new> object, B<parties> a list
of parties (players or teams) to be paired.  B<exclude> can be used to indicate
which pairs shouldn't be generated (probably because they've already been
paired in an earlier round).        

The list of parties is sorted and pairer tries to find a set of pairs that
respects the exclude list, and tries to pair the parties that appear first
in the sorted list with each other most aggresively.

To influence the sort order, use objects as parties and overload either the
B<cmp> or B<0+> operators in the object class to sort as desired.

Algorithm::Pair::Swiss-E<gt>B<pairs> explores the parties and returns the first
pairing solution which satisfies the excludes. Because it doesn't exhaustively
try all possible solutions, performance is generally pretty reasonable.

For a large number of parties, if is generally easy to find a non-excluded pair,
and for a smaller number of parties traversal of the possible pairs is done
reasonably fast.

This module uses the parties as keys in a hash, and uses the empty string ('')
as a special case in this same hash. For this reason, please observe the
following restrictions regarding your party values:
 - make sure it is defined
 - make sure it is defined when stringified
 - make sure each is a non-empty string when stringified
 - make sure each is unique when stringified

All the restrictions on the stringifications are compatible with the perl's
default stringification of objects, and should be safe for any stringification
which returns a unique party-identifier (for instance a primary key from a
Class::DBI object).        

=cut


package Algorithm::Pair::Swiss;
use strict;
use warnings;
require 5.001;

use version; our $VERSION = sprintf(q{0.1.%6d} => q{$Revision: 1$} =~ /(\d+)/g);

use Tie::IxHash 1.21;

######################################################
#
#       Public methods
#
#####################################################

=head1 METHODS

=over 4

=item my $pairer = B<Algorithm::Pair::Swiss-E<gt>new>(?parties?)

A B<new> Algorithm::Pair::Swiss object is used to generate pairings.
Optionally parties can be given when instantiating the object. This is
the same as using the B<parties> method.

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->parties(@_) if @_;
    return $self;
}    

=item = $pairer-E<gt>B<parties>( @parties )

Provides the pairer with a complete list of all individuals that can
be paired. If no parties are specified, it returns the sorted list
of all parties. This allows you to use this method to extract 'rankings'
if you happen to have implemented a B<cmp> operation overload in the
class you parties belong to.

=cut

sub parties {
    my $self = shift;
    return sort @{$self->{parties}} unless @_;
    $self->{parties} = [ @_ ];
    for my $i (@{$self->{parties}}) { $self->{exclude}->{$i}={} }
}

=item @pairs = $pairer-E<gt>B<pairs>

Returns the best pairings found as a list of arrayref's, each containing
one pair of parties.

=cut

sub pairs {    
    my $self = shift;
    my @pairs = _pairs($self->parties,$self->{exclude});
    return @pairs;
}    

=item $pair-E<gt>B<exclude>(@pairs)

Excludes the given pairs from further pairing. The @pairs array
should consist of a list of references to arrays, each containing the two
parties of that pair. This means you can easily feed it the output of
a previous call to $pair-E<gt>B<pairs>. The selection given is added
to previously excluded pairs.

=cut

sub exclude {
    my $self = shift;
    for my $pair (@_) {
	my ($x,$y) = @$pair;
	    $self->{exclude}->{$x}->{$y||''} = 1 if $x;
	    $self->{exclude}->{$y}->{$x||''} = 1 if $y;
    }	
}    

sub _pairs {
    my ($unpaired,$exclude) = @_;
    my @unpaired = @$unpaired;
    my $p1 = shift @unpaired;
    if(@unpaired==0) {					            # single player left
    	return if exists $exclude->{$p1}->{''};		# already had a bye before
	    return [$p1,undef];	            			# return a bye
    }
    for my $p2 (@unpaired) {
    	next if exists $exclude->{$p1}->{$p2};		# already paired
       	next if exists $exclude->{$p2}->{$p1};		# already paired
    	return [$p1,$p2] if @unpaired==1;		    # last pair!
    	@unpaired = grep {$_ ne $p2} @unpaired;		# this pair could work
    	my @pairs = _pairs(\@unpaired,$exclude);	# so try to pair the rest
    	next unless @pairs;				            # no luck
    	return [$p1,$p2],@pairs;			        # yay! return the resultset
    }
    return;
}    

1;

__END__

=back

=head1 BUGS

Currently the algorithm doesn't seem to handle an odd number of parties
properly. This is on the top of my list; the module should return a pair
of a single party with 'undef' ([$p,undef]) for the lowest ranked party
that doesn't have an exclude with 'undef' yet. Lowest ranked would be
determined by being last in the list of parties after sorting.

=head1 SEE ALSO

=over 0

=item o Algorithm::Pair::Best

The B<Algorithm::Pair::Best> module if you need more control
over your pairings.

=back

=head1 AUTHOR

Gilion Goudsmit, E<lt>ggoudsmit@shebang.nl<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Gilion Goudsmit

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.

=cut

