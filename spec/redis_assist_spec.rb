require 'spec_helper'

describe Person do
  let(:first)           { 'Bobby' }
  let(:last)            { 'Brown' }
  let(:birthday)        { Time.parse('4/10/1972') }
  let(:toys)            { ['GameBoy', 'Nintendo', 'Stuffed Animal'] }
  let(:info)            { { "happy" => 'yes', "hair" => 'Brown' } }
  let(:favorite_number) { 666 }
  let(:attrs)           { { first: first, last: last, birthday: birthday, toys: toys, favorite_number: favorite_number, info: info } }
  let(:person)          { Person.new(attrs) }

  subject { person }

  context "saving" do
    describe "#create" do
      let(:person)  { Person.create(attrs) }
      subject       { person }
      its(:id)      { should }
      it            { subject.new_record?.should_not }
    end

    describe ".save" do
      before    { person.save }
      its(:id)  { should }
      it        { subject.new_record?.should_not }
    end

    describe ".valid?" do
      let(:bad_attrs) { attrs.merge(first: 'RJ') }
      subject         { Person.new(bad_attrs) }
      its(:save)      { should_not }
      its(:errors)    { subject.errors.empty?.should_not }
      it              { subject.valid?.should_not }
    end
  end

  context "finding" do
    before { person.save }

    describe "#find" do
      let(:found)   { Person.find(person.id) }
      subject       { found }
      its(:id)      { should eq person.id }

      context "finding deleted" do
        before  { subject.delete }
        it { Person.find(subject.id).should_not }
        it { Person.find(subject.id, deleted: true).id.should eq subject.id}
      end
    end

    describe "#find_by_id" do
      let(:found)   { Person.find_by_id(person.id) }
      subject       { found }
      its(:id)      { should eq person.id }
      its(:first)   { should eq person.first }
      it            { Person.find_by_id("fakeid").should eq nil }
    end

    describe "#find_by_ids" do
      let(:second_person) { Person.new(attrs.merge(first: 'Garth', last: 'Portrais')) }
      before do
        second_person.save
        person.save
      end
      it { Person.find_by_ids([person.id, second_person.id]).is_a?(Array).should }
      it { Person.find_by_ids([person.id, second_person.id]).length.should eq 2 }
      it { Person.find_by_ids(["fakefuckingid"]).should eq [] }
    end

    describe "#find_in_batches" do
      it "should find batches" do
        Person.find_in_batches(batch_size: 1) do |batch|
          batch.should be_kind_of(Array)
        end
      end
    end

    describe "#all" do
      subject { Person.all }

      its(:length) { should eq Person.count }
    end

    describe "#exists?" do
      subject { person }
      it      { Person.exists?(person.id).should }
      it      { Person.exists?(rand(123456789)).should_not }
    end
  end

  context "updating" do
    describe ".save" do
      before do 
        person.save 
        person.first = 'Garth'
        person.save
      end

      subject     { Person.find(person.id) }
      its(:first) { should eq 'Garth' }
    end

    describe "#update" do
      before do 
        person.save
        Person.update(person.id, last: 'Dick Brain', birthday: birthday, toys: ['matchless car'], info: { 'super' => 'cool' })
      end

      subject           { Person.find(person.id) }
      its(:birthday)    { should eq birthday }
      # its(:last)        { should eq 'Dick Brain' }
      # its(:info)        { should eq({ 'super' => 'cool' }) }
    end

    describe ".update_columns" do
      let(:info)              { { 'super' => 'not cool' } }
      let(:updated_birthday)  { Time.now }

      before do
        person.save
        person.update_columns(last: 'McCann', toys: ['Game Genie'], info: info, birthday: updated_birthday)
      end

      subject         { Person.find(person.id) }
      its(:last)      { should eq 'McCann' }
      its(:toys)      { should eq ['Game Genie'] }
      its(:info)      { should eq info }
      it "should transform the value"  do 
        subject.birthday.to_f.should eq updated_birthday.to_f
      end
    end
  end

  context "attribute type conversion" do
    before  { person.save }
    subject { Person.find(person.id) }

    its(:first)       { should eq first }
    its(:birthday)    { should eq birthday }
    its(:toys)        { should eq toys }
    its(:info)        { should eq info }
  end

  context "attribute default value" do
    before      { person.save }
    it "retains string default" do
      subject.title.should  eq "Runt" 
    end

    it "retains transformed default" do
      subject.zero.should eq 0
      subject.hundred.should eq 100
    end
  end

  context "deleting" do
    describe ".delete" do
      before do
        person.save
        person.delete
      end

      subject { Person.find_by_id(person.id) }

      it { should_not }
    end

    describe ".undelete" do
      before do
        person.save
        person.delete
        person.undelete
      end

      subject { Person.find_by_id(person.id) }

      it { should }
      its(:deleted?) { should_not }
    end
  end

  context "associations" do
    before { person.save }
  end
end
