
Dir[Pathname.new(Dir.pwd).join('spec', 'factories', '**', '*.rb')].each { |f| require f }
