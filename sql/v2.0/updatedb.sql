create or replace view inkomsten as
    select t.id
    ,      t.boek
    ,      t.datum
    ,      t.omschrijving
    ,      t.bonnummer
    ,      t.rekeningnummer
    ,      t.afbij
    ,      v2.id as valuta
    ,      ((v.value * t.bedragexclusiefbtw)/v2.value) bedragexclusiefbtw
    ,      ((v.value * t.bedraginclusiefbtw)/v2.value) bedraginclusiefbtw
    ,      t.btwpercentage
    ,      t.transactiesoort
    ,      t.kilometers
    from   transacties t
    ,      valutas v
    ,      valutas v2
    where  t.afbij = 'BIJ'
    and    v.id = t.valuta
    order by t.afbij, t.transactiesoort, t.datum
;

create or replace view uitgaven as
    select t.id
    ,      t.boek
    ,      t.datum
    ,      t.omschrijving
    ,      t.bonnummer
    ,      t.rekeningnummer
    ,      t.afbij
    ,      v.id as valuta
    ,      case
            when t.kilometers is null
            then ((v.value * t.bedragexclusiefbtw)/v2.value)
            else ((vp.value *(t.kilometers * p.prijsinclusiefbtw * (100 / (100 + p.btwpercentage))))/v2.value)
            end as bedragexclusiefbtw
    ,      case
                  when t.kilometers is null
                  then ((v.value * t.bedraginclusiefbtw)/v2.value)
                  else ((vp.value *(t.kilometers * p.prijsinclusiefbtw))/v2.value)
                  end as bedraginclusiefbtw
    ,      case
                 when t.kilometers is null
                  then t.btwpercentage
                  else p.btwpercentage
                 end as btwpercentage
    ,      t.transactiesoort
    ,      t.kilometers
    from   transacties t
    ,      valutas v
    ,      valutas v2
    ,      kilometer_prijzen p
    ,      valutas vp
    where
           t.afbij = 'AF'
    and    v.id = t.valuta
    and    p.begindatum <= t.datum
    and    p.einddatum >= t.datum
    and    p.valuta = vp.id
    order by t.afbij, t.transactiesoort, t.datum
;

    /* t.boek = '" + _boek + "'\n"
         and    t.datum >= to_date('" + _beginDatum + "','YYYY-MM-DD')\n"
         and    t.datum <= to_date('" + _eindDatum + "','YYYY-MM-DD')\n"
         and    */
       /*  and    v2.id = '" + _valuta + "'*/

create or replace view saldo as
    select t.id
    ,      t.boek
    ,      t.datum
    ,      t.omschrijving
    ,      t.bonnummer
    ,      t.rekeningnummer
    ,      t.afbij
    ,      t.valuta
    ,      case
             when t.kilometers is null
             then ((v.value * t.bedragexclusiefbtw)/v2.value)
             else ((vp.value *(t.kilometers * p.prijsinclusiefbtw * (100 / (100 + p.btwpercentage))))/v2.value)
             end as bedragexclusiefbtw
    ,      case
             when t.kilometers is null
             then ((v.value * t.bedraginclusiefbtw)/v2.value)
             else ((vp.value *(t.kilometers * p.prijsinclusiefbtw))/v2.value)
             end as bedraginclusiefbtw
    ,      case
             when t.kilometers is null
             then t.btwpercentage
             else p.btwpercentage
             end as btwpercentage
    ,      t.transactiesoort
    ,      t.kilometers
    from   transacties t
    ,      valutas v
    ,      valutas v2
    ,      kilometer_prijzen p
    ,      valutas vp
    where
           v.id = t.valuta
    and    p.begindatum <= t.datum
    and    p.einddatum >= t.datum
    and    p.valuta = vp.id
    order by t.afbij, t.transactiesoort, t.datum
;

/*
t.boek = '" + _boek + "'\n"
    and    t.datum >= to_date('" + _beginDatum + "','YYYY-MM-DD')\n"
    and    t.datum <= to_date('" + _eindDatum + "','YYYY-MM-DD')\n"
    and    v2.id = '" + _valuta + "'\n"
*/