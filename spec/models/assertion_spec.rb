require 'rails_helper'

RSpec.describe Assertion, type: :model do
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:status) }
  it { should validate_numericality_of(:links_number).only_integer }
  it { should validate_numericality_of(:images_number).only_integer }

  it { should have_db_column(:url).of_type(:string) }
  it { should have_db_column(:text).of_type(:string) }
  it { should have_db_column(:status).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
  it { should have_db_column(:links_number).of_type(:integer) }
  it { should have_db_column(:images_number).of_type(:integer) }
end
