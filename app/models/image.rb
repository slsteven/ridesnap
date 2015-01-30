# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  url        :string
#  default    :boolean
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_images_on_vehicle_id  (vehicle_id)
#

class Image < ActiveRecord::Base
  belongs_to :vehicle

  after_destroy :remove_s3_record

  def image_url
    "#{Settings.aws.address}/#{self.vehicle.vin}/#{self.url}"
  end

private

  def remove_s3_record
    creds = ::Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key)
    s3 = ::Aws::S3::Resource.new(region: 'us-west-1', credentials: creds)
    bucket = s3.bucket(Settings.aws.bucket)
    img = bucket.object("#{self.vehicle.vin}/#{self.url}")
    img.delete
  end
end
