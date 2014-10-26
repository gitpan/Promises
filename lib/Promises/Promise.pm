package Promises::Promise;
BEGIN {
  $Promises::Promise::AUTHORITY = 'cpan:STEVAN';
}
{
  $Promises::Promise::VERSION = '0.01';
}
# ABSTRACT: An implementation of Promises in Perl

use strict;
use warnings;

use Scalar::Util qw[ blessed ];
use Carp         qw[ confess ];

sub new {
    my ($class, $deferred) = @_;
    (blessed $deferred && $deferred->isa('Promises::Deferred'))
        || confess "You must supply an instance of Promises::Deferred";
    bless { 'deferred' => $deferred } => $class;
}

sub then    { (shift)->{'deferred'}->then( @_ ) }
sub status  { (shift)->{'deferred'}->status     }
sub result  { (shift)->{'deferred'}->result     }

1;

__END__

=pod

=head1 NAME

Promises::Promise - An implementation of Promises in Perl

=head1 VERSION

version 0.01

=head1 DESCRIPTION

Promise objects are typically not created by hand, they
are typically returned from the C<promise> method of
a L<Promises::Deferred> instance. It is best to think
of a L<Promises::Promise> instance as a handle for
L<Promises::Deferred> instances.

Most of the documentation here points back to the
documentation in the L<Promises::Deferred> module.

Additionally the L<Promises> module contains a long
explanation of how this module, and all it's components
are meant to work together.

=head1 METHODS

=over 4

=item C<new( $deferred )>

The constructor only takes one parameter and that is an
instance of L<Promises::Deferred> that you want this
object to proxy.

=item C<then( $callback, $error )>

This calls C<then> on the proxied L<Promises::Deferred> instance.

=item C<status>

This calls C<status> on the proxied L<Promises::Deferred> instance.

=item C<result>

This calls C<result> on the proxied L<Promises::Deferred> instance.

=back

=head1 AUTHOR

Stevan Little <stevan.little@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
