package Promises::Deferred::Mojo;
BEGIN {
  $Promises::Deferred::Mojo::AUTHORITY = 'cpan:STEVAN';
}
# ABSTRACT: An implementation of Promises in Perl
$Promises::Deferred::Mojo::VERSION = '0.94';
use strict;
use warnings;

use Mojo::IOLoop;

use parent 'Promises::Deferred';

sub _notify_backend {
    my ( $self, $callbacks, $result ) = @_;
    Mojo::IOLoop->timer(0,sub {
        foreach my $cb (@$callbacks) {
            $cb->(@$result);
        }
    });
}

1;

__END__

=pod

=head1 NAME

Promises::Deferred::Mojo - An implementation of Promises in Perl

=head1 VERSION

version 0.94

=head1 SYNOPSIS

    use Promises backend => ['Mojo'], qw[ deferred collect ];

    # ... everything else is the same

=head1 DESCRIPTION

The "Promise/A+" spec strongly suggests that the callbacks
given to C<then> should be run asynchronously (meaning in the
next turn of the event loop), this module provides support for
doing so using the L<Mojo::IOLoop> module.

Module authors should not care which event loop will be used but
instead should just the Promises module directly:

    package MyClass;

    use Promises qw(deferred collect);

End users of the module can specify which backend to use at the start of
the application:

    use Promises -backend => ['Mojo'];
    use MyClass;

B<Note:> If you are using Mojolicious with the L<EV> event loop, then you
should use the L<Promises::Deferred::EV> backend instead.

=back

=head1 AUTHOR

Stevan Little <stevan.little@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
