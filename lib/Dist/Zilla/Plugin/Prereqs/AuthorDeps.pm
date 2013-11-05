use v5.10;
use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::AuthorDeps;
# ABSTRACT: Add Dist::Zilla authordeps to META files as develop prereqs
# VERSION

use Moose;
use MooseX::Types::Moose qw( HashRef ArrayRef Str );

use Dist::Zilla::Util::AuthorDeps;
use Dist::Zilla;
use Path::Class;

with 'Dist::Zilla::Role::PrereqSource';

=attr phase

Phase for prereqs. Defaults to 'develop'.

=cut

has phase => (
    is      => ro  =>,
    isa     => Str,
    lazy    => 1,
    default => sub { 'develop' },
);

=attr relation

Relation type.  Defaults to 'requires'.

=cut

has relation => (
    is      => ro  =>,
    isa     => Str,
    lazy    => 1,
    default => sub { 'requires' },
);

=attr exclude

Module to exclude from prereqs.  May be specified multiple times.

=cut

has exclude => (
    is => ro =>,
    isa => ArrayRef [Str],
    lazy    => 1,
    default => sub { [] }
);

has _exclude_hash => (
    is => ro =>,
    isa => HashRef [Str],
    lazy    => 1,
    builder => '_build__exclude_hash'
);

sub _build__exclude_hash {
    my ( $self, ) = @_;
    return { map { ; $_ => 1 } @{ $self->exclude } };
}

sub mvp_multivalue_args { return qw(exclude) }

sub register_prereqs {
    my ($self)   = @_;
    my $zilla    = $self->zilla;
    my $phase    = $self->phase;
    my $relation = $self->relation;

    my $authordeps = Dist::Zilla::Util::AuthorDeps::extract_author_deps( dir('.') );

    for my $req (@$authordeps) {
        my ( $mod, $version ) = each %$req;
        next if $self->_exclude_hash->{$mod};
        $zilla->register_prereqs( { phase => $phase, type => $relation }, $mod, $version );
    }

    $zilla->register_prereqs( { phase => $phase, type => $relation },
        "Dist::Zilla", Dist::Zilla->VERSION, );

    return;
}

1;

=for Pod::Coverage mvp_multivalue_args register_prereqs

=head1 SYNOPSIS

    # in dist.ini:

    [Prereqs::AuthorDeps]

=head1 DESCRIPTION

This adds L<Dist::Zilla> itself and the result of the C<dzil authordeps>
command to the 'develop' phase prerequisite list.

=head1 SEE ALSO

L<Dist::Zilla::Plugin::Prereqs::Plugins> is similar but puts all plugins after
expanding any bundles into prerequisites, which is a much longer list that you
would get from C<dzil authordeps>.

=cut

# vim: ts=4 sts=4 sw=4 et:
