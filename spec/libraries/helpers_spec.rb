# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe ChefDk::Helpers do
  describe '#metadata_for' do
    let(:options) { nil }
    let(:body) { nil }
    let(:res) { described_class.metadata_for(options) }

    before(:each) do
      uri = URI("https://omnitruck.chef.io/#{options[:channel]}/chefdk/" \
                "metadata?v=#{options[:version]}&p=#{options[:platform]}&" \
                "pv=#{options[:platform_version]}&" \
                "m=#{options[:machine]}")
      allow(Net::HTTP).to receive(:get).with(uri).and_return(body)
    end

    context 'a normal request and response' do
      let(:options) do
        {
          channel: 'stable',
          version: '1.2.3',
          platform: 'test',
          platform_version: '4.5.6',
          machine: 'x86_64'
        }
      end
      let(:body) do
        "sha1\tabcdef\nsha256\t123456\nurl\thttps://example.com/chefdk.pkg"
      end

      it 'returns the expected metadata' do
        expected = { sha1: 'abcdef',
                     sha256: '123456',
                     url: 'https://example.com/chefdk.pkg' }
        expect(res).to eq(expected)
      end
    end

    context 'no package found' do
      let(:options) do
        {
          channel: 'stable',
          version: '1.2.3',
          platform: 'test',
          platform_version: '4.5.6',
          machine: 'x86_64'
        }
      end
      let(:body) { '' }

      it 'returns nil' do
        expect(res).to eq(nil)
      end
    end

    context 'a missing channel option' do
      let(:options) do
        {
          version: '1.2.3',
          platform: 'test',
          platform_version: '4.5.6',
          machine: 'x86_64'
        }
      end

      it 'raises an error' do
        expect { res }.to raise_error(KeyError)
      end
    end

    context 'a missing version option' do
      let(:options) do
        {
          channel: 'stable',
          platform: 'test',
          platform_version: '4.5.6',
          machine: 'x86_64'
        }
      end

      it 'raises an error' do
        expect { res }.to raise_error(KeyError)
      end
    end

    context 'a missing platform option' do
      let(:options) do
        {
          channel: 'stable',
          version: '1.2.3',
          platform_version: '4.5.6',
          machine: 'x86_64'
        }
      end

      it 'raises an error' do
        expect { res }.to raise_error(KeyError)
      end
    end

    context 'a missing platform_version option' do
      let(:options) do
        {
          channel: 'stable',
          version: '1.2.3',
          platform: 'test',
          machine: 'x86_64'
        }
      end

      it 'raises an error' do
        expect { res }.to raise_error(KeyError)
      end
    end

    context 'a missing machine option' do
      let(:options) do
        {
          channel: 'stable',
          version: '1.2.3',
          platform: 'test',
          platform_version: '4.5.6'
        }
      end

      it 'raises an error' do
        expect { res }.to raise_error(KeyError)
      end
    end
  end

  describe '#valid_version?' do
    let(:version) { nil }
    let(:res) { described_class.valid_version?(version) }

    context 'a "latest" version' do
      let(:version) { 'latest' }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version' do
      let(:version) { '1.2.3' }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version + build' do
      let(:version) { '1.2.3-12' }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'an invalid version' do
      let(:version) { 'x.y.z' }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
  end
end
