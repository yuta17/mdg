require 'active_record'

module Mdg
  class Command

    def self.run(argv)
      new(argv).execute
    end

    def initialize(argv)
      @argv = argv
    end

    def execute
      options = Options.parse!(@argv)
      sub_command = options.delete(:command)

      if sub_command == 'server'
        puts 'Start server process...'
        port_option = options[:port].nil? ? '' : "-p #{options[:port]}"

        config = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config.ru'))
        exec "cd #{File.dirname(config)} && rackup -E production #{port_option} #{config}"
      end

      DB.prepare

      deeds = case sub_command
              when 'create'
                create_deed(options[:content], options[:hour])
              when 'delete'
                delete_deed(options[:id])
              when 'update'
                update_deed(options[:id], options)
              when 'list'
                list_deed
              end
      display_deeds deeds

    rescue => e
      abort "Error: #{e.message}"
    end

    def list_deed
      Deed.order('created_at DESC')
    end

    def create_deed(content, hour)
      ActiveRecord::Base.transaction do
        deed = Deed.create!(content: content, hour: hour)
        Timestamp.create!(deed_id: deed.id, totaltime: deed.hour)
        deed
      end
    end

    def delete_deed(id)
      deed = Deed.find(id)
      deed.destroy
    end

    def update_deed(id, attributes)
      deed = Deed.find(id)
      attributes[:hour] = deed.hour + attributes[:hour].to_f
      today_range = Date.today.beginning_of_day..Date.today.end_of_day

      ActiveRecord::Base.transaction do
        deed.update_attributes! attributes
        Timestamp.where(deed_id: deed.id).where(created_at: today_range).delete_all
        Timestamp.create!(deed_id: deed.id, totaltime: attributes[:hour])
      end

      deed
    end

    private

    def display_deeds(deeds)
      header = display_format('ID', 'Content', 'Total Time')

      puts header
      puts '-' * header.size
      Array(deeds).each do |deed|
        puts display_format(deed.id, deed.content, deed.hour)
      end
    end

    def display_format(id, content, hour)
      [id.to_s.rjust(4), content.ljust(38), hour.to_s.ljust(11)].join(' | ')
    end
  end
end
