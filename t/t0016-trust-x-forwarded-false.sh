#!/bin/sh
. ./test-lib.sh
t_plan 5 "trust_x_forwarded=false configuration test"

t_begin "setup and start" && {
	unicorn_setup
	echo "trust_x_forwarded false" >> $unicorn_config
	unicorn -D -c $unicorn_config env.ru
	unicorn_wait_start
}

t_begin "spoofed request with X-Forwarded-Proto does not trigger" && {
	curl -H 'X-Forwarded-Proto: https' http://$listen/ | \
		grep -F '"rack.url_scheme"=>"http"'
}

t_begin "spoofed request with X-Forwarded-SSL does not trigger" && {
	curl -H 'X-Forwarded-SSL: on' http://$listen/ | \
		grep -F '"rack.url_scheme"=>"http"'
}

t_begin "killing succeeds" && {
	kill $unicorn_pid
}

t_begin "check stderr has no errors" && {
	check_stderr
}

t_done
