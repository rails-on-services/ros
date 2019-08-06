# frozen_string_literal: true

class PlatformEventProcessor
  def self.storage_upload(urn:, event:, data:)
puts 'XXXXX'
puts data
puts 'XXXXX'
Ros::Infra.tenant_storage.get(data['remote_path'])
local_path = "#{Rails.root}/tmp/#{data['remote_path']}"
    # Use abstracted get to get teh file from remote storage
    User.load_csv(local_path, data['column_map'], true)
    # binding.pry
  end
end

=begin
[4] [cognito][development][222_222_222] pry(PlatformEventProcessor)> data =>
{"id"=>46,
 "name"=>"survey_customers_20190608.csv",
 "etag"=>"d41d8cd98f00b204e9800998ecf8427e",
 "size"=>1024,
 "transfer_map_id"=>1,
 "created_at"=>"2019-06-10T08:47:09.345Z",
 "updated_at"=>"2019-06-10T08:47:09.345Z",
 "urn"=>"urn:perx:storage::222222222:upload/46",
 "target"=>"user",
 "remote_path"=>"home/222222222/uploads/survey_customers_20190608.csv",
 "column_map"=>
  {"title"=>"Salutation",
   "last_name"=>"Last Name",
   "phone_number"=>"Mobile",
   "primary_identifier"=>"Unique Number",
   "pool_name"=>"Campaign"}}
=end
