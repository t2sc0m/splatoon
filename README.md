# NAME
# splatoon-svc #

dockerでSplatoonProxyを動作させるためのconfig

# SplatoonProxy #

Slack/IRC通知Proxy

  
# SYNOPSIS

起動方法

    $ export SPLATOON_URL=https://YOUR__URL
    $ export SPLATOON_SLACK_URL=https://YOUR_SLACK_HOOK_URL
    $ export SPLATOON_SLACK_CHANNEL='#SLACK_CHANNEL_NAME'
    $ export SPLATOON_IKACHAN_URL=http://YOUR_URL/cgi-bin/notify-irc.cgi
    $ plackup

アクセスのしかた

    http://YOUR_URL/splatoon-proxy/?message=お前のものは俺のもの、俺のものも俺のもの&channel=general

# DESCRIPTION

SplatoonProxy はPSGI Applicationとして提供される、SlackおよびIRCbot向けの通知Proxyです。

  
# LICENSE

Copyright (C) Satoshi a.k.a. ytnobody AZUMA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

  
# AUTHOR

Satoshi Azuma <ytnobody@gmail.com>
