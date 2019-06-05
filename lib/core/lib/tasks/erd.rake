# frozen_string_literal: true

namespace :ros do
  namespace :erd do
    desc 'Generate an ERD'
    task :generate do
      Dir.chdir(Rails.root.to_s) do
        system 'bundle exec erd'
      end
    end
  end
end
