# Encoding: UTF-8

require 'chef'
require 'chefspec'
require 'tmpdir'
require 'fileutils'

RSpec.configure do |c|
  c.color_enabled = true

  c.before(:suite) do
    COOKBOOK_PATH = Dir.mktmpdir 'chefspec'
    metadata = Chef::Cookbook::Metadata.new
    metadata.from_file(File.expand_path('../../metadata.rb', __FILE__))
    link_path = File.join(COOKBOOK_PATH, metadata.name)
    FileUtils.ln_s(File.expand_path('../..', __FILE__), link_path)
    c.cookbook_path = COOKBOOK_PATH
  end

  c.before(:each) do
    # Don't worry about external cookbook dependencies
    Chef::Cookbook::Metadata.any_instance.stub(:depends)

    # Prep lookup() for the stubs below
    Chef::ResourceCollection.any_instance.stub(:lookup).and_call_original

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    Chef::RunContext.any_instance.stub(:loaded_recipe?).and_return(false)
    Chef::Recipe.any_instance.stub(:include_recipe) do |i|
      Chef::RunContext.any_instance.stub(:loaded_recipe?).with(i)
        .and_return(true)
      @included_recipes << i
    end
    Chef::RunContext.any_instance.stub(:loaded_recipes)
      .and_return(@included_recipes)
  end

  c.after(:suite) { FileUtils.rm_r(COOKBOOK_PATH) }
end

at_exit { ChefSpec::Coverage.report! }
