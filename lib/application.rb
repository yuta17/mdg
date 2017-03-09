require 'sinatra/base'
require 'active_record'
require 'haml'
require 'gruff'

require './lib/mdg/db'
require './lib/mdg/deed'
require './lib/mdg/timestamp'

module Mdg
  class Application < Sinatra::Base

    configure do
      DB.prepare
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get '/' do
      redirect '/mdg'
    end

    get '/mdg' do
      @deeds = Deed.all

      g = Gruff::Line.new
      g.title = 'My Graph'
      labels = {}
      n = 0

      @deeds.each do |deed|
        g.data(deed.content, deed.timestamps.map(&:totaltime))
        deed.timestamps.each do |t|
          date = t.created_at.strftime('%y/%m/%d')
          unless labels.value?(date)
            labels.store(n, date)
            n += 1
          end
        end
      end

      g.labels = labels
      g.write('./lib/public/my_graph.png')

      haml :index
    end
  end
end
