require 'rails_helper'

RSpec.describe Map, type: :model do
  context 'Attributes' do
    it { is_expected.to respond_to :title }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :imprint }
    it { is_expected.to respond_to :public }
    it { is_expected.to respond_to :public_token }
    it { is_expected.to respond_to :secret_token }
  end

  context 'Callbacks' do
    it 'should create secret token on create for public maps' do
      map = create :map, :public
      expect(map.secret_token).to be_a(String)
    end

    it 'should create public token on create for public maps' do
      map = create :map, :public
      expect(map.public_token).to be_a(String)
    end

    it 'should create secret token on create for private maps' do
      map = create :map, :private
      expect(map.secret_token).to be_a(String)
    end
  end

  context 'Associations' do
    it { is_expected.to have_many :places }
  end
end
