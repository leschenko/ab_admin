#!/bin/sh
#
# unicorn_<%= app_name %> 
#
# chkconfig: - 85 15
# processname: unicorn_<%= app_name %>
# description: unicorn_<%= app_name %>
#
### BEGIN INIT INFO
# Provides: unicorn_<%= app_name %>
# Required-Start: $all
# Required-Stop: $all
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop unicorn_<%= app_name %>
### END INIT INFO

set -u
set -e

APP_ROOT=<%= app_path %>
PID=$APP_ROOT/tmp/pids/unicorn.pid
RAILS_ENV=${RAILS_ENV:-"production"}

RVM_RUBY=`cat $APP_ROOT/.ruby-version`
RVM_GEMSET=`cat $APP_ROOT/.ruby-gemset`
BUNDLE_PATH=/usr/local/rvm/wrappers/ruby-$RVM_RUBY@$RVM_GEMSET/bundle

CMD="$BUNDLE_PATH exec unicorn -D -E $RAILS_ENV -c $APP_ROOT/config/unicorn/$RAILS_ENV.rb"

old_pid="$PID.oldbin"

cd $APP_ROOT || exit 1
git show-ref >> tmp/refs

sig () {
	test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
	test -s $old_pid && kill -$1 `cat $old_pid`
}

case $1 in
start)
	sig 0 && echo >&2 "Already running" && exit 0
	$CMD
	;;
stop)
	sig QUIT && exit 0
	echo >&2 "Not running"
	;;
force-stop)
	sig TERM && exit 0
	echo >&2 "Not running"
	;;
restart|reload)
	sig HUP && echo reloaded OK && exit 0
	echo >&2 "Couldn't reload, starting '$CMD' instead"
	$CMD
	;;
upgrade)
	sig USR2 && exit 0
	echo >&2 "Couldn't upgrade, starting '$CMD' instead"
	$CMD
	;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
	echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
	exit 1
	;;
esac
