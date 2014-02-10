# encoding: utf-8

require 'spec_helper'
require "logring/cli"

describe Logring::Cli do

  before :each do
    @cli = Logring::Cli.new([],{'configfile' => 'config.yml'})
    @testdir = File.join('spec','files','cli')
    @oldpwd = Dir.pwd
    Dir.chdir @testdir
  end

  after :each do
    FileUtils.rm_f 'config.yml' if File.exists? 'config.yml'
    Dir.chdir @oldpwd
  end

  it "creates a sample config when it does not exist" do
    @cli.shell.mute do
      @cli.list
    end
    expect(File.file? 'config.yml').to be_true
  end

end
