require 'rails_helper'

describe RailsPages::Page::Loader do
  before do
    allow(Kernel).to receive(:load) do
      described_class.last_definition = ['route', proc { }, { meta: '1' }]
      true
    end
  end

  around do |example|
    # We want to refrain from re-loading the real page blocks during a test
    # suite run, because re-loading causes us to lose coverage information.
    old_page_blocks = described_class.page_blocks
    old_last_definition = described_class.last_definition

    described_class.page_blocks = nil
    described_class.last_definition = nil

    FakeFS do
      FileUtils.mkdir_p Rails.root.join('app/pages/page1')
      FileUtils.mkdir_p Rails.root.join('app/pages/nest/page2')
      FileUtils.mkdir_p Rails.root.join('drivers/test/app/pages/nest/page3')
      File.write(page1_def, 'puts "test1"')
      File.write(page2_def, 'puts "test2"')
      File.write(page3_def, 'puts "test3"')
      File.write(nonpage_file, 'dont execute me')

      example.run
    end

  ensure
    # Restore previous values to retain coverage info.
    described_class.page_blocks = old_page_blocks
    described_class.last_definition = old_last_definition
  end

  let(:page1_def) { Rails.root.join('app/pages/page1/page.rb') }
  let(:page2_def) { Rails.root.join('app/pages/nest/page2/page.rb') }
  let(:page3_def) { Rails.root.join('drivers/test/app/pages/nest/page3/page.rb') }
  let(:nonpage_file) { Rails.root.join('app/pages/nest/notapage.rb') }

  describe '.load_pages' do
    it 'populates .page_blocks with Page instances' do
      result = described_class.load_pages

      expect(result.size).to eq 2

      expect(result['page1'].id).to eq 'page1'
      expect(result['nest/page2'].id).to eq 'nest/page2'

      expect(result['page1'].route).to eq 'route'
      expect(result['nest/page2'].route).to eq 'route'

      expect(result['page1'].metadata[:meta]).to eq '1'
      expect(result['nest/page2'].metadata[:meta]).to eq '1'
    end

    it 'undoes the previous result when called twice in development' do
      allow(Rails.env).to receive(:development?).and_return true

      result = described_class.load_pages
      expect(result.size).to eq 2

      result = described_class.load_pages
      expect(result.size).to eq 2

      expect(Kernel).to have_received(:load).exactly(4).times
    end

    it 'loads the page.rb files' do
      result = described_class.load_pages
      expect(result.size).to eq 2

      expect(Kernel).to have_received(:load).with(page1_def.to_s)
      expect(Kernel).to have_received(:load).with(page2_def.to_s)
    end

    it 'loads driver pages when Rails paths have been updated' do
      allow(Rails.application.config).to receive(:paths).and_return(
        'app' => ['app', 'drivers/test/app']
      )

      result = described_class.load_pages
      expect(result.size).to eq 3

      expect(Kernel).to have_received(:load).with(page1_def.to_s)
      expect(Kernel).to have_received(:load).with(page2_def.to_s)
      expect(Kernel).to have_received(:load).with(page3_def.to_s)
    end

    it 'raises an error when called twice outside of development env' do
      result = described_class.load_pages
      expect(result.size).to eq 2

      expect { described_class.load_pages }
        .to raise_error(/Maybe try lazy_load_pages instead/)
    end
  end

  describe '.lazy_load_pages' do
    it 'populates .page_blocks with Page instances only on first call' do
      result = described_class.lazy_load_pages
      expect(result.size).to eq 2

      result = described_class.lazy_load_pages
      expect(result.size).to eq 2

      expect(Kernel).to have_received(:load).exactly(2).times
    end
  end
end
