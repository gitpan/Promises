package Promises::Deferred;
BEGIN {
  $Promises::Deferred::AUTHORITY = 'cpan:STEVAN';
}
{
  $Promises::Deferred::VERSION = '0.01';
}
# ABSTRACT: An implementation of Promises in Perl

use strict;
use warnings;

use Scalar::Util qw[ blessed reftype ];
use Carp         qw[ confess ];

use Promises::Promise;

use constant IN_PROGRESS => 'in progress';
use constant RESOLVED    => 'resolved';
use constant REJECTED    => 'rejected';
use constant RESOLVING   => 'resolving';
use constant REJECTING   => 'rejecting';

sub new {
    my $class = shift;
    my $self  = bless {
        resolved => [],
        rejected => [],
        status   => IN_PROGRESS,
        promise  => undef
    } => $class;
    $self->{'promise'} = Promises::Promise->new( $self );
    $self;
}

sub promise { (shift)->{'promise'} }
sub status  { (shift)->{'status'}  }
sub result  { (shift)->{'result'}  }

sub resolve {
    my $self   = shift;
    my $result = [ @_ ];
    $self->{'result'} = $result;
    $self->{'status'} = RESOLVING;
    $self->_notify( $self->{'resolved'}, $result );
    $self->{'resolved'} = [];
    $self->{'status'}   = RESOLVED;
    $self;
}

sub reject {
    my $self = shift;
    my $result = [ @_ ];
    $self->{'result'} = $result;
    $self->{'status'} = REJECTING;
    $self->_notify( $self->{'rejected'}, $result );
    $self->{'rejected'} = [];
    $self->{'status'}   = REJECTED;
    $self;
}

sub then {
    my ($self, $callback, $error) = @_;

    (ref $callback && reftype $callback eq 'CODE')
        || confess "You must pass in a success callback";

    (ref $error && reftype $error eq 'CODE')
        || confess "You must pass in a error callback";

    my $d = (ref $self)->new;

    push @{ $self->{'resolved'} } => $self->_wrap( $d, $callback, 'resolve' );
    push @{ $self->{'rejected'} } => $self->_wrap( $d, $error,    'reject'  );

    if ( $self->status eq RESOLVED ) {
        $self->resolve( @{ $self->result } );
    }

    if ( $self->status eq REJECTED ) {
        $self->reject( @{ $self->result } );
    }

    $d->promise;
}

sub _wrap {
    my ($self, $d, $f, $method) = @_;
    return sub {
        my @results = $f->( @_ );
        if ( (scalar @results) == 1 && blessed $results[0] && $results[0]->isa('Promises::Promise') ) {
            $results[0]->then(
                sub { $d->resolve( @{ $results[0]->result } ) },
                sub { $d->reject  },
            );
        }
        else {
            $d->$method( @results )
        }
    }
}

sub _notify {
    my ($self, $callbacks, $result) = @_;
    $_->( @$result ) foreach @$callbacks;
}

1;

__END__

=pod

=head1 NAME

Promises::Deferred - An implementation of Promises in Perl

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use Promises::Deferred;

  sub fetch_it {
      my ($uri) = @_;
      my $d = Promises::Deferred->new;
      http_get $uri => sub {
          my ($body, $headers) = @_;
          $headers->{Status} == 200
              ? $d->resolve( decode_json( $body ) )
              : $d->reject( $body )
      };
      $d->promise;
  }

=head1 DESCRIPTION

This class is meant only to be used by an implementor,
meaning users of your functions/classes/modules should
always interact with the associated promise object, but
you (as the implementor) should use this class. Think
of this as the engine that drives the promises and the
promises as the steering wheels that control the
direction taken.

=head1 METHODS

=over 4

=item C<new>

This will construct an instance, it takes no arguments.

=item C<promise>

This will return a L<Promises::Promise> that can be used
as a handle for this object.

=item C<status>

This will return the status of the the asynchronous
operation, which will be either 'in progress', 'resolved'
or 'rejected'. These three strings are also constants
in this package (C<IN_PROGRESS>, C<RESOLVED> and C<REJECTED>
respectively), which can be used to check these values.

=item C<result>

This will return the result that has been passed to either
the C<resolve> or C<reject> methods. It will always return
an ARRAY reference since both C<resolve> and C<reject>
take a variable number of arguments.

=item C<then( $callback, $error )>

This method is used to register two callbacks, the first
C<$callback> will be called on success and it will be
passed all the values that were sent to the corresponding
call to C<resolve>. The second, C<$error> will be called
on error, and will be passed the all the values that were
sent to the corresponding C<reject>. It should be noted
that this method will always return the associated
L<Promises::Promise> instance so that you can chain
things if you like.

=item C<resolve( @args )>

This is the method to call upon the successful completion
of your asynchronous operation, meaning typically you
would call this within the callback that you gave to the
asynchronous function/method. It takes an arbitrary list
of arguments and captures them as the C<result> of this
promise (so obviously they can be retrieved with the
C<result> method).

=item C<reject( @args )>

This is the method to call when an error occurs during
your asynchronous operation, meaning typically you
would call this within the callback that you gave to the
asynchronous function/method. It takes an arbitrary list
of arguments and captures them as the C<result> of this
promise (so obviously they can be retrieved with the
C<result> method).

=back

=head1 AUTHOR

Stevan Little <stevan.little@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
