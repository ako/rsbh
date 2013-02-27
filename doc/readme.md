# Boekhouding

## Installatie gebruikte frameworks

Beheer van de ruby tooling gaat met [rvm][1]. Uitgebreide uitleg: [Get started right with RVM][2]
Zelf installeren (dus niet via apt-get) is aanbevolen aanpak, zie: [Ubuntu, Ruby, RVM, Rails, and You][4]

Stappen voor installatie:

1. Installeer rvm:

        $ curl -L https://get.rvm.io | bash -s stable --ruby

2. Installeer Ruby via rvm:

        $ rvm install 1.9.3

3. Definieer een gemset

        $ rvm use 1.9.3@boekhouding --create

4. Installeer dependencies van het project:

        $ gem install sinatra
        $ gem install data_mapper
        $ gem install dm-postgres-adapter
        $ gem install kramdown
        $ gem install dm-ar-finders
        $ gem install toml

## HTML documentatie genereren

    $ kramdown readme.md

## Configuratie

1. Database configureren - Staat nu nog hard gecodeerd in BoekhoudingApp.rb. Pas
   de volgende regel aan:

       DataMapper.setup(:default, 'postgres://bh2:bh2@localhost/bh2dev')

## Applicatie starten

Start de applicatie als volgt:

    $ ruby BoekhoudingApp.rb

Je kunt de applicatie nu in een browser openen met de url: [http://localhost:4567/index.html][3]

## Technische info

Technische opzet is als volgt:

- Rest service voor de boekhouding objecten:
  - Ruby - dynamische programmeer taal
  - Sinatra - thin web framework, implementatie rest services
  - data_mapper - OMR framework, communicatie ruby met postgres
- Single page javascript web applicatie:
  - Angularjs - javascript mvc raamwerk
  - Bootstrap - layout en ui componenten
  - jquery - javascript dom abstractie

  [1]: https://rvm.io/
  [2]: http://sirupsen.com/get-started-right-with-rvm/
  [3]: http://localhost:4567/index.html
  [4]: http://ryanbigg.com/2010/12/ubuntu-ruby-rvm-rails-and-you/