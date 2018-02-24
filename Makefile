default: make-ssl
	docker-compose build
	@docker-compose up -d mariadb
	@docker-compose run --no-deps --rm web bundle install -j4

up: migrate
	docker-compose up

migrate:
	@while ! docker-compose run --rm mariadb ls /var/lib/mysql/development > /dev/null ; do sleep 4; echo "."; done
	docker-compose run --rm web bin/rails db:migrate RAILS_ENV=development

update-bundle:
	@docker-compose run --rm web bundle update

make-ssl:
	mkdir -p .sslkey ssl
	openssl genrsa -out .sslkey/server.key 2048
	openssl genrsa -out ssl/secret.key 2048
	openssl rsa -in ssl/secret.key -out .sslkey/secret.key.rsa

	openssl req -new -key .sslkey/server.key -subj "/C=/ST=/L=/O=/CN=/emailAddress=/" -out .sslkey/server.csr
	openssl req -new -key .sslkey/secret.key.rsa -subj "/C=/ST=/L=/O=/CN=example/" -out ssl/secret.csr -config conf/domain.conf

	openssl x509 -req -days 365 -in .sslkey/server.csr -signkey .sslkey/server.key -out .sslkey/server.crt
	openssl x509 -req -extensions v3_req -days 365 -in ssl/secret.csr -signkey .sslkey/secret.key.rsa -out ssl/secret.crt -extfile conf/domain.conf

	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ssl/secret.crt
	cat ssl/secret.key ssl/secret.crt > ssl/secret.pem

clean:
	@-rm -rf .sslkey ssl
	@-docker-compose down
	@-docker volume rm rails_mysql-data rails_bundle-data

docker-rspec:
	docker-compose run --rm web bundle exec rspec
rubocop:
	docker-compose run --no-deps --rm web bundle exec rubocop
brakeman:
	docker-compose run --rm web bundle exec brakeman -w3
console:
	docker-compose run --rm web bundle exec rails c
routes:
	docker-compose run --rm web bundle exec rails routes
db-reset:
	docker-compose run --rm web bundle exec rake db:migrate:reset
