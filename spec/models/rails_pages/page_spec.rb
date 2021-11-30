require 'rails_helper'

describe RailsPages::Page, type: :model do
  around do |example|
    # We want to refrain from re-loading the real page blocks during a test
    # suite run, because re-loading causes us to lose coverage information.
    old_page_blocks = RailsPages::Page::Loader.page_blocks
    old_last_definition = RailsPages::Page::Loader.last_definition

    RailsPages::Page::Loader.page_blocks = nil
    RailsPages::Page::Loader.last_definition = nil

    example.run
  ensure
    # Restore previous values to retain coverage info.
    RailsPages::Page::Loader.page_blocks = old_page_blocks
    RailsPages::Page::Loader.last_definition = old_last_definition
  end

  describe '.all' do
    it 'calls RailsPages::Page::Loader.load_pages' do
      page1 = described_class.new('test/one', 'my/route', proc {  })
      page2 = described_class.new('test/two', 'my/route', proc {  })

      allow_any_instance_of(RailsPages::Page::Loader).to receive(:load_pages)
        .and_return('test/one' => page1, 'test/two' => page2)

      expect(described_class.all).to eq [page1, page2]
    end

    it 'returns existing values from RailsPages::Page::Loader.page_blocks' do
      page1 = described_class.new('test/one', 'my/route', proc {  })
      page2 = described_class.new('test/two', 'my/route', proc {  })

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'test/two' => page2
      }

      expect(described_class.all).to eq [page1, page2]
    end
  end

  describe '.each' do
    it 'simply loops through .all' do
      page1 = described_class.new('test/one', 'my/route', proc {  })
      page2 = described_class.new('test/two', 'my/route', proc {  })

      allow(described_class).to receive(:all).and_return [page1, page2]

      accumulator = []
      described_class.each { |page| accumulator << page }
      expect(accumulator).to eq [page1, page2]
    end
  end

  describe '.find' do
    it 'pulls by ID from RailsPages::Page::Loader.page_blocks' do
      page1 = described_class.new('test/one', 'my/route', proc {  })
      page2 = described_class.new('test/two', 'my/route', proc {  })

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'test/two' => page2
      }

      expect(described_class.find('test/one')).to eq page1
      expect(described_class.find('test/two')).to eq page2
    end
  end

  describe '.where' do
    it 'pulls by metadata from RailsPages::Page::Loader.page_blocks' do
      page1 = described_class.new('test/one', 'my/route', proc {  }, one: 'two')
      page2 = described_class.new('test/two', 'my/route', proc {  }, one: 'two')
      page3 = described_class.new('test/three', 'my/route', proc { }, one: 'three')

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'test/two' => page2,
        'test/three' => page3
      }

      expect(described_class.where(one: 'two')).to match_array [page1, page2]
      expect(described_class.where(one: 'three')).to match_array [page3]
      expect(described_class.where(one: 'none')).to match_array []
    end

    it 'lets me pass a block' do
      page1 = described_class.new('test/one', 'my/route', proc {  })
      page2 = described_class.new('out/two', 'my/route', proc {  })
      page3 = described_class.new('test/three', 'my/route', proc { })

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'out/two' => page2,
        'test/three' => page3
      }

      expect(described_class.where { |p| p.id.start_with?('test') })
        .to match_array [page1, page3]
    end
  end

  describe '.[]' do
    it 'lets me search by regex' do
      page1 = described_class.new('test/one', 'my/route', proc {  }, one: 'two')
      page2 = described_class.new('wrong/two', 'my/route', proc {  }, one: 'two')
      page3 = described_class.new('test/three', 'my/route', proc { }, one: 'three')

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'wrong/two' => page2,
        'test/three' => page3
      }

      expect(described_class[/^test/]).to match_array [page1, page3]
    end
  end

  describe '.find_by' do
    it 'pulls 1 page by metadata from RailsPages::Page::Loader.page_blocks' do
      page1 = described_class.new('test/one', 'my/route', proc {  }, one: 'two')
      page2 = described_class.new('test/two', 'my/route', proc {  }, one: 'two')
      page3 = described_class.new('test/three', 'my/route', proc { }, one: 'three')

      RailsPages::Page::Loader.page_blocks = {
        'test/one' => page1,
        'test/two' => page2,
        'test/three' => page3
      }

      expect(described_class.find_by(one: 'two')).to eq page1
      expect(described_class.find_by(one: 'three')).to eq page3
      expect(described_class.find_by(one: 'none')).to be_nil
    end
  end

  describe '.define' do
    it 'populates RailsPages::Page::Loader.last_definition with the route and block' do
      block = proc { raise 'this should not be executed' }

      expect do
        described_class.define('/path/:id', one: 'two', &block)
      end
        .to change { RailsPages::Page::Loader.last_definition }
        .from(nil)
        .to(['/path/:id', block, { one: 'two' }])
    end
  end

  describe '#inspect' do
    it 'returns #<RailsPages::Page:id>' do
      page = described_class.new('this/page/id', 'my/route', proc { })
      expect(page.inspect).to eq '#<RailsPages::Page:this/page/id>'
    end
  end

  describe '#infect' do
    let(:target) do
      Class.new do
        include RailsPages::Page::DSL
      end.new
    end

    it "populates the target's #before_blocks from the DSL" do
      dsl_block = proc do
        before do
          'hey!!'
        end
      end
      page = described_class.new('test/page/id', 'test/route', dsl_block)

      expect { page.infect(target) }
        .to change { target.before_blocks }
        .from(nil)
        .to([instance_of(Proc)])

      expect(target.before_blocks.first.call).to eq 'hey!!'
    end

    it "populates the target's #authorize_blocks from the DSL" do
      dsl_block = proc do
        authorize do
          'auth!'
        end
      end
      page = described_class.new('test/page/id', 'test/route', dsl_block)

      expect { page.infect(target) }
        .to change { target.authorize_blocks }
        .from(nil)
        .to([instance_of(Proc)])

      expect(target.authorize_blocks.first.call).to eq 'auth!'
    end

    it "populates the target's #data_block from the DSL" do
      dsl_block = proc do
        data do
          { test: 'test' }
        end
      end
      page = described_class.new('test/page/id', 'test/route', dsl_block)

      expect { page.infect(target) }
        .to change { target.data_block }
        .from(nil)
        .to(instance_of(Proc))

      expect(target.data_block.call).to eq(test: 'test')
    end

    it "populates the target's #get_blocks from the DSL" do
      dsl_block = proc do
        get '/test' do
          { test: 'test' }
        end
      end
      page = described_class.new('test/page/id', 'test/route', dsl_block)

      expect { page.infect(target) }
        .to change { target.get_blocks }
        .from(nil)
        .to('/test' => instance_of(Proc))

      expect(target.get_blocks['/test'].call).to eq(test: 'test')
    end

    it "populates the target's #post_blocks from the DSL" do
      dsl_block = proc do
        post '/test' do
          { test: 'test' }
        end
      end
      page = described_class.new('test/page/id', 'test/route', dsl_block)

      expect { page.infect(target) }
        .to change { target.post_blocks }
        .from(nil)
        .to('/test' => instance_of(Proc))

      expect(target.post_blocks['/test'].call).to eq(test: 'test')
    end
  end
end
