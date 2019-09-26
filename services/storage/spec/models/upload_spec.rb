# frozen_string_literal: true

require 'rails_helper'
require 'net/sftp'

RSpec.describe Upload, type: :model, skip: true do
  let(:sftp_host) { 'sftp' }
  let(:tenant_id) { '222222222' }
  let(:tenant_password) { 'pass' }
  let(:file_name) { 'text5.txt' }

  # TODO: Create fixtures for CSV files for Users
  it 'can upload and download a file to/from the SFTP server', skip: true do
    File.open(file_name, 'w') { |file| file.write('test text') }
    expect(File).not_to exist("#{file_name}.download")

    Net::SFTP.start(sftp_host, tenant_id, password: tenant_password) do |sftp|
      sftp.upload!(file_name, "/uploads/#{file_name}")
      sftp.download!("/uploads/#{file_name}", "#{file_name}.download")
    end

    expect(File).to exist("#{file_name}.download")
    expect(`diff #{file_name} #{file_name}.download`.size).to eq(0)
    Dir.glob("#{file_name}*") { |file| File.delete(file) }
  end
end
