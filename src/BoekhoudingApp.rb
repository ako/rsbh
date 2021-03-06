require 'sinatra'
require 'data_mapper'
require 'json'
require 'dm-serializer'
require 'dm-ar-finders'
require 'toml'

DataMapper::Logger.new(STDOUT, :debug)
@bhenv = TOML.load_file("#{Dir.home}/.boekhouding.toml")
print("Connecting to database #{@bhenv['database']['url']}\n")
DataMapper.setup(:default, @bhenv['database']['url'])

class Boek 
	include DataMapper::Resource
	storage_names[:default] = 'boeken'
	property :id, 			        String, :key => true
	property :omschrijving,	        String, :required => true
end

class Jaar
    include DataMapper::Resource
	storage_names[:default] = 'jaren'
	property :jaar, 			    Integer, :key => true
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
    property :id,                   Integer,    :key => true
    property :boek,                 String,     :required => true
    property :datum,                Date,       :required => true
    property :omschrijving,         String,     :length => 1..2000
    property :bonnummer,            Integer
    property :rekeningnummer,       Integer
    property :afbij,                String,     :required => true, :length => 1..3
    property :valuta,               String,     :required => true, :length => 1..3
    property :bedragexclusiefbtw,   Float
    property :bedraginclusiefbtw,   Float
    property :btwpercentage,        Float
    property :transactiesoort,      String,     :required => true
    property :kilometers,           Integer

    def self.nextId
        nid = repository(:default).adapter.select("select nextval('transactie_id_seq')")
        puts "next id #{nid[0]}"
        return nid[0]
    end
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

class TotalenPerSoortPerJaar
    include DataMapper::Resource
    storage_names[:default] = 'totalen_per_soort_per_jaar'
    property :jaar,                 Integer, :key => true
    property :boek,                 String, :key => true
    property :transactiesoort,      String, :key => true
    property :valuta,               String, :key => true
    property :afinclbtw,            Float
    property :afexclbtw,            Float
    property :bijinclbtw,           Float
    property :bijexclbtw,           Float
    property :inclusiefbtw,         Float
    property :exclusiefbtw,         Float
end

configure do
	set :static,  true
end

get '/boeken' do
	content_type 'text/json'
	boeken = Boek.all :order => :id.asc
	boeken.to_json
end

get '/jaren' do
	content_type 'text/json'
	jaren = Jaar.all :order => :jaar.asc
	jaren.to_json
end

get '/boeken/:id' do | boekId |
	content_type 'text/json'
	boek = Boek.get(boekId)
	boek.to_json
end

post '/boeken/:boekId/transacties' do | boekId |
    logger.info "post transacties"
    tx = Transactie.new
    tx.id = Transactie.nextId
    tx.boek = boekId
    data = JSON.parse(request.body.read)
    logger.info data
    logger.info data['datum']
    tx.datum = data['datum']
    tx.omschrijving = data['omschrijving']
    tx.bonnummer = data['bonnummer']
    tx.rekeningnummer = data['rekeningnummer']
    tx.afbij = data['afbij']
    tx.valuta = data['valuta']
    tx.bedragexclusiefbtw =data['bedragexclbtw']
    tx.bedraginclusiefbtw = data['bedraginclbtw']
    tx.btwpercentage = data['btwpercentage']
    tx.transactiesoort = data['soort']
    tx.kilometers  = data['kilometers']

    logger.info tx
    begin
        if tx.save
            #valid, saved
            # Created
            status 201
            logger.info "save, id #{tx.id}"
            newTxUrl = "/boeken/#{boekId}/transacties/#{tx.id}"
            headers 'Location' => newTxUrl
            tx.to_json
        else
            #not valid
            tx.errors.each do | e |
                logger.info e
            end
            # Bad Request
            status 400
            errors = Array.new
            tx.errors.each do | e |
                errors.push (e[0])
            end
            errors.to_json
        end
    rescue StandardError => e
        logger.info("rescueing save...")
        logger.info(e)
        logger.info("#{$!}")
        status 500
        e.resource.errors.to_json
    end
end

get '/boeken/:boekId/transacties/:transactieId' do | boekId, transactieId |
    pass unless params[:count] == 'true'
	content_type 'text/json'
    logger.info "transacties aantal"
    transacties = Transactie.count(:boek => boekId)
    logger.info "transacties aantal: #{transacties}"
    transacties.to_json
end

get '/boeken/:boekId/jaar/:jaar/totalen' do | boekId, jaar |
	content_type 'text/json'
	begin
        logger.info "totalen per jaar per soort"
        val = "EUR"
        totalen = TotalenPerSoortPerJaar.all(:boek=>boekId, :jaar=>jaar, :valuta=>val )
        totalen.to_json
    rescue StandardError => e
        logger.info("rescueing TotalenPerSoortPerJaar")
        logger.info(e)
        status 500
        e.resource.errors.to_json
    end
end

get '/boeken/:boekId/transacties/:transactieId' do | boekId, transactieId |
	content_type 'text/json'
    logger.info "alle transacties"
    limit = 1000 unless params[:limit].is_a? Integer
    offset = 0 unless params[:offset].is_a? Integer
    beginDate = Date.new( params[:jaar].to_i,1,1 )
    endDate = Date.new( params[:jaar].to_i,12,31 )

    transactie = {
       :boek.like => boekId,
       :datum => beginDate..endDate,
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

#DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize

