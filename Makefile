deploy:
	ssh isucon11-final-1 " \
		cd /home/isucon; \
		git checkout .; \
		git fetch; \
		git checkout $(BRANCH); \
		git reset --hard origin/$(BRANCH)"

build:
	ssh isucon11-final-1 " \
		cd /home/isucon/webapp/go; \
		/home/isucon/local/go/bin/go build -o isucholar; \
		sudo systemctl restart isucholar.go.service"

mysql-deploy:
	ssh isucon11-final-1 "sudo dd of=/etc/mysql/mysql.conf.d/mysqld.cnf" < ./etc/mysql/mysql.conf.d/mysqld.cnf

mysql-rotate:
	ssh isucon11-final-1 "sudo rm -f /var/log/mysql/mysql-slow.log"

mysql-restart:
	ssh isucon11-final-1 "sudo systemctl restart mysql.service"

nginx-rotate:
	ssh isucon11-final-1 "sudo rm -f /var/log/nginx/access.log"

nginx-reload:
	ssh isucon11-final-1 "sudo systemctl reload nginx.service"

nginx-restart:
	ssh isucon11-final-1 "sudo systemctl restart nginx.service"

bench-run:
	ssh isucon11-final-1 " \
		cd /home/isucon/benchmarker; \
		./bin/benchmarker -target localhost:443 -tls"

pt-query-digest:
	ssh isucon11-final-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
ALPM="/api/courses/[0-9A-Z]{26}/classes/[0-9A-Z]{26}/assignments/export"
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh isucon11-final-1 "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

pprof-kill:
	ssh isucon11-final-1 "pgrep -f 'pprof' | xargs kill;"

.PHONY: pprof
pprof:
	ssh isucon11-final-1 "/home/isucon/local/go/bin/go tool pprof -seconds=75 webapp/go/isucholar http://localhost:6060/debug/pprof/profile"

pprof-show:
	$(eval latest := $(shell ssh isucon11-final-1 "ls -rt ~/pprof/ | tail -n 1"))
	scp isucon11-final-1:~/pprof/$(latest) ./pprof
	go tool pprof -http=":1080" ./pprof/$(latest)
