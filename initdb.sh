psql bh2dev bh2 --file=sql/v1.0/dropdb.sql
psql bh2dev bh2 --file=sql/v1.0/createdb.sql
psql bh2dev bh2 --file=sql/v1.0/initdata.sql
psql bh2dev bh2 --file=sql/v1.0/initdata2.sql

psql bh2dev bh2 --file=sql/v2.0/updatedb.sql

