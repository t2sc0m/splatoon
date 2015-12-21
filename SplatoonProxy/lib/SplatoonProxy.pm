package SplatoonProxy;
use 5.008001;
use strict;
use warnings;

use Encode;
use Furl;
use URI;
use Plack::Request;
use Plack::Response;
use JSON;
use HTTP::Request::Common;

our $VERSION = "0.01";
our $SLACK_URL;
our $SLACK_CHANNEL = 'general';
our $SLACK_NICK = 'Splatoon-the-Notifier';
our $SLACK_ICON = 'https://lh3.googleusercontent.com/-yZGk_swE8Oc/VXpJksg1PMI/AAAAAAAAB28/BNn59kLRBxA/s200/splatoon-6.png';
our $URL;
our $IKACHAN_URL;
our $IKACHAN_PARAM_NAME = $ENV{SPLATOON_IKACHAN_PARAM_NAME} || 'message';
our $IKACHAN_CHANNEL_PARAM_NAME = $ENV{SPLATOON_IKACHAN_CHANNEL_PARAM_NAME} || 'channel';

our $CHANNEL_MAP;

my $furl = Furl->new(agent => 'SplatoonProxy/0.01');
my $json = JSON->new->utf8(1);

my $conf = confy('Splatoon');

$SLACK_URL = $conf->{slack_url} if $conf->{slack_url};
$SLACK_CHANNEL = $conf->{slack_channel} if $conf->{slack_channel};
$IKACHAN_URL = $conf->{ikachan_url} if $conf->{ikachan_url};

$CHANNEL_MAP = confy('SplatoonChannelMap');

sub confy {
    my $realm = shift;
    my $res = $furl->get($url.'/confy/config/'.$realm);
    $json->decode($res->content) if $res->is_success;
}

sub slack {
    my (%param) = @_;
    return unless length($param{message});
    my $payload = $json->encode({
        text => Encode::decode_utf8($param{message}), 
        channel => '#'.$param{channel},
        icon_url => $param{icon_url},
        username => $param{nickname},
    });
    my $req = POST($SLACK_URL, [payload => $payload]);
    $furl->request($req);
}

sub ika {
    my (%param) = @_;
    my $message = sprintf('[#%s@%s] %s', $param{channel}, $param{nickname}, $param{message});
    my $res = $furl->post($IKACHAN_URL, [], {
        $IKACHAN_PARAM_NAME         => $message, 
        $IKACHAN_CHANNEL_PARAM_NAME => $CHANNEL_MAP->{$param{channel}} || $param{channel},
    });
    $res->is_success;
}

sub post {
    my (%param) = @_;
    return if length($param{message}) < 1;
    $param{channel} =~ s/^#//;
    slack(%param);
    ika(%param);
}


sub app {
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        return [404, [], ['not found']] unless $req->path eq '/';
        my $message = $req->param('message');
        my $channel = $req->param('channel') || $SLACK_CHANNEL;
        my $nickname = $req->param('nickname') || $SLACK_NICK;
        my $icon_url = $req->param('icon_url') || $SLACK_ICON;
        post(
            channel => $channel,
            message => $message,
            nickname => $nickname,
            icon_url => $icon_url,
        );
        Plack::Response->new(200, ['Content-type', 'application/json'], ["{status: 200}"])->finalize;
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

SplatoonProxy - Slack/IRC通知Proxy

=head1 SYNOPSIS

起動方法

    $ export SPLATOON_URL=https://YOUR_URL
    $ export SPLATOON_SLACK_URL=https://YOUR_SLACK_HOOK_URL
    $ export SPLATOON_SLACK_CHANNEL='#SLACK_CHANNEL_NAME' 
    $ export SPLATOON_IKACHAN_URL=http://YOUR_URL/cgi-bin/notify-irc.cgi 
    $ plackup

アクセスのしかた

    http://YOUR_URL/splatoon-proxy/?message=お前のものは俺のもの、俺のものも俺のもの&channel=general

=head1 DESCRIPTION

SplatoonProxy はPSGI Applicationとして提供される、SlackおよびコロンIRCbot向けの通知Proxyです。

=head1 LICENSE

Copyright (C) Satoshi a.k.a. ytnobody AZUMA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Satoshi Azuma E<lt>ytnobody@gmail.comE<gt>

=cut

