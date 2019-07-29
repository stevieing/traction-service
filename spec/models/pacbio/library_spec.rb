require 'rails_helper'

RSpec.describe Pacbio::Library, type: :model, pacbio: true do

  it 'must have a volume' do
    expect(build(:pacbio_library, volume: nil)).to_not be_valid
  end

  it 'must have a concentration' do
    expect(build(:pacbio_library, concentration: nil)).to_not be_valid
  end

  it 'must have a library kit barcode' do
    expect(build(:pacbio_library, library_kit_barcode: nil)).to_not be_valid
  end

  it 'must have a fragment size' do
    expect(build(:pacbio_library, fragment_size: nil)).to_not be_valid
  end

  it 'must have a tag' do
    expect(build(:pacbio_library, tag: nil)).to_not be_valid
  end

  it 'will have a uuid' do
    expect(create(:pacbio_library).uuid).to be_present
  end

  context 'wells' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      library.wells << create_list(:pacbio_well, 5)
      expect(library.wells.count).to eq(5)
    end
  end

  context 'wells' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      library.wells << create_list(:pacbio_well, 5)
      expect(library.wells.count).to eq(5)
    end
  end

  context 'requests' do
    it 'can have one or more' do
      library = create(:pacbio_library)
      create_list(:pacbio_request_library, 5, request: create(:pacbio_request), library: library, tag: create(:tag))
      expect(library.requests.count).to eq(5)
    end
  end
  
end