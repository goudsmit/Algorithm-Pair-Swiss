#!/usr/bin/perl -w

use Test::Simple tests => 4;

use Algorithm::Pair::Swiss;

my $pairer = Algorithm::Pair::Swiss->new(1,2,3,4);
ok( defined $pairer,				'instantiated');
ok( $pairer->isa('Algorithm::Pair::Swiss'),	'proper class');

my @parties = $pairer->parties;
ok( @parties == 4,				'instantiation parties assigned properly');

$pairer->parties(1,2,3);
@parties = $pairer->parties;
ok( @parties == 3,				'parties method assigned properly');

