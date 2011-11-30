class Product < ActiveRecord::Base
  validates_presence_of :title, :description, :image_url
  validates_numericality_of :price
  validate :price_must_be_at_least_a_cent
  validates_uniqueness_of :title
  validates_format_of :image_url, :with => %r{\.(gif|jpg|png)$}i,
    :message => 'must be a URL for GIF, JPG ' +
    'or PNG image.'
  validates_length_of :description, :in => 10..200, :too_short => "is too short", :too_long => "is too long"
  
  def self.find_products_for_sale
    find(:all, :order => "title" )
  end

  protected
  def price_must_be_at_least_a_cent
    # Takecare that you are in the model and it sees all the attributes of the model
    errors.add(:price, 'should be at least 0.01' ) if price.nil? || price < 0.01
  end
end
