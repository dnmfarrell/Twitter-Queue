package Twitter::Queue;
use warnings;
use strict;
use Net::Twitter::Lite::WithAPIv1_1;
our $VERSION = 0.01;

sub new {
  my ($class, $args) = @_;
  return bless {
    twitter => Net::Twitter::Lite::WithAPIv1_1->new(%$args),
    size    => $args->{size} || 100,
  }, $class;
}

sub add {
  my ($self, $data) = @_;
  my $res = eval { $self->{twitter}->update($data) };
  if ($@) {
    die ref $@ eq 'Net::Twitter::Error'
      ? sprintf 'Error tweeting %s %s %s', $@->code, $@->message, $@->error
      : sprintf 'Error tweeting %s', $@;
  }
  return $res;
}

sub next {
  my ($self) = @_;
  my $statuses = $self->{twitter}->home_timeline({ count => $self->{size} });
  my $next = $statuses->[-1];
  return undef unless $next;
  $self->{twitter}->destroy_status($next->{id});
  return $next->{text};
}

1;
__END__
=encoding utf8

=head1 NAME

Twitter::Queue - the micro blogging framework FIFO queue

=head1 METHODS

=head2 new ($args)

Constructor, returns a new C<Twitter::Queue> object.

Requires hashref containing these key values:

  consumer_key        => '...',
  consumer_secret     => '...',
  access_token        => '...',
  access_token_secret => '...',
  size                => 100, # optional queue size

The Twitter key/secrets come from the Twitter API. You need to L<register|http://apps.twitter.com>
an application with Twitter in order to obtain them.

=head2 add ($item)

Adds C<$item> to the queue, C<$item> must be be a string that complies with Twitter's
character counting L<rules|https://dev.twitter.com/basics/counting-characters>.

=head2 next ()

Returns the next item in the queue, removing it from the queue. Returns C<undef>
if the queue is empty.

=head1 AUTHOR

E<copy> 2017 David Farrell

=head1 LICENSE

The (two-clause) FreeBSD License, see LICENSE.

=cut
