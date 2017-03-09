require 'active_record'

module Mdg
  class Deed < ActiveRecord::Base
    has_many :timestamps, dependent: :destroy

    validates :content, presence: true, length: { maximum: 140 }
    validates :hour,    presence: true, numericality: true
  end
end
