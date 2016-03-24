require 'digest'
require 'time'

module BoshDeploymentResource
  class OutCommand
    def initialize(bosh, manifest_path, writer=STDOUT)
      @bosh = bosh
      @manifest_path = manifest_path
      @writer = writer
    end

    def run(working_dir, request)
      validate! request
      errand = request.fetch("params")["errand"]
      bosh.errand(@manifest_path, errand)

      response = {
        "version" => {
          "manifest_sha1" => 1,
          "target" => bosh.target
        },
        "metadata" => []
      }

      writer.puts response.to_json
    end

    private

    attr_reader :bosh, :manifest, :writer

    def validate!(request)
      case request.fetch("params")["cleanup"]
      when nil, true, false
      else
        raise "given cleanup value must be a boolean"
      end

      ["manifest", "errand"].each do |field|
        request.fetch("params").fetch(field) { raise "params must include '#{field}'" }
      end
    end

    def find_stemcells(working_dir, request)
      globs = request.
        fetch("params").
        fetch("stemcells")

      glob(working_dir, globs)
    end

    def find_releases(working_dir, request)
      globs = request.
        fetch("params").
        fetch("releases")

      glob(working_dir, globs)
    end

    def glob(working_dir, globs)
      paths = []

      globs.each do |glob|
        abs_glob = File.join(working_dir, glob)
        results = Dir.glob(abs_glob)

        raise "glob '#{glob}' matched no files" if results.empty?

        paths.concat(results)
      end

      paths.uniq
    end

    def enumerable?(object)
      object.is_a? Enumerable
    end
  end
end
