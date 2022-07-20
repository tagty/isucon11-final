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
		/home/isucon/private_isu.git/benchmarker/bin/benchmarker -u /home/isucon/private_isu.git/benchmarker/userdata -t http://35.75.126.244"

pt-query-digest:
	ssh isucon11-final-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
ALPM="/posts/[0-9]+,/posts?.+,/@.+,/image/[0-9]+"
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh isucon11-final-1 "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

pprof-kill:
	ssh isucon11-final-1 "pgrep -f 'pprof' | xargs kill;"

pprof:
	go tool pprof -http=0.0.0.0:1080 -seconds=45 http://35.75.126.244/debug/pprof/profile
