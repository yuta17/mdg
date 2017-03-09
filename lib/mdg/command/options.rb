require 'optparse'

module Mdg
  class Command
    module Options

      def self.parse!(argv)
        options = {}

        sub_command_parsers = create_sub_command_parsers(options)
        command_parser      = create_command_parser

        # 引数の解析を行う
        begin
          command_parser.order!(argv)

          options[:command] = argv.shift

          sub_command_parsers[options[:command]].parse! argv

          if %w(update delete).include?(options[:command])
            raise ArgumentError, "#{options[:command]} id not found." if argv.empty?
            options[:id] = Integer(argv.first)
          end
        rescue OptionParser::MissingArgument, OptionParser::InvalidOption, ArgumentError => e
          abort e.message
        end

        options
      end

      def self.create_sub_command_parsers(options)
        # サブコマンドの処理をする際に、未定義のkeyを指定されたら例外を発生させる
        sub_command_parsers = Hash.new do |_, v|
          raise ArgumentError, "'#{v}' is not ds sub command"
        end

        # サブコマンド用の定義
        sub_command_parsers['create'] = OptionParser.new do |opt|
          opt.banner = 'Usage: create <args>'
          opt.on('-c VAL', '--content=VAL', 'do content')     { |v| options[:content] = v }
          opt.on('-t VAL', '--time=VAL',    'do time (hour)') { |v| options[:hour] = v }
          opt.on_tail('-h', '--help', 'Show this message')    { help_sub_command(opt) }
        end

        sub_command_parsers['list'] = OptionParser.new do |opt|
          opt.banner = 'Usage: list'
          opt.on_tail('-h', '--help', 'Show this message') { help_sub_command(opt) }
        end

        sub_command_parsers['update'] = OptionParser.new do |opt|
          opt.on('-t VAL', '--time=VAL', 'update time (hour)') { |v| options[:hour] = v }
          opt.on_tail('-h', '--help', 'Show this message')     { help_sub_command(opt) }
        end

        sub_command_parsers['delete'] = OptionParser.new do |opt|
          opt.banner = 'Usage: delete id'
          opt.on_tail('-h', '--help', 'Show this message') { help_sub_command(opt) }
        end

        sub_command_parsers['server'] = OptionParser.new do |opt|
          opt.banner = 'Usage: server <args>'
          opt.on('-p VAL', '--port=VAL', 'Port(default:9292)') { |v| options[:hour] = v }
        end

        sub_command_parsers
      end

      def self.help_sub_command(parser)
        puts parser.help
        exit
      end

      def self.create_command_parser
        # サブコマンド以外の定義
        command_parser = OptionParser.new do |opt|
          sub_command_help = [
            { name: 'create -c content -t time (hour)',    summary: 'Create Do with time' },
            { name: 'update id -t time (hour)',            summary: 'Update total time' },
            { name: 'list',                                summary: 'Do List' },
            { name: 'delete id',                           summary: 'Delete Do' },
            { name: 'server -p port',                      summary: 'Start http server process' }
          ]

          opt.banner = "Usage: #{opt.program_name} [-h|--help] [-v|--version] <command> [<args]"
          opt.separator ''
          opt.separator "#{opt.program_name} Available Commands:"
          sub_command_help.each do |command|
            opt.separator [opt.summary_indent, command[:name].ljust(40), command[:summary]].join(' ')
          end

          opt.on_head('-h', '--help', 'Show this message') do
            puts opt.help
            exit
          end

          opt.on_head('-v', '--version', 'Show program version') do
            opt.version = Mdg::VERSION
            puts opt.ver
            exit
          end
        end
      end

      private_class_method :create_command_parser, :create_sub_command_parsers, :help_sub_command
    end
  end
end
