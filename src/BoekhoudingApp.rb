require 'sinatra'
require 'data_mapper'
require 'json'
require 'dm-serializer'
require 'dm-ar-finders'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'postgres://bh2:bh2@localhost/bh2dev')

class Boek 
	include DataMapper::Resource
	storage_names[:default] = 'boeken'
	property :id, 			        String, :key => true
	property :omschrijving,	        String, :required => true
end

class TransactieSoort
    include DataMapper::Resource
    storage_names[:default] = 'transactie_soorten'
    property :id,                   String, :key => true
	property :omschrijving,	        String, :required => true
end

class KilometerPrijs
    include DataMapper::Resource
    storage_names[:default] = 'kilometer_prijzen'
    property :begindatum,           Date, :key => true
    property :einddatum,            Date
    property :prijsinclusiefbtw,    Decimal
    property :btwpercentage,        Decimal
    property :valuta,               String
end

class Valuta
    include DataMapper::Resource
    storage_names[:default] = 'valutas'
    property :id,                   String, :key => true
    property :omschrijving,         String
    property :value,                Decimal
end

class Transactie
    include DataMapper::Resource
    storage_names[:default] = 'transacties'
    property :id,                   Integer, :key => true
    property :boek,                 String, :required => true
    property :datum,                Date
    property :omschrijving,         String
    property :bonnummer,            Integer
    property :rekeningnummer,       Integer
    property :afbij,                String
    property :valuta,               String
    property :bedragexclusiefbtw,   Decimal
    property :bedraginclusiefbtw,   Decimal
    property :btwpercentage,        Decimal
    property :transactiesoort,      String
    property :kilometers,           Integer
end

class Inkomsten
    include DataMapper::Resource
    storage_names[:default] = 'inkomsten'
    property :id,                   Integer, :key => true
    property :boek,                 String
    property :datum,                Date
    property :omschrijving,         String
    property :bonnummer,            Integer
    property :rekeningnummer,       Integer
    property :afbij,                String
    property :valuta,               String
    property :bedragexclusiefbtw,   Decimal
    property :bedraginclusiefbtw,   Decimal
    property :btwpercentage,        Decimal
    property :transactiesoort,      String
    property :kilometers,           Integer
end

class Uitgaven
    include DataMapper::Resource
    storage_names[:default] = 'uitgaven'
    property :id,                   Integer, :key => true
    property :boek,                 String
    property :datum,                Date
    property :omschrijving,         String
    property :bonnummer,            Integer
    property :rekeningnummer,       Integer
    property :afbij,                String
    property :valuta,               String
    property :bedragexclusiefbtw,   Decimal
    property :bedraginclusiefbtw,   Decimal
    property :btwpercentage,        Decimal
    property :transactiesoort,      String
    property :kilometers,           Integer
end

class Saldo
    include DataMapper::Resource
    storage_names[:default] = 'saldo'
    property :id,                   Integer, :key => true
    property :boek,                 String
    property :datum,                Date
    property :omschrijving,         String
    property :bonnummer,            Integer
    property :rekeningnummer,       Integer
    property :afbij,                String
    property :valuta,               String
    property :bedragexclusiefbtw,   Decimal
    property :bedraginclusiefbtw,   Decimal
    property :btwpercentage,        Decimal
    property :transactiesoort,      String
    property :kilometers,           Integer
end

configure do
	set :static,  true
end

get '/boeken' do
	content_type 'text/json'
	boeken = Boek.all :order => :id.asc
	boeken.to_json
end

get '/boeken/:id' do | boekId |
	content_type 'text/json'
	boek = Boek.get(boekId)
	boek.to_json
end

get '/boeken/:boekId/transacties/:transactieId' do | boekId, transactieId |
    pass unless params[:count] == 'true'
	content_type 'text/json'
    logger.info "transacties aantal"
    transacties = Transactie.count(:boek => boekId)
    logger.info "transacties aantal: #{transacties}"
    transacties.to_json
end

get '/boeken/:boekId/transacties/:transactieId' do | boekId, transactieId |
	content_type 'text/json'
    logger.info "alle transacties"
    limit = 100 unless params[:limit].is_a? Integer
    offset = 0 unless params[:offset].is_a? Integer
    transactie = {
       :boek.like => boekId,
#       :datum.to_s.like => "%#{params[:datum]}%",
       :omschrijving.like => "%#{params[:omschrijving]}%",
#        :bonnummer.like => "%#{params[:bonnummer]}%",
#        :rekeningnummer.like => "%#{params[:rekeningnummer]}%",
        :afbij.like => "%#{params[:afbij]}%",
        :valuta.like => "%#{params[:valuta]}%",
#        :bedraginclusiefbtw.like => "%#{params[:bedraginclbtw]}%",
#        :bedragexclusiefbtw.like => "%#{params[:bedragexclbtw]}%",
#        :btwpercentage.like => "%#{params[:btwpercentage]}%",
        :transactiesoort.like => "%#{params[:transactiesoort]}%"
#        :kilometers.like => "%#{params[:kilometers]}%"
    }
    logger.info "stap 2: #{transactie}"
    transacties = Transactie.all( :conditions => transactie,
        :offset => Integer(offset),
        :limit => Integer(limit),
        :order => :id.asc)
    logger.info "stap 3: #{transacties.length}"
    transacties.to_json
end


get '/transacties' do
	content_type 'text/json'
    transacties = Transactie.all :order => :id.desc
    transacties.to_json
end

get '/transactiesoorten' do
	content_type 'text/json'
    transactiesoorten = TransactieSoort.all :order => :id.asc
    transactiesoorten.to_json
end

get '/kilometerprijzen' do
	content_type 'text/json'
    kilometerprijzen = KilometerPrijs.all :order => :begindatum.desc
    kilometerprijzen.to_json
end

get '/valutas' do
    content_type 'text/json'
    valutas = Valuta.all :order => :id.asc
    valutas.to_json
end

get '/boeken/:boekId/inkomsten/' do | boekId |
	content_type 'text/json'
	logger.info "inkomsten rapport #{params[:van]} #{params[:tot]} #{params[:valuta]}"
    inkCondition = {
        :boek => boekId,
        :valuta => params[:valuta],
        :datum.gte => params[:van],
        :datum.lte => params[:tot]
    }
	inkomsten = Inkomsten.all( :conditions => inkCondition, :order => :id.asc)
	logger.info "inkomsten rapport: #{inkomsten.length}"
	inkomsten.to_json
end

get '/boeken/:boekId/uitgaven/' do | boekId |
	content_type 'text/json'
    uitCondition = {
        :boek => boekId,
        :valuta => params[:valuta],
        :datum.gte => params[:van],
        :datum.lte => params[:tot]
    }
	uitgaven = Uitgaven.all(:conditions => uitCondition, :order => :id.asc)
	uitgaven.to_json
end

get '/boeken/:boekId/saldo/' do | boekId |
	content_type 'text/json'
    saldoCondition = {
        :boek => boekId,
        :valuta => params[:valuta],
        :datum.gte => params[:van],
        :datum.lte => params[:tot]
    }
	saldo = Saldo.all(:conditions => saldoCondition, :order => :id.asc)
	saldo.to_json
end

DataMapper.finalize

