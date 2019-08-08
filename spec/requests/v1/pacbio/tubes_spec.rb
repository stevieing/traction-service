require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  context '#get' do
    context 'pacbio tubes' do
      let!(:saphyr_library_tubes) { create_list(:tube_with_saphyr_library, 2)}
      let!(:pacbio_library_tubes) { create_list(:tube_with_pacbio_library, 3)}

      it 'returns a list of pacbio tubes' do
        get v1_pacbio_tubes_path, headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'].length).to eq(3)
      end
    end

    context 'when material is a request' do
      let!(:tube_with_saphyr_request) { create(:tube_with_saphyr_request)}
      let!(:tube_with_pacbio_request1) { create(:tube_with_pacbio_request)}
      let!(:tube_with_pacbio_request2) { create(:tube_with_pacbio_request)}

      it 'returns the correct attributes' do
        get v1_pacbio_tubes_path, headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)

        expect(json['data'][0]['attributes']['barcode']).to eq(tube_with_pacbio_request1.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("requests")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube_with_pacbio_request1.material.id.to_s)

        expect(json['data'][1]['attributes']['barcode']).to eq(tube_with_pacbio_request2.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("requests")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube_with_pacbio_request2.material.id.to_s)

      end
    end

    context 'when material is a library' do
      let!(:tube_with_saphyr_library) { create(:tube_with_saphyr_library)}
      let!(:tube_with_pacbio_library1) { create(:tube_with_pacbio_library)}
      let!(:tube_with_pacbio_library2) { create(:tube_with_pacbio_library)}

      it 'returns the correct attributes' do
        get v1_pacbio_tubes_path, headers: json_api_headers
        expect(response).to have_http_status(:success)
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data'][0]['attributes']['barcode']).to eq(tube_with_pacbio_library1.barcode)
        expect(json['data'][0]['relationships']['material']).to be_present
        expect(json['data'][0]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][0]['relationships']['material']['data']['id']).to eq(tube_with_pacbio_library1.material.id.to_s)

        expect(json['data'][1]['attributes']['barcode']).to eq(tube_with_pacbio_library2.barcode)
        expect(json['data'][1]['relationships']['material']).to be_present
        expect(json['data'][1]['relationships']['material']['data']['type']).to eq("libraries")
        expect(json['data'][1]['relationships']['material']['data']['id']).to eq(tube_with_pacbio_library2.material.id.to_s)
      end
    end

    describe 'filter' do
      context 'when filtering by barcode' do
        let(:tubes_with_request) { create_list(:tube_with_pacbio_request, 2)}

        it 'returns the correct tube' do
          barcode = tubes_with_request[0].barcode
          get "#{v1_pacbio_tubes_path}?filter[barcode]=#{barcode}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(1)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcode
        end
      end

      context 'filtering by barcodes' do
        let(:tubes_with_library) { create_list(:tube_with_pacbio_library, 4)}

        it 'returns the correct tubes' do
          barcodes = tubes_with_library.map(&:barcode)[0..1]
          get "#{v1_pacbio_tubes_path}?filter[barcode]=#{barcodes.join(',')}", headers: json_api_headers
          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data'].length).to eq(barcodes.length)
          expect(json['data'][0]["attributes"]["barcode"]).to eq barcodes[0]
          expect(json['data'][1]["attributes"]["barcode"]).to eq barcodes[1]
        end
      end
    end

    describe 'filter and include' do
      context 'when including material and the material is a request' do
        let(:tubes_with_request) { create_list(:tube_with_pacbio_request, 2)}

        it 'returns the request data' do
          tube = tubes_with_request[0]
          get "#{v1_pacbio_tubes_path}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers

          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          expect(json['data'].length).to eq(1)

          expect(json['included'][0]['id']).to eq tube.material.id.to_s
          expect(json['included'][0]['type']).to eq "requests"

          expect(json['included'][0]['attributes']['external_study_id']).to eq tube.material.external_study_id
          expect(json['included'][0]['attributes']['sample_name']).to eq tube.material.sample.name
          expect(json['included'][0]['attributes']['barcode']).to eq tube.barcode
          expect(json['included'][0]['attributes']['sample_species']).to eq tube.material.sample.species
          expect(json['included'][0]['attributes']['created_at']).to eq tube.material.sample.created_at.strftime('%m/%d/%Y %I:%M')

          expect(json['data'][0]['relationships']['material']['data']['type']).to eq 'requests'
          expect(json['data'][0]['relationships']['material']['data']['id']).to eq tube.material.id.to_s
        end
      end

      context 'when including material and the material is a library' do
        let(:tubes_with_library) { create_list(:tube_with_pacbio_library, 2)}

        it 'returns the request data' do
          tube = tubes_with_library[0]
          get "#{v1_pacbio_tubes_path}?filter[barcode]=#{tube.barcode}&include=material", headers: json_api_headers

          expect(response).to have_http_status(:success)
          json = ActiveSupport::JSON.decode(response.body)

          expect(json['data'].length).to eq(1)

          expect(json['included'][0]['id']).to eq tube.material.id.to_s
          expect(json['included'][0]['type']).to eq "libraries"

          expect(json['data'][0]['attributes']['barcode']).to eq tube.barcode
          expect(json['included'][0]['attributes']['volume']).to eq tube.material.volume
          expect(json['included'][0]['attributes']['concentration']).to eq tube.material.concentration
          expect(json['included'][0]['attributes']['library_kit_barcode']).to eq tube.material.library_kit_barcode
          expect(json['included'][0]['attributes']['fragment_size']).to eq tube.material.fragment_size

          expect(json['data'][0]['relationships']['material']['data']['type']).to eq 'libraries'
          expect(json['data'][0]['relationships']['material']['data']['id']).to eq tube.material.id.to_s
        end
      end
    end

  end

end
