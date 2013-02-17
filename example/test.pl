#!perl

use v5.10;

use strict;
use warnings;

use Promises qw[ deferred ];
use Mojo::UserAgent;
use Mojo::IOLoop;

sub fetch {
    state $ua = Mojo::UserAgent->new;
    my $url   = shift;
    my $d     = deferred;
    $ua->get($url => sub {
        my ($ua, $tx) = @_;
        $d->resolve( $tx );
    });
    $d->promise;
}

sub get_thumbnail {
    my $url = shift;
    fetch( $url )->then(
        sub {
            my $tx = shift;
            fetch( $tx->res->dom->find('img')->[0]->{'src'} );
        }        
    );
}

my $delay = Mojo::IOLoop->delay;

foreach my $url (qw[ mojolicio.us www.google.com ]) {
    $delay->begin;
    get_thumbnail($url)->then(
        sub {
            my $tx = shift;
            $delay->end( $tx );
        }
    );
}

my @thumbs = $delay->wait;

print join "\n" => map { $_->req->url } @thumbs;
print "\n";

__END__

=pod 

Here is the example Scala code, it assumes a function 
called C<fetch> which when given a URL will return a
Future.

  def getThumbnail(url: String): Future[Webpage] = {
      val promise = new Promise[Webpage]
      fetch(url) onSuccess { page =>
          fetch(page.imageLinks(0)) onSuccess { p =>
              promise.setValue(p)
          } onFailure { exc =>
              promise.setException(exc)
          }
      } onFailure { exc =>
          promise.setException(exc)
      }
      promise
  }

=cut

# first our simple URL fetcher 
# that returns a promise

sub fetch {
    state $ua = Mojo::UserAgent->new;
    my $url   = shift;
    my $d     = deferred;
    $ua->get($url => sub {
        my ($ua, $tx) = @_;
        $d->resolve( $tx );
    });
    $d->promise;
}

# then we copy what they did in Scala

sub get_thumbnail {
    my $url = shift;
    my $d   = Promises::Deferred->new;
    fetch( $url )->then(
        sub {
            my $page = shift;
            fetch( $page->image_links->[0] )->then(
                sub { $d->resolve( $_[0] ) },
                sub { $d->reject( $_[0] ) },                
            )
        },
        sub { $d->reject( $_[0] ) }
    );
    $d->promise;
}

=pod

Scala Futures have a method called C<flatMap>, which takes a 
function that given value will return another Future. 

  def getThumbnail(url: String): Future[Webpage] =
    fetch(url) flatMap { page =>
      fetch(page.imageLinks(0))
    }

=cut

# but since our C<then> method actually creates a 
# new promise and wraps the callbacks to chain to 
# that promise, we don't need this flatMap combinator
# and so this, Just Works.

sub get_thumbnail {
    my $url = shift;
    fetch( $url )->then(
        sub {
            my $page = shift;
            fetch( $page->image_links->[0] );
        }        
    );
}

=pod

Scala Futures also have a C<rescue> method which can 
serve as a kind of catch block that potentially will 
return another Future.

  val f = fetch(url) rescue {
    case ConnectionFailed =>
      fetch(url)
  }

=cut

# and just as with C<flatMap>, since our callbacks
# are wrapped and chained with a new Promise, we 
# can do a rescue just by using the error callback
# The Promise returned by C<fetch> will get chained
# and so this will depend on it.

sub get_thumbnail {
    my $url = shift;
    fetch( $url )->then(
        sub {
            my $page = shift;
            fetch( $page->image_links->[0] );
        },
        sub {
            given ( $_[0] ) {
                when ('connection_failed') {
                    return fetch( $url );
                }
                default {
                    return "failed";
                }
            }
        }
    );
}

sub retry {
    my $p = shift;
    $p->then(
        undef,
        sub {
            given ( $_[0] ) { 
                when ('connection_failed') {
                    return fetch( $url );
                }
                default {
                    return "failed";
                }
            }
        }
    );
}

sub get_thumbnail {
    my $url = shift;
    fetch( $url )->then(
        sub {
            my $page = shift;
            fetch( $page->image_links->[0] );
        }
    );
}

retry( get_thumbnail( $url ) );




