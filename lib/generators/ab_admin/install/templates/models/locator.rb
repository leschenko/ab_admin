# -*- encoding : utf-8 -*-
class Locator < ActiveRecord::Base

  def self.find(*args)
    first
  end

  def title
    ''
  end

end

# == Schema Information
#
# Table name: locators
#
#  id :integer          not null, primary key
#

