require 'spec_helper'

describe ::ActiveModel::Validations::DomainNameValidator do
  [
      'example.com',
      'i.com',
      'i-i.com',
      'example.museum',
      'subdomain.example.com'
  ].each do |domain|
    it "domain #{domain} valid" do
      subject = build_domain_validation_record(domain: domain)
      expect(subject.valid?).to eq true
    end
  end

  [
      '.example.com',
      'Example.museum',
      'example.abc1',
      '-example.com',
      'example-.com',
      '0c6e7542-c601-0410-84e7-c038aed88b3b'
  ].each do |domain|
    it "domain #{domain} invalid" do
      subject = build_domain_validation_record(domain: domain)
      expect(subject.valid?).to eq false
    end
  end

  def build_domain_validation_record(attrs = {})
    ValidatorTestRecord.reset_callbacks(:validate)
    ValidatorTestRecord.validates :domain, domain_name: true
    ValidatorTestRecord.new attrs
  end
end