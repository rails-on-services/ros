# frozen_string_literal: true

class User < Cognito::ApplicationRecord
  has_many :user_pools
  has_many :pools, through: :user_pools

  def self.convert
    { 'Salutation' => :title, 'Last Name' => :last_name, 'Mobile' => :phone_number,
      'Unique Number' => :primary_identifier, 'Campaign Code' => :pool_name }
  end

  def self.reset
    UserPool.delete_all
    Pool.delete_all
    User.delete_all
  end

  def self.file_fingerprint_attributes
    column_names + [:pool_name]
  end

  # User.load_csv('/home/admin/prudential.csv', true)
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Rails/Output
  def self.load_csv(file_name, create = false)
    CSV.foreach(file_name, headers: true, header_converters: ->(name) { convert[name] }) do |row|
      if create
        pool = Pool.find_or_create_by(name: row[:pool_name])
        # row[:phone_number] = "+#{row[:phone_number]}"
        row = row.to_h.except(:pool_name)
        user = User.find_or_create_by(primary_identifier: row[:primary_identifier])
        user.update(row.slice(:title, :last_name, :phone_number))
        pool.users << user
      else
        # rubocop:disable Rails/Output
        puts "title: #{row[:title]} phone_number: #{row[:phone_number]} last_name: #{row[:last_name]} " \
          "id: #{row[:primary_identifier]} pool: #{row[:pool_name]}"
        # rubocop:enable Rails/Output
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Rails/Output
end
