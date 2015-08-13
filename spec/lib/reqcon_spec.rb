require "spec_helper"

class HostTest
  extend Reqcon
end
module Reqcon
  describe "#run" do
    let(:reqconsample) {YAML.load_file(File.expand_path("../../test_data/reqcons_mine.yml", __FILE__)) }
    let(:parvalsample) {YAML.load_file(File.expand_path("../../test_data/parvals_list.yml", __FILE__)) }
    it "takes in two lists" do
      puts HostTest.run(reqconsample, parvalsample).pretty_print_inspect
    end
  end
end