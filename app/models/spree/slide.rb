class Spree::Slide < ActiveRecord::Base

  has_and_belongs_to_many :slide_locations,
                          class_name: 'Spree::SlideLocation',
                          join_table: 'spree_slide_slide_locations'

  has_one_attached :image

  validate :check_image_presence
  validate :check_image_content_type

  scope :published, -> { where(published: true).order('position ASC') }
  scope :location, -> (location) { joins(:slide_locations).where('spree_slide_locations.name = ?', location) }

  belongs_to :product, touch: true, optional: true

  def initialize(attrs = nil)
    attrs ||= { published: true }
    super
  end

  def slide_name
    name.blank? && product.present? ? product.name : name
  end

  def slide_link
    link_url.blank? && product.present? ? product : link_url
  end

  private

  def check_image_presence
    unless image.attached?
      image.purge
      errors.add(:image, I18n.t(:image_must_be_present, scope: :spree_slider))
    end
  end

  def check_image_content_type
    if image.attached? && !image.content_type.in?(accepted_image_types)
      image.purge
      errors.add(:image, I18n.t(:image_invalid_content_type, scope: :spree_slider))
    end
  end

  def accepted_image_types
    %w(image/jpeg image/jpg image/png image/gif)
  end

end
