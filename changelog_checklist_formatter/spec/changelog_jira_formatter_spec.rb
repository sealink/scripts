require 'rspec'
require_relative '../lib/changelog_checklist'

describe 'changelog formatter' do
  let(:version_series) { '' }
  let(:formatter) { ChangelogChecklist.new(version_series) }

  context 'when the version series is 4.63.0' do
    let(:version_series) { '4.63.0' }
    let(:output1) {
      "|4.63.0| |\n"\
      "|*Internal*| |\n"\
      "|[TT-569] Use the tagged base image to improve traceability| |\n"
    }
    it 'the ChangeLog table will be formatted as output1' do
      expect(formatter.to_table).to eq output1
    end
  end

  context 'when the version series is 4.51.2' do
    let(:version_series) { '4.51.2' }
    let(:output2) {
      "|4.51.2| |\n"\
      "|*Internal*| |\n"\
      "|Updates base docker image to address dojo loading issue| |\n"\
    }
    it 'the ChangeLog table will be formatted as output2' do
      expect(formatter.to_table).to eq output2
    end
  end

  context 'when the version series is 4.51' do
    let(:version_series) { '4.51' }
    let(:output3) {
      "|4.51.3| |\n"\
      "|*Internal*| |\n"\
      "|Updates config version to 2.1\n"\
      "4.51.2| |\n"\
      "|*Internal*| |\n"\
      "|Updates base docker image to address dojo loading issue\n"\
      "4.51.1| |\n"\
      "|*Internal*| |\n"\
      "|Fixes application launch issue\n"\
      "4.51.0| |\n"\
      "|*API*| |\n"\
      "|Implements Vouchers API| |\n"\
      "|*Internal*| |\n"\
      "|Fixes issue with CreditLink redeem API| |\n"\
      "|Adds support for CreditLink voucher deactivate API| |\n"\
      "|*Front Office*| |\n"\
      "|Bookings: When adding multiple vehicles and trailers, trailers will now be assigned correctly| |\n"\
      "|*Admin*| |\n"\
      "|No longer require services at the product type level (Migration)| |\n"\
      "|Clarify cargo when creating/editing vehicle types| |\n"
    }
    it 'the ChangeLog table will be formatted as output3' do
      expect(formatter.to_table).to eq output3
    end
  end
end
