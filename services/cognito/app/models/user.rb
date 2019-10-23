# frozen_string_literal: true

class User < Cognito::ApplicationRecord
  has_many :user_pools
  has_many :pools, through: :user_pools

  def self.reset
    UserPool.delete_all
    Pool.delete_all
    User.delete_all
  end

  def self.file_fingerprint_attributes
    column_names + %i[pool_name]
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Rails/Output
  def self.load_document(file_name, column_map = nil, create = false)
    column_map ||= default_headers
    column_map = column_map.invert.symbolize_keys.invert
    CSV.foreach(file_name, headers: true, header_converters: ->(name) { column_map[name] }) do |row|
      if create
        pool = Pool.find_or_create_by(name: row[:pool_name])
        # row[:phone_number] = "+#{row[:phone_number]}"
        row = row.to_h.except(:pool_name)
        user = User.find_or_create_by(primary_identifier: row[:primary_identifier])
        user.update(row.slice(:title, :last_name, :phone_number))
        pool.users << user
      else
        puts "title: #{row[:title]} phone_number: #{row[:phone_number]} last_name: #{row[:last_name]} " \
          "id: #{row[:primary_identifier]} pool: #{row[:pool_name]}"
      end
    end
    true
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Rails/Output

  def self.default_headers
    { 'Salutation' => :title, 'Last Name' => :last_name, 'Mobile' => :phone_number,
      'Unique Number' => :primary_identifier, 'Campaign Code' => :pool_name }
  end
end
