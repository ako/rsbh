/*******************************************************************************
 *
 * App
 *
 ******************************************************************************/

console.log("init");
var boekhoudingApp = angular.module('boekhoudingApp',
	['ui.bootstrap.dialog','boekhoudingApp.services']);
boekhoudingApp.
	config(['$routeProvider', function ($routeProvider) {
	$routeProvider.
		when('/welkom',
		{templateUrl:'partials/welkom.html', controller:WelkomCtrl}).
		when('/rapport/totalen',
		{templateUrl:'partials/totalenrapport.html', controller:TotalenRapportCtrl}).

		when('/rapport/:rapportType',
		{templateUrl:'partials/rapporten.html', controller:RapportenCtrl}).


		when('/transacties',
		{templateUrl:'partials/transacties.html', controller:TransactiesCtrl}).
		when('/boeken',
		{templateUrl:'partials/boeken.html', controller:BoekenCtrl}).
		when('/transactiesoorten',
		{templateUrl:'partials/transactiesoorten.html', controller:TransactieSoortenCtrl}).
		when('/valutas',
		{templateUrl:'partials/valutas.html', controller:ValutaCtrl}).
		when('/kilometerprijs',
		{templateUrl:'partials/kilometerprijs.html', controller:KilometerPrijsCtrl}).
		otherwise({redirectTo:'/welkom'});
}]);

/*******************************************************************************
 *
 * Services
 *
 ******************************************************************************/

var BoekhoudingSvc = angular.module('boekhoudingApp.services', ['ngResource']);
BoekhoudingSvc.
	factory('Rapport',function ($resource) {
		console.log('rapportSvc');
		return $resource('/boeken/:boekId/:rapportType/?van=:beginDatum&tot=:eindDatum&valuta=:valuta',
			{}, {
				query:{method:'GET', params:{rapportType:''}, isArray:true}
			});
	}).
	factory('TotalenPerSoortPerJaar',function ($resource) {
		console.log('totalenPerSoortPerJaarSvc');
		return $resource('/boeken/:boekId/jaar/:jaar/totalen/',
			{}, {
				query:{method:'GET', params:{boekId:''}, isArray:true}
			});
	}).
	factory('Boek',function ($resource) {
		console.log('boekSvc');
		return $resource('/boeken/:boekId', {}, {
			query:{method:'GET', params:{boekId:''}, isArray:true}
		});
	}).
	factory('Jaar',function ($resource) {
		console.log('jaarSvc');
		return $resource('/jaren/:jaar', {}, {
			query:{method:'GET', params:{jaar:''}, isArray:true}
		});
	}).
	factory('Valuta',function ($resource) {
		console.log('valutaSvc');
		return $resource('/valutas/:valutaId', {}, {
			query:{method:'GET', params:{valutaId:''}, isArray:true}
		});
	}).
	factory('TransactieSoort',function ($resource) {
		console.log('transactieSoortSvc');
		return $resource('/transactiesoorten/:transactieSoortId', {}, {
			query:{method:'GET', params:{transactieSoortId:''}, isArray:true}
		});
	}).
	factory('KilometerPrijs',function ($resource) {
		console.log('kilometerPrijsSvc');
		return $resource('/kilometerprijzen/:beginDatum', {}, {
			query:{method:'GET', params:{beginDatum:''}, isArray:true}
		});
	}).
	factory('Transactie', function ($resource) {
		console.log('transactieSvc');
		return $resource('/boeken/:boekId/transacties/:transactieId', {}, {
			query:{method:'GET', params:{transactieId:'all'}, isArray:true},
			save:{method:'POST'}
		});
	}).factory('Globals',function($resource){
		console.log('Globals');
		return {
			actiefBoek: "test",
			actiefJaar: 2013,
			actiefValuta: "EUR"
		};
	});

/*******************************************************************************
 *
 * Controllers
 *
 ******************************************************************************/

function WelkomCtrl($scope) {
	console.log('WelkomCtrl');
};

function BoekKeuzeCtrl($scope,Globals,Boek){
	$scope.boeken = Boek.query(function(){
		console.log("boeken: "+ $scope.boeken.length);
		Globals.actiefBoek = $scope.boeken[0].id;
		$scope.actiefBoek = Globals.actiefBoek;
	});
	$scope.kiesBoek = function(boek){
		console.log("kiesBoek:" + boek.id);
		Globals.actiefBoek = boek.id;
		$scope.actiefBoek = Globals.actiefBoek;
	}
}
BoekKeuzeCtrl.$inject = ['$scope','Globals','Boek']

function JaarKeuzeCtrl($scope,Globals,Jaar){
	$scope.jaren = Jaar.query(function(){
		console.log("jaren: "+ $scope.jaren.length);
		Globals.actiefJaar = $scope.jaren[0].jaar;
		$scope.actiefJaar = Globals.actiefJaar;
	});
	$scope.kiesJaar = function(jaar){
		console.log("kiesJaar:" + jaar.jaar);
		Globals.actiefJaar = jaar.jaar;
		$scope.actiefJaar = Globals.actiefJaar;
	}
}
JaarKeuzeCtrl.$inject = ['$scope','Globals','Jaar']

function ValutaKeuzeCtrl($scope,Globals,Valuta){
	$scope.valutas = Valuta.query(function(){
		console.log("valutas: "+ $scope.valutas.length);
		Globals.actiefValuta = $scope.valutas[0].id;
		$scope.actiefValuta = Globals.actiefValuta;
	});
	$scope.kiesValuta = function(valuta){
		console.log("kiesValuta:" + valuta.id);
		Globals.actiefValuta = valuta.id;
		$scope.actiefValuta = Globals.actiefValuta;
	}
}
ValutaKeuzeCtrl.$inject = ['$scope','Globals','Valuta']

