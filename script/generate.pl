#!/usr/bin/env perl

use strict;

use CPANPLUS::Backend;

use lib::abs '../lib';
use Acme::CPANAuthors::AnyEvent;

my $cb = CPANPLUS::Backend->new();

my %dist;
my %author;
my %authors;

for my $mod ( $cb->search( type => 'name', allow => [ qr/AnyEvent/ ], verbose => 1 ) ) {
    ( my $distname = $mod->package ) =~ s{[\d_\.-]+\.tar\.gz$}{};
    $dist{$distname}++;
    my $aut = $mod->author->cpanid;
    $author{ $aut } = $mod->author->author;
    $authors{ $aut };# ||= [];
    push @{ $authors{ $aut }{$distname} }, $mod->name;
}

my $file = do { open my $f, '<', lib::abs::path('.').'/AnyEvent.tt'; local $/; <$f> };

my $reg = '';
my $pod = '';
my $ver = sprintf "%0.2f", $Acme::CPANAuthors::AnyEvent::VERSION + 0.01;

$pod .= sprintf "Now B<%d> AnyEvent CPAN authors:\n\n", 0+keys %authors;
$pod .= sprintf "    %-11s=> '%s', # Main AnyEvent author ;) \n\n", MLEHMANN => $author{MLEHMANN};
$reg .= sprintf "\t%-11s=> '%s', # Main AnyEvent author ;)\n", MLEHMANN => $author{MLEHMANN};

for ( sort keys %authors ) {
    next if $_ eq 'MLEHMANN'; # ;)
    $reg .= sprintf "\t%-11s=> '%s',\n",$_, $author{$_};
    $pod .= sprintf "    %-11s=> '%s',\n",$_, $author{$_};
}

$pod .= sprintf "\nAnd we written B<%d> distros", 0+keys %dist;

$file =~ s{ %REGISTER% }{use Acme::CPANAuthors::Register(\n$reg);}sx;
$file =~ s{ %VERSION%  }{$ver}sgx;
$file =~ s{ %AUTHORS%  }{$pod}sgx;

print $file;

#my @res = $cb->search( type => 'distribution', allow => [ qr/AnyEvent/ ], verbose => 1 );
#warn Dump \@res;
