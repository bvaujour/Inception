# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: injah <injah@student.42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/11/27 14:48:46 by injah             #+#    #+#              #
#    Updated: 2024/11/29 10:30:07 by injah            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


WP_DATA = ~/data/wordpress
DB_DATA = ~/data/mariadb

all: up

up: build
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)
	@docker compose -f ./srcs/docker-compose.yml up -d

down:
	@docker compose -f ./srcs/docker-compose.yml down

stop:
	@docker compose -f ./srcs/docker-compose.yml stop

start:
	@docker compose -f ./srcs/docker-compose.yml start

build: copy-env
	@sudo chmod 666 /var/run/docker.sock
	@clear
	@docker compose -f ./srcs/docker-compose.yml build

copy-env:
	@cp $(HOME)/.env $(shell pwd)/srcs

ng:
	@docker exec -it nginx zsh

mdb:
	@docker exec -it mariadb zsh

wp:
	@docker exec -it wordpress zsh

clean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) || true
	@sudo rm -rf $(WP_DATA) || true
	@sudo rm -rf $(DB_DATA) || true
	@sudo rm -rf $(shell pwd)/srcs/.env

re: clean up

prune: clean
	@docker system prune -a --volumes -f

.PHONY: all up down stop start build ng mdb wp clean re prune
