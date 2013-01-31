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
		when('/rapporten',
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
	factory('Boek',function ($resource) {
		console.log('boekSvc');
		return $resource('/boeken/:boekId', {}, {
			query:{method:'GET', params:{boekId:''}, isArray:true}
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
			query:{method:'GET', params:{transactieId:'all'}, isArray:true}
		});
	}).factory('Globals',function($resource){
		console.log('Globals');
		return {
			actiefBoek: "x"
		};
	});

/*******************************************************************************
 *
 * Controllers
 *
 ******************************************************************************/

function WelkomCtrl($scope) {
	console.log('WelkomCtrl');
	$scope.kiesBoek = function(){
		console.log("kiesBoek2");
	}
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

/******************************* RapportenCtrl ********************************/

function RapportenCtrl($scope, Rapport,Globals) {
	console.log('RapportenCtrl');
	$scope.qryBegindatum = "01/01/2000";
	$scope.qryEinddatum = "01/01/2014";
	$scope.qryValuta = "EUR";
	$scope.qryRapporttype = "inkomsten";
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
					valuta:$scope.qryValuta},
				function () {
					console.log("rapport query result: ");
				});
	};
	$scope.toonRapport();
};

RapportenCtrl.$inject = ['$scope','Rapport','Globals']

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

function TransactiesCtrl($scope, Transactie, $dialog,Globals) {
	console.log('TransactiesCtrl');
	$scope.offset = 0;
	$scope.limit = 100;
	$scope.f_datum = "";
	$scope.f_omschrijving = "";
	$scope.f_bonnummer = "";
	$scope.f_rekeningnummer = "";
	$scope.f_afbij = "";
	$scope.f_valuta = "";
	$scope.f_bedragexclbtw = "";
	$scope.f_bedraginclbtw = "";
	$scope.f_btwpercentage = "";
	$scope.f_transactiesoort = "";
	$scope.f_kilometers = "";
	$scope.refresh = function(){
		$scope.transacties = Transactie.query(
			{ 	offset:$scope.offset,
			  	limit:$scope.limit,
			  	boekId:Globals.actiefBoek,
			  	datum: $scope.f_datum,
			  	omschrijving: $scope.f_omschrijving,
				bonnummer: $scope.f_bonnummer,
				rekeningnummer: $scope.f_rekeningnummer,
				afbij: $scope.f_afbij,
				valuta: $scope.f_valuta,
				bedragexclbtw: $scope.f_bedragexclbtw,
				bedraginclbtw: $scope.f_bedraginclbtw,
				btwpercentage: $scope.f_btwpercentage,
				transactiesoort: $scope.f_transactiesoort,
				kilometers: $scope.f_kilometers
			},
			function(){
				$scope.transactiesCount = $scope.transacties.length;
			}
		);
	};
	$scope.toevoegPopup = function(){
		var d = $dialog.dialog({
				templateUrl: '/partials/transactie_modal.html',
				controller: 'EditTransactieCtrl'
			});
		    d.open().then(function(result){
		      if(result)
		      {
		        alert('dialog closed with result: ' + result);
		      }
		    });
	};
};
TransactiesCtrl.$inject = ['$scope', 'Transactie','$dialog','Globals']

function EditTransactieCtrl($scope, dialog) {
	$scope.tx = {};
	$scope.transactieOpslaan = function(tx){
		console.log("transactieOpslaan: " + tx);
		dialog.close(tx);
	}
};

console.log("init done");
