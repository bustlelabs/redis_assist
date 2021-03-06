require 'spec_helper'
require 'redis_assist'

class TestTransform < RedisAssist::Transform; end

class TestModel < RedisAssist::Base
  attr_persist :truthy, as: :boolean
  attr_persist :floaty, as: :float
  attr_persist :mathy,  as: :integer
  attr_persist :parsy,  as: :json
  attr_persist :timing, as: :time
  attr_persist :zero,   as: :integer
end

describe TestTransform do
  let(:transform) { TestTransform }
  let(:val)       { rand(120320230).to_s }
  subject         { transform }
  its(:key)       { should eq :test }
  it              { subject.from(val).should eq val }
  it              { subject.to(val).should eq val }
end

describe TestModel do
  let(:truthy)  { rand(1).eql?(0) ? true : false }
  let(:floaty)  { Math::PI }
  let(:mathy)   { rand(100) }
  let(:parsy)   { { 'hi' => 'hi', 'number' => mathy, 'bool' => truthy, 'float' => floaty } }
  let(:timing)  { Time.now }
  let(:attrs)   { { truthy: truthy, floaty: floaty, mathy: mathy, parsy: parsy, timing: timing } }
  let(:model)   { TestModel.new(attrs) }

  context "saved" do
    before        { model.save }
    let(:found)   { TestModel.find(model.id) }
    subject       { found }
    its(:truthy)  { should eq truthy } 
    its(:floaty)  { should eq floaty } 
    its(:mathy)   { should eq mathy } 
    its(:parsy)   { should eq parsy } 
    its(:timing)  { timing.eql?(model.timing).should } 
  end

  context "nil json" do
    let(:parsy)   { nil }
    let(:model)   { TestModel.new(attrs) }
    before        { model.save }
    subject       { model }
    its(:parsy)   { should be nil }
  end

  context "integer" do
    let(:mathy) { nil }
    let(:model) { TestModel.new(attrs) }
    before      { model.save }
    its(:mathy) { should be nil }
    let(:found) { TestModel.find(model.id) }
    it "retains nil integer" do
      found.mathy.should be nil
    end
  end

  context "time parsing" do
    subject { model }
    let(:new_time) { Time.now }
    before do
      model.timing = new_time.to_s
      model.save
    end

    its(:timing) { subject.timing.to_s.should eq new_time.to_s }
  end
end
