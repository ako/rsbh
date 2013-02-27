create or replace view inkomsten as
    select t.id
    ,      t.boek
    ,      t.datum
    ,      t.omschrijving
    ,      t.bonnummer
    ,      t.rekeningnummer
    ,      t.afbij
    ,      v2.id as valuta
    ,      round(((v.value * t.bedragexclusiefbtw)/v2.value),2) bedragexclusiefbtw
    ,      round(((v.value * t.bedraginclusiefbtw)/v2.value),2) bedraginclusiefbtw
    ,      round(
            case
                when t.btwpercentage is null
                then ((t.bedraginclusiefbtw - t.bedragexclusiefbtw) / t.bedragexclusiefbtw) * 100
                else t.btwpercentage
                end
            , 2) as btwpercentage
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
    ,      v2.id as valuta
    ,      round(case
                when t.kilometers is null
                then ((v.value * t.bedragexclusiefbtw)/v2.value)
                else ((vp.value *(t.kilometers * p.prijsinclusiefbtw * (100 / (100 + p.btwpercentage))))/v2.value)
                end,2) as bedragexclusiefbtw
    ,      round(case
                  when t.kilometers is null
                  then ((v.value * t.bedraginclusiefbtw)/v2.value)
                  else ((vp.value *(t.kilometers * p.prijsinclusiefbtw))/v2.value)
                  end,2) as bedraginclusiefbtw
    ,      case
                 when t.kilometers is null
                  then
                        round(
                          case
                              when t.btwpercentage is null
                              then ((t.bedraginclusiefbtw - t.bedragexclusiefbtw) / t.bedragexclusiefbtw) * 100
                              else t.btwpercentage
                              end
                          , 2)
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
    ,      v2.id as valuta
    ,      round(case
             when t.kilometers is null
             then ((v.value * t.bedragexclusiefbtw)/v2.value)
             else ((vp.value *(t.kilometers * p.prijsinclusiefbtw * (100 / (100 + p.btwpercentage))))/v2.value)
             end,2) as bedragexclusiefbtw
    ,      round(case
             when t.kilometers is null
             then ((v.value * t.bedraginclusiefbtw)/v2.value)
             else ((vp.value *(t.kilometers * p.prijsinclusiefbtw))/v2.value)
             end,2) as bedraginclusiefbtw
    ,      case
             when t.kilometers is null
                  then
                        round(
                          case
                              when t.btwpercentage is null
                              then ((t.bedraginclusiefbtw - t.bedragexclusiefbtw) / t.bedragexclusiefbtw) * 100
                              else t.btwpercentage
                              end
                          , 2)
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

create or replace view jaren as
  select distinct extract(year from datum) jaar
  from transacties
  order by jaar
;

create or replace view totalen_per_soort_per_jaar as
    select  extract(year from datum)    as jaar
    ,       boek                        as boek
    ,       transactiesoort             as transactiesoort
    ,       valuta                      as valuta
    ,       round(sum(case when afbij = 'AF' then bedraginclusiefbtw else 0 end),2) as afinclbtw
    ,       round(sum(case when afbij = 'AF' then bedragexclusiefbtw else 0 end),2) as afexclbtw
    ,       round(sum(case when afbij = 'BIJ' then bedraginclusiefbtw else 0 end),2) as bijinclbtw
    ,       round(sum(case when afbij = 'BIJ' then bedragexclusiefbtw else 0 end),2) as bijexclbtw
    ,       round(sum(case when afbij = 'AF' then -1 * bedraginclusiefbtw else bedraginclusiefbtw end),2)     as inclusiefbtw
    ,       round(sum(case when afbij = 'AF' then -1 * bedragexclusiefbtw else bedragexclusiefbtw end),2)     as exclusiefbtw
    ,       min(datum)                  as eerste_datum
    ,       max(datum)                  as laatste_datum
    from    saldo
    group by jaar
    ,       boek
    ,       transactiesoort
    ,       valuta
    order by jaar
    ,       boek
    ,       transactiesoort
    ,       valuta
;

create or replace view totalen_per_jaar as
    select  jaar        as jaar
    ,       boek        as boek
    ,       valuta      as valuta
    ,       round(sum(afinclbtw),2) as afinclbtw
    ,       round(sum(afexclbtw),2) as afexclbtw
    ,       round(sum(bijinclbtw),2) as bijinclbtw
    ,       round(sum(bijexclbtw),2) as bijexclbtw
    ,       round(sum(inclusiefbtw),2) as inclusiefbtw
    ,       round(sum(exclusiefbtw),2) as exclusiefbtw
    from    totalen_per_soort_per_jaar
    group by jaar
    ,       boek
    ,       valuta
    order by jaar
    ,       boek
    ,       valuta
    ;