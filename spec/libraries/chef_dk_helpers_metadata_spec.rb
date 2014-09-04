# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: chef_dk_helpers_metadata
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../spec_helper'
require_relative '../../libraries/chef_dk_helpers_metadata'

describe ChefDk::Helpers::Metadata do
  let(:package_name) { 'chefdk' }
  let(:platform) { {} }
  let(:node) { Fauxhai.mock(platform).data }
  let(:new_resource) { double(name: 'my_chef_dk') }
  let(:obj) { described_class.new(package_name, node, new_resource) }

  describe '#initialize' do
    [:package_name, :node, :new_resource].each do |attr|
      it "sets the correct #{attr}" do
        expect(obj.send(attr)).to eq(send(attr))
      end
    end

    it 'sets the correct base_url' do
      expect(obj.base_url).to eq('https://www.opscode.com/chef/metadata-chefdk')
    end
  end

  describe '#[]' do
    let(:fake_data) do
      { url: 'some url', md5: 'some md5', sha256: 'some sha256', yolo: true }
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:to_h)
        .and_return(fake_data)
      allow_any_instance_of(described_class).to receive(:filename)
        .and_return('something.pkg')
    end

    [:url, :md5, :sha256, :yolo].each do |attr|
      it "has access to the #{attr} data" do
        expect(obj[attr]).to eq(fake_data[attr])
      end
    end

    it 'has access to the filename' do
      expect(obj[:filename]).to eq('something.pkg')
    end
  end

  describe '#filename' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:url)
        .and_return('https://example.com/somewhere/over/here/thing.pkg')
    end

    it 'returns just the filename portion of the package URL' do
      expect(obj.filename).to eq('thing.pkg')
    end
  end

  [:url, :md5, :sha256, :yolo].each do |method|
    describe "##{method}" do
      let(:fake_data) do
        { url: 'some url', md5: 'some md5', sha256: 'some sha256', yolo: true }
      end

      before(:each) do
        allow_any_instance_of(described_class).to receive(:to_h)
          .and_return(fake_data)
      end

      it "returns the correct #{method} data" do
        expect(obj.send(method)).to eq(fake_data[method])
      end
    end
  end

  describe '#to_h' do
    context 'fake data' do
      let(:url) do
        'https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/' \
          'chefdk-0.2.1-1.el6.x86_64.rpm'
      end
      let(:md5) { 'feb2e06fdecae3bae79f8ec8d32d6ab6' }
      let(:sha256) do
        'afd487ab6f0cd0286a0a3d2808a041c784c064eddb6193d688edfb6741065b56'
      end
      let(:raw_metadata) { "url\t#{url}\nmd5\t#{md5}\nsha256\t#{sha256}" }

      before(:each) do
        allow_any_instance_of(described_class).to receive(:raw_metadata)
          .and_return(raw_metadata)
      end

      it 'returns the correct result hash' do
        expect(obj.to_h).to eq(url: url, md5: md5, sha256: sha256)
      end
    end

    json = ::File.open(File.expand_path('../../support/real_test_data.json',
                                        __FILE__)).read
    JSON.parse(json, symbolize_names: true).each do |data|
      context "#{data[:platform][:name]}-#{data[:platform][:version]} data" do
        let(:platform) do
          { platform: data[:platform][:name],
            version: data[:platform][:version] }
        end
        let(:new_resource) do
          double(name: 'my_chef_dk',
                 version: data[:version],
                 prerelease: data[:prerelease],
                 nightlies: data[:nightlies])
        end

        it 'returns the expected data' do
          expect(obj.to_h).to eq(data[:expected])
        end
      end
    end
  end

  describe '#to_s' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:raw_metadata)
        .and_return('SOMEDATA')
    end

    it 'returns the raw metadata string' do
      expect(obj.to_s).to eq('SOMEDATA')
    end
  end

  describe '#raw_metadata' do
    let(:murl) { URI.encode('https://fake.example.com/somewhere') }
    let(:parsed) { double(read: 'HTTPBODY') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:murl).and_return(murl)
      allow(URI).to receive(:parse).with(murl).and_return(parsed)
    end

    it 'returns the results of the HTTP GET' do
      expect(obj.send(:raw_metadata)).to eq('HTTPBODY')
    end

    context 'a non-existent URL' do
      before(:each) do
        allow(URI).to receive(:parse).with(murl)
          .and_raise(OpenURI::HTTPError.new('404 badness', 'fake'))
      end

      it 'rescues HTTP, e.g. 404, errors' do
        expect(obj.send(:raw_metadata)).to eq('')
      end
    end
  end

  describe '#murl' do
    let(:elements) { { shorts: 'on', pants: 'off' } }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:murl_elements)
        .and_return(elements)
    end

    it 'returns the expected URL' do
      expected = 'https://www.opscode.com/chef/metadata-chefdk?shorts=on&' \
                 'pants=off'
      expect(obj.send(:murl)).to eq(expected)
    end
  end

  describe '#murl_elements' do
    let(:new_resource) do
      double(name: 'my_chef_dk',
             version: '6.6.6',
             prerelease: false,
             nightlies: true)
    end

    before(:each) do
      {
        platform: 'fake', platform_version: '3.14', machine: 'x64'
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    it 'returns the expected elements hash' do
      expected = { v: '6.6.6',
                   prerelease: false,
                   nightlies: true,
                   p: 'fake',
                   pv: '3.14',
                   m: 'x64' }
      expect(obj.send(:murl_elements)).to eq(expected)
    end
  end

  describe '#platform' do
    [
      { platform: 'ubuntu', version: '12.04', expected: 'ubuntu' },
      { platform: 'centos', version: '6.5', expected: 'centos' },
      { platform: 'mac_os_x', version: '10.9.2', expected: 'mac_os_x' },
      { platform: 'windows', version: '2012', expected: 'windows' }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it "returns #{p[:expected]}" do
          expect(obj.send(:platform)).to eq(p[:expected])
        end
      end
    end
  end

  describe '#platform_version' do
    [
      { platform: 'ubuntu', version: '12.04', expected: '12.04' },
      { platform: 'centos', version: '6.5', expected: '6.5' },
      { platform: 'mac_os_x', version: '10.9.2', expected: '10.9' },
      { platform: 'windows', version: '2012', expected: '2012' }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it "returns #{p[:expected]}" do
          expect(obj.send(:platform_version)).to eq(p[:expected])
        end
      end
    end
  end

  describe '#machine' do
    [
      { platform: 'ubuntu', version: '12.04', expected: 'x86_64' },
      { platform: 'centos', version: '6.5', expected: 'x86_64' },
      { platform: 'mac_os_x', version: '10.9.2', expected: 'x86_64' },
      { platform: 'windows', version: '2012', expected: 'x86_64' }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it "returns #{p[:expected]}" do
          expect(obj.send(:machine)).to eq(p[:expected])
        end
      end
    end
  end
end
