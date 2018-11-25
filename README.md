# pg-967_1c

Взято здесть:

https://partners.v8.1c.ru/forum/topic/1700724

Автор:

Буторин Александр (АйТимПро, Москва)


cd ~/


git clone https://github.com/renbuar/pg-967_1c.git


cd ~/pg-967_1c


mkdir -p ~/pg-967_1c/pg_dist


cd ~/pg-967_1c/pg_dist

Качаем сюда:

postgresql_9.6.7_1.1C_amd64_addon_deb.tar.bz2
postgresql_9.6.7_1.1C_amd64_deb.tar.bz2


Распаковываем:

libecpg6_9.6.7-1.1C_amd64.deb
libecpg-compat3_9.6.7-1.1C_amd64.deb
libecpg-dev_9.6.7-1.1C_amd64.deb
libpgtypes3_9.6.7-1.1C_amd64.deb
libpq5_9.6.7-1.1C_amd64.deb
libpq-dev_9.6.7-1.1C_amd64.deb
postgresql-9.6_9.6.7-1.1C_amd64.deb
postgresql-9.6-dbg_9.6.7-1.1C_amd64.deb
postgresql-client-9.6_9.6.7-1.1C_amd64.deb
postgresql-contrib-9.6_9.6.7-1.1C_amd64.deb
postgresql-doc-9.6_9.6.7-1.1C_all.deb
postgresql-plperl-9.6_9.6.7-1.1C_amd64.deb
postgresql-plpython3-9.6_9.6.7-1.1C_amd64.deb
postgresql-plpython-9.6_9.6.7-1.1C_amd64.deb
postgresql-pltcl-9.6_9.6.7-1.1C_amd64.deb
postgresql-server-dev-9.6_9.6.7-1.1C_amd64.deb


cd ~/pg-967_1c

Собираем образ командой:


docker build -t pg:967_1c .


docker volume create --name pgdata 


Запускаем:


docker run --detach --rm --volume pgdata:/var/lib/postgresql/data --name pg1c --publish 5432:5432 pg:967_1c
  


