insert into valutas values('NLG','Nederlandse Gulden', ( 1 / 2.02371) );

insert into valutas values('EUR','Euro', 1 ); 

insert into valutas values('DM','Duitse Mark', 0.5175 );



insert into boeken values ('test','test');

insert into boeken values ('boek1','huishouding');

insert into boeken values ('boek2','Milena');



insert into kilometer_prijzen values ('1/1/1988','1/1/1991',0.45,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1991','1/1/1992',0.44,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1992','1/1/1993',0.34,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1993','4/1/1993',0.40,14.94,'NLG');

insert into kilometer_prijzen values ('4/1/1993','7/1/1993',0.45,14.94,'NLG');

insert into kilometer_prijzen values ('7/1/1993','1/1/1994',0.52,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1994','1/1/1995',0.57,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1995','1/1/1996',0.59,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1996','1/1/1998',0.60,14.94,'NLG');

insert into kilometer_prijzen values ('1/1/1998','1/1/2002',0.60,12,'NLG');







insert into transactie_soorten values ('subsidie','subsidie');

insert into transactie_soorten values ('verkoop','M Verkoop');

insert into transactie_soorten values ('verhuur','M Verhuur');

insert into transactie_soorten values ('divink','M+A diverse inkomsten');

insert into transactie_soorten values ('hg-btw','M Inkomsten hoog BTW');

insert into transactie_soorten values ('atelier','M Atelierkosten');

insert into transactie_soorten values ('materiaal','M Materiaalkosten');

insert into transactie_soorten values ('provisie','M Provisie');

insert into transactie_soorten values ('kilometers','M Kilometerkosten');

insert into transactie_soorten values ('reiskosten','M reiskosten');

insert into transactie_soorten values ('vakliterat','M Kosten vakliteratuur');

insert into transactie_soorten values ('telefoon','M Telefoonkosten');

insert into transactie_soorten values ('pres','M Presentatiekosten');

insert into transactie_soorten values ('aanloop','M Aanloopkosten');

insert into transactie_soorten values ('afschrijving','M Afschrijving inv.');

insert into transactie_soorten values ('benzine','M Benzinekosten');

insert into transactie_soorten values ('div.uitg','M+A Diverse Uitgaven');

insert into transactie_soorten values ('salaris','A salaris-wachtgeld');

insert into transactie_soorten values ('Unipat','A free-lance ink.');

insert into transactie_soorten values ('belterug','A belasting teruggave');

insert into transactie_soorten values ('bnkrente','A bankrente');

insert into transactie_soorten values ('fout','foutboeking');

insert into transactie_soorten values ('huis','A woonlasten');

insert into transactie_soorten values ('auto','A Autokosten');

insert into transactie_soorten values ('boot','A kosten boot');

insert into transactie_soorten values ('levensm','A Levensmiddelen');

insert into transactie_soorten values ('rookw+dr','A Rookwaren en drank');

insert into transactie_soorten values ('contant','A contante opnamen');

insert into transactie_soorten values ('kleding','A Kleding');

insert into transactie_soorten values ('medisch','A Medische kosten');

insert into transactie_soorten values ('verzekering','A Overige verzekering');

insert into transactie_soorten values ('beroep','A Beroepskosten');

insert into transactie_soorten values ('beroep.Mil','A Milena beroepsk.v.rek.A');

insert into transactie_soorten values ('lectuur','A Lectuur');

insert into transactie_soorten values ('ptt','A Telefoon en omroep');

insert into transactie_soorten values ('bank','A bankkosten');

insert into transactie_soorten values ('belasting','A belasting');

insert into transactie_soorten values ('spaar','A spaarrekening');

insert into transactie_soorten values ('Andrej','A Andrej');

insert into transactie_soorten values ('Denis','A Denis');

insert into transactie_soorten values ('div.ch','A Div. Eurocheques');

insert into transactie_soorten values ('cheq.buit','A Cheques buitenland');



insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test inkomst 1',1,2,'BIJ','EUR',20,30,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test inkomst 2',1,2,'BIJ','EUR',40,60,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test inkomst 3',1,2,'BIJ','EUR',20,30,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test inkomst 4',1,2,'BIJ','EUR',20,30,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test inkomst 5',1,2,'BIJ','EUR',20,30,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test uitgave 1',1,2,'AF','EUR',10,10,0,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test uitgave 2',1,2,'AF','EUR',20,20,0,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test uitgave 3',1,2,'AF','EUR',30,45,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test uitgave 4',1,2,'AF','EUR',40,60,50,'reiskosten',null);

insert into transacties values ( nextval('transactie_id_seq'), 'test',current_date,'test uitgave 5',1,2,'AF','EUR',50,100,50,'reiskosten',null);



commit;

