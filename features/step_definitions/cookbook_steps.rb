Given /^a Chef cookbook with a recipe that logs a node attribute$/ do
  steps %q{
    Given a file named "cookbooks/example/recipes/default.rb" with:
    """
      log "The value of node.foo is: #{node.foo}"
    """
  }
end

Given /^the recipe has a spec example that sets a node attribute$/ do
  steps %q{
    Given a file named "cookbooks/example/spec/default_spec.rb" with:
    """
      require "chefspec"

      describe "example::default" do

        before(:all) do
          @chef_run = ChefSpec::ChefRunner.new
        end

        it "should log the node foo" do
          @chef_run.node.foo = 'bar'
          @chef_run.converge "example::default"
          @chef_run.should log "The value of node.foo is: bar"
        end
      end
    """
  }
end

Given /^the recipe has a spec example that overrides the operating system to '([^']+)'$/ do |operating_system|
  @operating_system = operating_system
  steps %Q{
    Given a file named "cookbooks/example/spec/default_spec.rb" with:
    """
      require "chefspec"

      describe "example::default" do

        before(:all) do
          @chef_run = ChefSpec::ChefRunner.new
        end

        it "should log the node platform" do
          @chef_run.node.automatic_attrs['platform'] = '#{operating_system}'
          @chef_run.converge "example::default"
          @chef_run.should log "I am running on the #{operating_system} platform."
        end
      end
    """
  }
end

When /^the recipe example is successfully run$/ do
  steps %q{
    When I successfully run `rspec cookbooks/example/spec/`
    Then it should pass with:
    """
    Found recipe default in cookbook example
    """
  }
end

Then /^the recipe will see the node attribute set in the spec example$/ do
  Then %q{the stdout should contain "Processing log[The value of node.foo is: bar]"}
end

Then /^the resources declared for the operating system will be available within the example$/ do
  Then %Q{the stdout should contain "Processing log[I am running on the #{@operating_system} platform.]"}
end
