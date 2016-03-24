require "json"

module BoshDeploymentResource
  class CheckCommand
    def initialize(bosh, writer=STDOUT)
      @bosh = bosh
      @writer = writer
    end

    def run(request)
      versions = []
      versions << { "manifest_sha1" => 1 }
      writer.puts(versions.to_json)
    end

    private

    attr_reader :writer, :bosh
  end
end
