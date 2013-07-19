package Dist::Zilla::Plugin::CoalescePod;
# ABSTRACT: merge .pod files into their .pm counterparts

use strict;
use warnings;

use Moose;

with 'Dist::Zilla::Role::FileMunger';

sub munge_file {
    my ( $self, $file ) = @_;

    # only look under /lib
    return unless $file->name =~ m#^lib/.*\.pm$#;

    ( my $podname = $file->name ) =~ s/\.pm$/.pod/;

    my ( $podfile ) = grep { $_->name eq $podname } 
                           @{ $self->zilla->files } or return;

   $self->log( "merged " . $podfile->name . " into " . $file->name );

    my @content = split /(^__DATA__$)/m, $file->content;

    # inject the pod
    splice @content, 1, 0, $podfile->content;

    $file->content( join '', @content );

    $self->zilla->prune_file($podfile);
}

1;
