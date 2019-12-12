# frozen_string_literal: true

class User < Cognito::ApplicationRecord
  attribute :anonymous, :boolean, default: false

  enum gender: { male: 'm', female: 'f', other: 'o' }

  has_many :user_pools
  has_many :pools, through: :user_pools

  scope :birth_day, ->(date) { where("TO_CHAR(birthday, 'DD-MM') = TO_CHAR(DATE(?), 'DD-MM')", date) }
  scope :birth_month, ->(date) { where("TO_CHAR(birthday, 'MM') = TO_CHAR(DATE(?), 'MM')", date) }

  def self.reset
    UserPool.delete_all
    Pool.delete_all
    User.delete_all
  end

  def self.file_fingerprint_attributes
    column_names + %i[pool_name]
  end

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
        Rails.logger.debug "title: #{row[:title]} phone_number: #{row[:phone_number]} " \
          "last_name: #{row[:last_name]} id: #{row[:primary_identifier]} pool: #{row[:pool_name]}"
      end
    end
    true
  end

  def self.default_headers
    { 'Salutation' => :title, 'Last Name' => :last_name, 'Mobile' => :phone_number,
      'Unique Number' => :primary_identifier, 'Campaign Code' => :pool_name,
      'Birthday' => :birthday, 'Gender' => :gender }
  end
end
