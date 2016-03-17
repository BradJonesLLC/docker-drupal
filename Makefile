CURRENT_DIRECTORY := $(shell pwd)

start:  
	@docker-compose up -d

build:
	@docker-compose build;

clean:  
	@docker-compose rm --force

stop:  
	@docker-compose stop

status:  
	@docker-compose ps

restart:  
	@docker-compose stop
	@docker-compose start

make-data:
	@docker create --name drupal_data -v /var/lib/mysql debian:latest /bin/true

.PHONY: clean start stop status restart make-data build
