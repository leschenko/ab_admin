require 'spec_helper'

describe ::ActiveModel::Validations::EmailValidator do
  [
      'first@example.com',
      'first@i.com',
      'first+@i.com',
      '+first@i.com',
      'firs++t@i.com',
      'first@ii.com',
      'first@i-i.com',
      '_first@example.com',
      '-first@example.com',
      'first.second@example.com',
      'first.-second@example.com',
      'first@example.museum',
      'first-second@example.com',
      'first@subdomain.example.com'
  ].each do |email|
    it "email #{email} valid" do
      subject = build_email_validation_record(email: email)
      expect(subject.valid?).to eq true
    end
  end

  [
      '.first@example.com',
      'first.@example.com',
      'first@Example.museum',
      'first@example.abc1',
      'first@example.Com',
      'first@.example.com',
      'first@-example.com',
      'first@example-.com',
      'framm@0c6e7542-c601-0410-84e7-c038aed88b3b'
  ].each do |email|
    it "email #{email} invalid" do
      subject = build_email_validation_record(email: email)
      expect(subject.valid?).to eq false
    end
  end

  def build_email_validation_record(attrs = {})
    ValidatorTestRecord.reset_callbacks(:validate)
    ValidatorTestRecord.validates :email, email: true
    ValidatorTestRecord.new attrs
  end
end