/******************************* RapportenCtrl ********************************/

function RapportenCtrl($scope, Rapport,Globals,$routeParams) {
	console.log('RapportenCtrl');
	$scope.qryBegindatum = "01/01/" + Globals.actiefJaar;
	$scope.qryEinddatum = "31/12/" + Globals.actiefJaar;
	$scope.qryRapporttype = $routeParams.rapportType;
	$scope.toonRapport = function () {
		console.log("toonRapport: " + $scope.qryValuta + ", " +
			$scope.qryBegindatum + ", " + $scope.qryEinddatum + ", " +
			$scope.qryRapporttype);
		$scope.rapportRegels =
			Rapport.query({
					boekId:Globals.actiefBoek,
					rapportType:$scope.qryRapporttype,
					beginDatum:$scope.qryBegindatum,
					eindDatum:$scope.qryEinddatum,
					valuta:Globals.actiefValuta},
				function () {
					console.log("rapport query result: ");
				});
	};
	$scope.toonRapport();
};
RapportenCtrl.$inject = ['$scope','Rapport','Globals','$routeParams']

function TotalenRapportCtrl($scope,TotalenPerSoortPerJaar,Globals) {
	console.log("TotalenRapportCtrl");
	$scope.refresh = function(){
		console.log("refresh");
		$scope.totalen = TotalenPerSoortPerJaar.query({
			boekId: Globals.actiefBoek,
			jaar: Globals.actiefJaar,
			valuta: Globals.actiefValuta
		},function(){
			$scope.bijExBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.bijexclbtw},0);
			$scope.bijInBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.bijinclbtw},0);
			$scope.afExBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.afexclbtw},0);
			$scope.afInBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.afinclbtw},0);
			$scope.inclusiefBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.inclusiefbtw},0);
			$scope.exclusiefBtw = _.reduce($scope.totalen,function(memo,num){return memo + num.exclusiefbtw},0);
		});
	};
	$scope.refresh();
}
TotalenRapportCtrl.$inject = ['$scope','TotalenPerSoortPerJaar','Globals']

/************************************* BoekenCtrl *****************************/

function BoekenCtrl($scope, Boek) {
	console.log('BoekenCtrl');
	$scope.boeken = Boek.query();
};
BoekenCtrl.$inject = ['$scope', 'Boek']

/************************************* ValutaCtrl *****************************/

function ValutaCtrl($scope, Valuta) {
	console.log('ValutaCtrl');
	$scope.valutas = Valuta.query();
};
ValutaCtrl.$inject = ['$scope', 'Valuta']

/************************************* KilometerPrijsCtrl *****************************/

function KilometerPrijsCtrl($scope, KilometerPrijs) {
	console.log('KilometerPrijsCtrl');
	$scope.kilometerPrijzen = KilometerPrijs.query();
};
KilometerPrijsCtrl.$inject = ['$scope', 'KilometerPrijs']

/**************************** TransactieSoortenCtrl ***************************/

function TransactieSoortenCtrl($scope, TransactieSoort) {
	console.log('TransactieSoortenCtrl');
	$scope.transactieSoorten = TransactieSoort.query();
};
TransactiesCtrl.$inject = ['$scope', 'TransactieSoort']

/******************************** TransactiesCtrl *****************************/

function TransactiesCtrl($scope, Transactie, $dialog,Globals, TransactieSoort, Valuta) {
	console.log('TransactiesCtrl');
	$scope.offset = 0;
	$scope.limit = 1000;
	$scope.filter = "";
	$scope.sortCol = "datum";
	$scope.sortReverse = false;
	$scope.actiefBoek = Globals.actiefBoek;
	$scope.actiefJaar = Globals.actiefJaar;
	$scope.tx = new Transactie();
	$scope.transactieSoorten =  TransactieSoort.query();
	$scope.valutas = Valuta.query();
	$scope.refresh = function(){
		$("#busy").show();
		$scope.transacties = Transactie.query(
			{ 	offset:$scope.offset,
			  	limit:$scope.limit,
			  	boekId:Globals.actiefBoek,
				jaar:Globals.actiefJaar
			},
			function(){
				console.log($scope.transacties[0]);
				$scope.transactiesCount = $scope.transacties.length;
				$scope.actiefBoek = Globals.actiefBoek;
				$scope.actiefJaar = Globals.actiefJaar;
				$("#busy").hide();
			}
		);
	};
	$scope.toevoegPopup = function(){
		$(".transactieForm").show();
	};
	$scope.sort = function(col){
		console.log("sort: " + col + ", " + $(col).attr("class"));
		$scope.sortCol = col;
		$scope.sortReverse = !$scope.sortReverse;
	}
	$scope.sortIcon = function(col){
		if(col == $scope.sortCol){
				return $scope.sortReverse ? "icon-sort-up" : "icon-sort-down";
		} else {
			return "icon-sort";
		}
	}
	$scope.transactieOpslaan = function(tx){
		console.log("transactieOpslaan");
		console.log($scope.tx);
		$scope.tx.$save({boekId:Globals.actiefBoek},function(ntx){
			console.log("transactieOpslaan: " + ntx);
			$(".transactieForm .alert").addClass("alert-success").show();
			$(".transactieForm .alert span").text("Ok dan, nieuwe transactie toegevoegd.");
			$scope.transacties.unshift(ntx);
			$scope.tx = new Transactie();
		}, function(errs){
			/* oops */
			$(".transactieForm .alert").addClass("alert-error").show();
			$(".transactieForm .alert span").text("Foutje, niet zo best, transactie is niet opgeslagen<br/>"+ errs);
		});
	}
};
TransactiesCtrl.$inject = ['$scope', 'Transactie','$dialog','Globals','TransactieSoort','Valuta']

console.log("init done");
