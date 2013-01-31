create table boeken
( id varchar(30) primary key
, omschrijving varchar(2000)
);

create table valutas
( id varchar(3) primary key
, omschrijving varchar(2000)
, value numeric(10,2) not null
);

create table kilometer_prijzen
( begindatum date not null
, einddatum date not null
, prijsinclusiefbtw numeric(10,2) not null
, btwpercentage numeric(10,2) not null
, valuta varchar(3) references valutas(id) not null
, primary key (begindatum,einddatum)
);

create table transactie_soorten
( id varchar(30) primary key
, omschrijving varchar(2000)
);

create sequence transactie_id_seq;
create table transacties
( id numeric(10,0) default nextval('transactie_id_seq') primary key
, boek varchar(30) references boeken(id) not null
, datum date not null
, omschrijving varchar(2000)
, bonnummer numeric(10,0)
, rekeningnummer numeric(10,0)
, afbij varchar(3) not null check ( afbij = 'AF' or afbij = 'BIJ' ) 
, valuta varchar(3) not null references valutas(id) 
, bedragexclusiefbtw numeric(10,2)
, bedraginclusiefbtw numeric(10,2)
, btwpercentage numeric(10,2)
, transactiesoort varchar(30) references transactie_soorten(id) not null
, kilometers numeric(10,0)
, constraint chk_bedrag_of_km
  check ( kilometers is null 
        or ( bedragexclusiefbtw is null
           and bedraginclusiefbtw is null
           and btwpercentage is null
           )
        )
, constraint chk_ex_incl_btw        
  check ( kilometers is not null
        or (  bedraginclusiefbtw is not null
           or ( bedragexclusiefbtw is not null
              and btwpercentage is not null
              )
           )
        )        
);

create index transacties_boek_idx on transacties (boek);
create index transacties_datum_idx on transacties (datum);
create index transacties_afbij_idx on transacties (afbij);
create index transacties_soort_idx on transacties (transactiesoort);

